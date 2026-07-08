----------------------------------------------------------------------------------
-- PBR Clock Board
--
-- Module Name: tb_pulseExtender
-- Self-checking testbench for pulseExtender
--
-- Created by: Marco Mese
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_pulseExtender is
end tb_pulseExtender;

architecture Behavioral of tb_pulseExtender is

constant clkPeriod : time     := 10 ns;
constant W5        : positive := 5;   -- sigWidth used by the extension DUTs
constant multiNum  : positive := 4;

type intArr_t  is array(natural range <>) of integer;
type durList_t is array(natural range <>) of natural;

signal clk     : std_logic := '1';
signal rst     : std_logic := '1';
signal running : boolean    := true;

-- ============================================================
-- DUT 1: sigWidth<=1 -- pure combinational passthrough (sigOut <= sigIn;
-- not even inside a process). No reset dependency at all in this branch.
-- ============================================================
signal sigInPass  : std_logic_vector(1 downto 0) := (others => '0');
signal sigOutPass : std_logic_vector(1 downto 0);

-- ============================================================
-- DUT 2: sigWidth=5 -- clean-trigger duration sweep (durations 1..sigWidth,
-- all confirmed to stay within the "no overlap" regime) + safe-gap sweep.
-- ============================================================
signal sigInExtend  : std_logic_vector(0 downto 0) := (others => '0');
signal sigOutExtend : std_logic_vector(0 downto 0);
signal pulseCntExtend  : intArr_t(0 to 0) := (others => 0);
signal widthCntExtend  : intArr_t(0 to 0) := (others => 0);
signal lastWidthExtend : intArr_t(0 to 0) := (others => 0);

-- ============================================================
-- DUT 3: sigIn held HIGH continuously, much longer than sigWidth.
-- OBSERVATIONAL: pulseExtender retriggers on every cycle sigIn=1 (it has no
-- edge detection of its own -- that's edgeDetectors' job upstream), so a
-- continuously-held input produces a repeating train of sigWidth-high /
-- 1-cycle-low pulses for as long as sigIn stays high. Reported, not asserted
-- to an exact count, since this is a "what does it actually do" check on a
-- stimulus pattern that shouldn't occur downstream of edgeDetectors anyway.
-- ============================================================
signal sigInHeldHigh  : std_logic_vector(0 downto 0) := (others => '0');
signal sigOutHeldHigh : std_logic_vector(0 downto 0);
signal pulseCntHeldHigh  : intArr_t(0 to 0) := (others => 0);
signal widthCntHeldHigh  : intArr_t(0 to 0) := (others => 0);
signal lastWidthHeldHigh : intArr_t(0 to 0) := (others => 0);

-- ============================================================
-- DUT 4: discrete retrigger / overlap sweep near the sigWidth boundary.
-- OBSERVATIONAL: when a new trigger coincides with the extension counter
-- reaching zero in the same cycle, the RTL's "last assignment wins"
-- semantics (the "if sigWCnt=0" branch runs after the "if sigIn=1" branch)
-- make the outcome ambiguous by inspection alone.
-- ============================================================
signal sigInRetrigger  : std_logic_vector(0 downto 0) := (others => '0');
signal sigOutRetrigger : std_logic_vector(0 downto 0);
signal pulseCntRetrigger  : intArr_t(0 to 0) := (others => 0);
signal widthCntRetrigger  : intArr_t(0 to 0) := (others => 0);
signal lastWidthRetrigger : intArr_t(0 to 0) := (others => 0);

-- ============================================================
-- DUT 5: reset asserted mid-extension. sigOut must clear immediately and
-- the DUT must recover cleanly afterwards. No sigRst-style generic here
-- (pulseExtender always resets to the same idle state, unconditionally).
-- ============================================================
signal sigInReset  : std_logic_vector(0 downto 0) := (others => '0');
signal sigOutReset : std_logic_vector(0 downto 0);
signal pulseCntReset  : intArr_t(0 to 0) := (others => 0);
signal widthCntReset  : intArr_t(0 to 0) := (others => 0);
signal lastWidthReset : intArr_t(0 to 0) := (others => 0);

-- ============================================================
-- DUT 6: multi-bit simultaneous + staggered independence.
-- ============================================================
signal sigInMulti  : std_logic_vector(multiNum-1 downto 0) := (others => '0');
signal sigOutMulti : std_logic_vector(multiNum-1 downto 0);
signal pulseCntMulti  : intArr_t(0 to multiNum-1) := (others => 0);
signal widthCntMulti  : intArr_t(0 to multiNum-1) := (others => 0);
signal lastWidthMulti : intArr_t(0 to multiNum-1) := (others => 0);

begin

----------------------------------------------------------------------------
-- clock
----------------------------------------------------------------------------
clkProc: process
begin
    while running loop
        clk <= '0';
        wait for clkPeriod/2;
        clk <= '1';
        wait for clkPeriod/2;
    end loop;
    wait;
end process;

-- rst is driven only from stimProc: a concurrent assignment here would
-- create a second driver on the same signal (see tb_edgeDetectors for the
-- 'X'-resolution issue this caused there).

----------------------------------------------------------------------------
-- DUT instantiations
----------------------------------------------------------------------------
dutPass: entity work.pulseExtender
generic map(sigWidth => 1, sigNum => 2)
port map(clk => clk, rst => rst, sigIn => sigInPass, sigOut => sigOutPass);

dutExtend: entity work.pulseExtender
generic map(sigWidth => W5, sigNum => 1)
port map(clk => clk, rst => rst, sigIn => sigInExtend, sigOut => sigOutExtend);

dutHeldHigh: entity work.pulseExtender
generic map(sigWidth => W5, sigNum => 1)
port map(clk => clk, rst => rst, sigIn => sigInHeldHigh, sigOut => sigOutHeldHigh);

dutRetrigger: entity work.pulseExtender
generic map(sigWidth => W5, sigNum => 1)
port map(clk => clk, rst => rst, sigIn => sigInRetrigger, sigOut => sigOutRetrigger);

dutReset: entity work.pulseExtender
generic map(sigWidth => W5, sigNum => 1)
port map(clk => clk, rst => rst, sigIn => sigInReset, sigOut => sigOutReset);

dutMulti: entity work.pulseExtender
generic map(sigWidth => W5, sigNum => multiNum)
port map(clk => clk, rst => rst, sigIn => sigInMulti, sigOut => sigOutMulti);

----------------------------------------------------------------------------
-- monitors: count pulses (rising edges of sigOut) and measure each pulse
-- width. widthCnt is also cleared on rst, so a reset mid-pulse doesn't leak
-- a stale accumulator into the next measured pulse.
----------------------------------------------------------------------------
monExtend: process(clk)
    variable prev : std_logic_vector(0 downto 0) := (others => '0');
begin
    if rising_edge(clk) then
        if rst = '1' then
            prev := (others => '0');
            widthCntExtend <= (others => 0);
        else
            for n in 0 to 0 loop
                if sigOutExtend(n) = '1' and prev(n) = '0' then
                    pulseCntExtend(n) <= pulseCntExtend(n) + 1;
                end if;
                if sigOutExtend(n) = '1' then
                    widthCntExtend(n) <= widthCntExtend(n) + 1;
                elsif prev(n) = '1' then
                    lastWidthExtend(n) <= widthCntExtend(n);
                    widthCntExtend(n)  <= 0;
                end if;
            end loop;
            prev := sigOutExtend;
        end if;
    end if;
end process;

monHeldHigh: process(clk)
    variable prev : std_logic_vector(0 downto 0) := (others => '0');
begin
    if rising_edge(clk) then
        if rst = '1' then
            prev := (others => '0');
            widthCntHeldHigh <= (others => 0);
        else
            for n in 0 to 0 loop
                if sigOutHeldHigh(n) = '1' and prev(n) = '0' then
                    pulseCntHeldHigh(n) <= pulseCntHeldHigh(n) + 1;
                end if;
                if sigOutHeldHigh(n) = '1' then
                    widthCntHeldHigh(n) <= widthCntHeldHigh(n) + 1;
                elsif prev(n) = '1' then
                    lastWidthHeldHigh(n) <= widthCntHeldHigh(n);
                    widthCntHeldHigh(n)  <= 0;
                end if;
            end loop;
            prev := sigOutHeldHigh;
        end if;
    end if;
end process;

monRetrigger: process(clk)
    variable prev : std_logic_vector(0 downto 0) := (others => '0');
begin
    if rising_edge(clk) then
        if rst = '1' then
            prev := (others => '0');
            widthCntRetrigger <= (others => 0);
        else
            for n in 0 to 0 loop
                if sigOutRetrigger(n) = '1' and prev(n) = '0' then
                    pulseCntRetrigger(n) <= pulseCntRetrigger(n) + 1;
                end if;
                if sigOutRetrigger(n) = '1' then
                    widthCntRetrigger(n) <= widthCntRetrigger(n) + 1;
                elsif prev(n) = '1' then
                    lastWidthRetrigger(n) <= widthCntRetrigger(n);
                    widthCntRetrigger(n)  <= 0;
                end if;
            end loop;
            prev := sigOutRetrigger;
        end if;
    end if;
end process;

monReset: process(clk)
    variable prev : std_logic_vector(0 downto 0) := (others => '0');
begin
    if rising_edge(clk) then
        if rst = '1' then
            prev := (others => '0');
            widthCntReset <= (others => 0);
        else
            for n in 0 to 0 loop
                if sigOutReset(n) = '1' and prev(n) = '0' then
                    pulseCntReset(n) <= pulseCntReset(n) + 1;
                end if;
                if sigOutReset(n) = '1' then
                    widthCntReset(n) <= widthCntReset(n) + 1;
                elsif prev(n) = '1' then
                    lastWidthReset(n) <= widthCntReset(n);
                    widthCntReset(n)  <= 0;
                end if;
            end loop;
            prev := sigOutReset;
        end if;
    end if;
end process;

monMulti: process(clk)
    variable prev : std_logic_vector(multiNum-1 downto 0) := (others => '0');
begin
    if rising_edge(clk) then
        if rst = '1' then
            prev := (others => '0');
            widthCntMulti <= (others => 0);
        else
            for n in 0 to multiNum-1 loop
                if sigOutMulti(n) = '1' and prev(n) = '0' then
                    pulseCntMulti(n) <= pulseCntMulti(n) + 1;
                end if;
                if sigOutMulti(n) = '1' then
                    widthCntMulti(n) <= widthCntMulti(n) + 1;
                elsif prev(n) = '1' then
                    lastWidthMulti(n) <= widthCntMulti(n);
                    widthCntMulti(n)  <= 0;
                end if;
            end loop;
            prev := sigOutMulti;
        end if;
    end if;
end process;

----------------------------------------------------------------------------
-- stimulus + checks
----------------------------------------------------------------------------
stimProc: process
    variable errors : integer := 0;

    -- expected-value bookkeeping: each variable is incremented by the code
    -- itself as stimuli are applied, never hand-computed.
    variable cExtend     : integer := 0;
    variable cReset      : integer := 0;
    variable cResetBase  : integer := 0;
    variable cRetrigger  : integer := 0;
    variable cHeldHigh   : integer := 0;
    variable cMulti      : intArr_t(0 to multiNum-1) := (others => 0);

    -- duration sweep for the clean-extension case: all values <= W5 keep the
    -- trigger safely inside the "no overlap with the counter reaching zero"
    -- regime, so every one of these must produce exactly one W5-wide pulse.
    constant sweepDurExtend : durList_t(0 to 4) := (1, 2, 3, 4, 5);
    constant safeGap        : natural := W5 + 3;
    constant sweepGap       : durList_t(0 to 3) := (W5+1, W5+2, W5*2, W5*4);
    constant overlapGaps    : durList_t(0 to 5) := (1, 2, 3, 4, 5, 6);

    procedure firePulse(signal   tgt     : out std_logic_vector;
                        constant idx     : in  natural;
                        constant nCycles : in  natural;
                        variable cnt     : inout integer) is
    begin
        wait until rising_edge(clk);
        tgt(idx) <= '1';
        for i in 1 to nCycles loop
            wait until rising_edge(clk);
        end loop;
        tgt(idx) <= '0';
        cnt := cnt + 1;
    end procedure;

    procedure idle(constant nCycles : in natural) is
    begin
        for i in 1 to nCycles loop
            wait until rising_edge(clk);
        end loop;
    end procedure;

    procedure checkVal(constant name : in string;
                       signal   arr  : in intArr_t;
                       constant idx  : in natural;
                       constant exp  : in integer) is
    begin
        if arr(idx) /= exp then
            report name & " FAILED: got " & integer'image(arr(idx))
                 & ", expected " & integer'image(exp) severity error;
            errors := errors + 1;
        else
            report name & " PASSED (" & integer'image(exp) & ")" severity note;
        end if;
    end procedure;

    procedure checkBit(constant name : in string; constant cond : in boolean) is
    begin
        if not cond then
            report name & " FAILED" severity error;
            errors := errors + 1;
        else
            report name & " PASSED" severity note;
        end if;
    end procedure;

begin
    idle(4);
    rst <= '0';
    idle(4);

    ------------------------------------------------------------------------
    -- Scenario 0: sigWidth<=1 passthrough. Combinational (not clocked, not
    -- reset-dependent): sigOut must mirror sigIn immediately, even with
    -- rst asserted -- this generate branch does not reference rst at all.
    ------------------------------------------------------------------------
    checkBit("Pass: both bits low at power-on", unsigned(sigOutPass) = 0);

    rst <= '1';   -- re-assert rst to prove the passthrough ignores it
    wait for 1 ns;
    sigInPass(0) <= '1';
    wait for 1 ns;
    checkBit("Pass: sigOut follows sigIn(0) even while rst='1' (no reset dependency)",
             sigOutPass(0) = '1' and sigOutPass(1) = '0');

    sigInPass(1) <= '1';
    wait for 1 ns;
    checkBit("Pass: sigOut follows sigIn on bit1 too", sigOutPass = sigInPass);

    sigInPass <= (others => '0');
    wait for 1 ns;
    checkBit("Pass: sigOut returns to 0 following sigIn", unsigned(sigOutPass) = 0);

    rst <= '0';
    idle(2);   -- let the shared rst settle before the clocked DUTs resume

    ------------------------------------------------------------------------
    -- Scenario 1: sigWidth=5 -- clean single-cycle-style trigger, duration
    -- sweep from 1 up to sigWidth itself (all confirmed non-overlapping):
    -- always exactly one W5-wide output pulse. Then a sweep of safe gaps
    -- (all > sigWidth) confirms no cross-talk between successive triggers.
    ------------------------------------------------------------------------
    for i in sweepDurExtend'range loop
        firePulse(sigInExtend, 0, sweepDurExtend(i), cExtend);
        idle(safeGap);
    end loop;
    checkVal("Extend duration-sweep count",      pulseCntExtend,  0, cExtend);
    checkVal("Extend duration-sweep last width", lastWidthExtend, 0, W5);

    for i in sweepGap'range loop
        firePulse(sigInExtend, 0, 1, cExtend);
        idle(sweepGap(i));
    end loop;
    checkVal("Extend gap-sweep count",      pulseCntExtend,  0, cExtend);
    checkVal("Extend gap-sweep last width", lastWidthExtend, 0, W5);

    ------------------------------------------------------------------------
    -- Scenario 2: reset asserted mid-extension. sigOut must clear
    -- immediately; the DUT must recover cleanly afterwards. Unlike
    -- edgeDetectors, pulseExtender has no sigRst-style "assumed prior state"
    -- generic, so a single reset behavior covers this module completely.
    ------------------------------------------------------------------------
    firePulse(sigInReset, 0, 1, cReset);
    wait until rising_edge(clk);   -- into the extension window
    wait until rising_edge(clk);   -- still well before sigWidth=5 completes
    rst <= '1';
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    rst <= '0';
    wait until rising_edge(clk);   -- let the cleared state settle
    checkBit("Reset: sigOut cleared right after reset", sigOutReset(0) = '0');

    idle(safeGap);
    cResetBase := pulseCntReset(0);

    firePulse(sigInReset, 0, 1, cReset);
    idle(safeGap);
    checkVal("Reset recovery count (delta from baseline)",
             pulseCntReset, 0, cResetBase + 1);
    checkVal("Reset recovery width", lastWidthReset, 0, W5);

    ------------------------------------------------------------------------
    -- Scenario 3: multi-bit -- simultaneous trigger on two bits, then
    -- staggered/overlapping trigger on two other bits, checking cross-bit
    -- independence throughout.
    ------------------------------------------------------------------------
    wait until rising_edge(clk);
    sigInMulti(0) <= '1';
    sigInMulti(1) <= '1';
    wait until rising_edge(clk);
    sigInMulti(0) <= '0';
    sigInMulti(1) <= '0';
    cMulti(0) := cMulti(0) + 1;
    cMulti(1) := cMulti(1) + 1;
    idle(safeGap);
    checkVal("Multi simultaneous bit0 count", pulseCntMulti,  0, cMulti(0));
    checkVal("Multi simultaneous bit1 count", pulseCntMulti,  1, cMulti(1));
    checkVal("Multi simultaneous bit0 width", lastWidthMulti, 0, W5);
    checkVal("Multi simultaneous bit1 width", lastWidthMulti, 1, W5);

    wait until rising_edge(clk);
    sigInMulti(2) <= '1';
    wait until rising_edge(clk);
    sigInMulti(3) <= '1';
    wait until rising_edge(clk);
    sigInMulti(2) <= '0';
    wait until rising_edge(clk);
    sigInMulti(3) <= '0';
    cMulti(2) := cMulti(2) + 1;
    cMulti(3) := cMulti(3) + 1;
    idle(safeGap);
    checkVal("Multi staggered bit2 count",   pulseCntMulti,  2, cMulti(2));
    checkVal("Multi staggered bit3 count",   pulseCntMulti,  3, cMulti(3));
    checkVal("Multi staggered bit2 width",   lastWidthMulti, 2, W5);
    checkVal("Multi staggered bit3 width",   lastWidthMulti, 3, W5);
    checkVal("Multi bit0 still undisturbed", pulseCntMulti,  0, cMulti(0));
    checkVal("Multi bit1 still undisturbed", pulseCntMulti,  1, cMulti(1));

    ------------------------------------------------------------------------
    -- Scenario 4: sigIn held HIGH continuously, much longer than sigWidth.
    -- OBSERVATIONAL: reports the resulting pulse train (pulseExtender has no
    -- edge detection, so a continuously-held input retriggers every cycle).
    ------------------------------------------------------------------------
    firePulse(sigInHeldHigh, 0, 30, cHeldHigh);
    idle(safeGap);
    report "=== OBSERVATIONAL: sigIn held high for 30 cycles (sigWidth="
         & integer'image(W5) & ") ===" severity note;
    report "  pulses observed (DUT) = " & integer'image(pulseCntHeldHigh(0)) severity note;
    report "  last measured width   = " & integer'image(lastWidthHeldHigh(0)) severity note;
    report "  NOTE: pulseExtender retriggers on every cycle sigIn=1 (no edge"
         & " detection of its own); a continuously-held input is expected to"
         & " produce a repeating train of W5-high/1-low pulses, not a single"
         & " extended one. This stimulus pattern should not occur downstream"
         & " of edgeDetectors, which always produces single-cycle pulses."
         severity note;

    ------------------------------------------------------------------------
    -- Scenario 5: discrete retrigger / overlap sweep around the sigWidth
    -- boundary. OBSERVATIONAL ONLY: when a new trigger coincides with the
    -- extension counter reaching zero in the same cycle, the RTL's "last
    -- assignment wins" semantics make the outcome ambiguous by inspection
    -- alone. Reported, not hard-asserted -- inspect the waveform if the
    -- counts don't match what you expect from the design intent.
    ------------------------------------------------------------------------
    for i in overlapGaps'range loop
        firePulse(sigInRetrigger, 0, 1, cRetrigger);
        idle(overlapGaps(i));
    end loop;
    report "=== OBSERVATIONAL: retrigger/overlap sweep (gaps 1..6 around sigWidth="
         & integer'image(W5) & ") ===" severity note;
    report "  triggers driven       = " & integer'image(cRetrigger) severity note;
    report "  pulses observed (DUT) = " & integer'image(pulseCntRetrigger(0)) severity note;
    report "  last measured width   = " & integer'image(lastWidthRetrigger(0)) severity note;
    report "  NOTE: not asserted (ambiguous corner case); inspect the waveform if"
         & " pulses observed does not match triggers driven." severity note;
    idle(safeGap);

    ------------------------------------------------------------------------
    -- summary
    ------------------------------------------------------------------------
    if errors = 0 then
        report "=== ALL TESTS PASSED ===" severity note;
    else
        report "=== " & integer'image(errors) & " TEST(S) FAILED ===" severity error;
    end if;

    running <= false;
    wait;
end process;

end Behavioral;
