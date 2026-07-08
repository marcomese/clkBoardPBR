----------------------------------------------------------------------------------
-- PBR Clock Board
--
-- Module Name: tb_edgeDetectors
-- Self-checking testbench for edgeDetectors (pure rising-edge detector;
-- pulse widening is a separate module now, see tb_pulseExtender).
--
-- Created by: Marco Mese
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_edgeDetectors is
end tb_edgeDetectors;

architecture Behavioral of tb_edgeDetectors is

constant clkPeriod : time     := 10 ns;
constant multiNum  : positive := 4;

type intArr_t  is array(natural range <>) of integer;
type durList_t is array(natural range <>) of natural;

signal clk     : std_logic := '1';
signal rst     : std_logic := '1';
signal running : boolean    := true;

-- ============================================================
-- DUT 1: duration sweep + long hold (sigRst=0)
-- ============================================================
signal sigInSweep  : std_logic_vector(0 downto 0) := (others => '0');
signal sigOutSweep : std_logic_vector(0 downto 0);
signal pulseCntSweep  : intArr_t(0 to 0) := (others => 0);
signal widthCntSweep  : intArr_t(0 to 0) := (others => 0);
signal lastWidthSweep : intArr_t(0 to 0) := (others => 0);

-- ============================================================
-- DUT 2/3: reset while input held high, sigRst=0 vs sigRst=1
-- ============================================================
signal sigInRstLo  : std_logic_vector(0 downto 0) := (others => '0');
signal sigOutRstLo : std_logic_vector(0 downto 0);
signal pulseCntRstLo  : intArr_t(0 to 0) := (others => 0);
signal widthCntRstLo  : intArr_t(0 to 0) := (others => 0);
signal lastWidthRstLo : intArr_t(0 to 0) := (others => 0);

signal sigInRstHi  : std_logic_vector(0 downto 0) := (others => '0');
signal sigOutRstHi : std_logic_vector(0 downto 0);
signal pulseCntRstHi  : intArr_t(0 to 0) := (others => 0);
signal widthCntRstHi  : intArr_t(0 to 0) := (others => 0);
signal lastWidthRstHi : intArr_t(0 to 0) := (others => 0);

-- ============================================================
-- DUT 4: multi-bit simultaneous + staggered independence
-- ============================================================
signal sigInMulti  : std_logic_vector(multiNum-1 downto 0) := (others => '0');
signal sigOutMulti : std_logic_vector(multiNum-1 downto 0);
signal pulseCntMulti  : intArr_t(0 to multiNum-1) := (others => 0);
signal widthCntMulti  : intArr_t(0 to multiNum-1) := (others => 0);
signal lastWidthMulti : intArr_t(0 to multiNum-1) := (others => 0);

-- ============================================================
-- DUT 5/6: signal already HIGH at the very first (power-on) reset,
-- sigRst=0 vs sigRst=1. sigIn starts at '1' from declaration, so the
-- shared power-on reset release in stimProc IS the stimulus.
-- ============================================================
signal sigInPowerOnLo  : std_logic_vector(0 downto 0) := (others => '1');
signal sigOutPowerOnLo : std_logic_vector(0 downto 0);
signal pulseCntPowerOnLo  : intArr_t(0 to 0) := (others => 0);
signal widthCntPowerOnLo  : intArr_t(0 to 0) := (others => 0);
signal lastWidthPowerOnLo : intArr_t(0 to 0) := (others => 0);

signal sigInPowerOnHi  : std_logic_vector(0 downto 0) := (others => '1');
signal sigOutPowerOnHi : std_logic_vector(0 downto 0);
signal pulseCntPowerOnHi  : intArr_t(0 to 0) := (others => 0);
signal widthCntPowerOnHi  : intArr_t(0 to 0) := (others => 0);
signal lastWidthPowerOnHi : intArr_t(0 to 0) := (others => 0);

-- ============================================================
-- DUT 7: sigRst=15 (assume ALL 4 bits HIGH -- e.g. a disconnected /
-- damaged differential cable floating to a static '1'), but the ACTUAL
-- signal is LOW at power-on (e.g. cable actually connected, real value
-- starts at '0'). Confirms this "wrong-direction" mismatch produces NO
-- spurious trigger on any of the 4 bits.
-- ============================================================
signal sigInMismatch  : std_logic_vector(multiNum-1 downto 0) := (others => '0');
signal sigOutMismatch : std_logic_vector(multiNum-1 downto 0);
signal pulseCntMismatch  : intArr_t(0 to multiNum-1) := (others => 0);
signal widthCntMismatch  : intArr_t(0 to multiNum-1) := (others => 0);
signal lastWidthMismatch : intArr_t(0 to multiNum-1) := (others => 0);

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

-- rst is driven only from stimProc (see below): a concurrent assignment here
-- would create a second driver on the same signal, and any later reset pulse
-- issued from stimProc would resolve to 'X' against it (std_logic conflict).

----------------------------------------------------------------------------
-- DUT instantiations
----------------------------------------------------------------------------
dutSweep: entity work.edgeDetectors
generic map(sigRst => 0, sigNum => 1)
port map(clk => clk, rst => rst, sigIn => sigInSweep, sigOut => sigOutSweep);

dutRstLo: entity work.edgeDetectors
generic map(sigRst => 0, sigNum => 1)
port map(clk => clk, rst => rst, sigIn => sigInRstLo, sigOut => sigOutRstLo);

dutRstHi: entity work.edgeDetectors
generic map(sigRst => 1, sigNum => 1)
port map(clk => clk, rst => rst, sigIn => sigInRstHi, sigOut => sigOutRstHi);

dutMulti: entity work.edgeDetectors
generic map(sigRst => 0, sigNum => multiNum)
port map(clk => clk, rst => rst, sigIn => sigInMulti, sigOut => sigOutMulti);

dutPowerOnLo: entity work.edgeDetectors
generic map(sigRst => 0, sigNum => 1)
port map(clk => clk, rst => rst, sigIn => sigInPowerOnLo, sigOut => sigOutPowerOnLo);

dutPowerOnHi: entity work.edgeDetectors
generic map(sigRst => 1, sigNum => 1)
port map(clk => clk, rst => rst, sigIn => sigInPowerOnHi, sigOut => sigOutPowerOnHi);

dutMismatch: entity work.edgeDetectors
generic map(sigRst => 15, sigNum => multiNum)
port map(clk => clk, rst => rst, sigIn => sigInMismatch, sigOut => sigOutMismatch);

----------------------------------------------------------------------------
-- monitors: count pulses (rising edges of sigOut) and measure each pulse width
----------------------------------------------------------------------------
monSweep: process(clk)
    variable prev : std_logic_vector(0 downto 0) := (others => '0');
begin
    if rising_edge(clk) then
        if rst = '1' then
            prev := (others => '0');
            widthCntSweep <= (others => 0);
        else
            for n in 0 to 0 loop
                if sigOutSweep(n) = '1' and prev(n) = '0' then
                    pulseCntSweep(n) <= pulseCntSweep(n) + 1;
                end if;
                if sigOutSweep(n) = '1' then
                    widthCntSweep(n) <= widthCntSweep(n) + 1;
                elsif prev(n) = '1' then
                    lastWidthSweep(n) <= widthCntSweep(n);
                    widthCntSweep(n)  <= 0;
                end if;
            end loop;
            prev := sigOutSweep;
        end if;
    end if;
end process;

monRstLo: process(clk)
    variable prev : std_logic_vector(0 downto 0) := (others => '0');
begin
    if rising_edge(clk) then
        if rst = '1' then
            prev := (others => '0');
            widthCntRstLo <= (others => 0);
        else
            for n in 0 to 0 loop
                if sigOutRstLo(n) = '1' and prev(n) = '0' then
                    pulseCntRstLo(n) <= pulseCntRstLo(n) + 1;
                end if;
                if sigOutRstLo(n) = '1' then
                    widthCntRstLo(n) <= widthCntRstLo(n) + 1;
                elsif prev(n) = '1' then
                    lastWidthRstLo(n) <= widthCntRstLo(n);
                    widthCntRstLo(n)  <= 0;
                end if;
            end loop;
            prev := sigOutRstLo;
        end if;
    end if;
end process;

monRstHi: process(clk)
    variable prev : std_logic_vector(0 downto 0) := (others => '0');
begin
    if rising_edge(clk) then
        if rst = '1' then
            prev := (others => '0');
            widthCntRstHi <= (others => 0);
        else
            for n in 0 to 0 loop
                if sigOutRstHi(n) = '1' and prev(n) = '0' then
                    pulseCntRstHi(n) <= pulseCntRstHi(n) + 1;
                end if;
                if sigOutRstHi(n) = '1' then
                    widthCntRstHi(n) <= widthCntRstHi(n) + 1;
                elsif prev(n) = '1' then
                    lastWidthRstHi(n) <= widthCntRstHi(n);
                    widthCntRstHi(n)  <= 0;
                end if;
            end loop;
            prev := sigOutRstHi;
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

monPowerOnLo: process(clk)
    variable prev : std_logic_vector(0 downto 0) := (others => '0');
begin
    if rising_edge(clk) then
        if rst = '1' then
            prev := (others => '0');
            widthCntPowerOnLo <= (others => 0);
        else
            for n in 0 to 0 loop
                if sigOutPowerOnLo(n) = '1' and prev(n) = '0' then
                    pulseCntPowerOnLo(n) <= pulseCntPowerOnLo(n) + 1;
                end if;
                if sigOutPowerOnLo(n) = '1' then
                    widthCntPowerOnLo(n) <= widthCntPowerOnLo(n) + 1;
                elsif prev(n) = '1' then
                    lastWidthPowerOnLo(n) <= widthCntPowerOnLo(n);
                    widthCntPowerOnLo(n)  <= 0;
                end if;
            end loop;
            prev := sigOutPowerOnLo;
        end if;
    end if;
end process;

monPowerOnHi: process(clk)
    variable prev : std_logic_vector(0 downto 0) := (others => '0');
begin
    if rising_edge(clk) then
        if rst = '1' then
            prev := (others => '0');
            widthCntPowerOnHi <= (others => 0);
        else
            for n in 0 to 0 loop
                if sigOutPowerOnHi(n) = '1' and prev(n) = '0' then
                    pulseCntPowerOnHi(n) <= pulseCntPowerOnHi(n) + 1;
                end if;
                if sigOutPowerOnHi(n) = '1' then
                    widthCntPowerOnHi(n) <= widthCntPowerOnHi(n) + 1;
                elsif prev(n) = '1' then
                    lastWidthPowerOnHi(n) <= widthCntPowerOnHi(n);
                    widthCntPowerOnHi(n)  <= 0;
                end if;
            end loop;
            prev := sigOutPowerOnHi;
        end if;
    end if;
end process;

monMismatch: process(clk)
    variable prev : std_logic_vector(multiNum-1 downto 0) := (others => '0');
begin
    if rising_edge(clk) then
        if rst = '1' then
            prev := (others => '0');
            widthCntMismatch <= (others => 0);
        else
            for n in 0 to multiNum-1 loop
                if sigOutMismatch(n) = '1' and prev(n) = '0' then
                    pulseCntMismatch(n) <= pulseCntMismatch(n) + 1;
                end if;
                if sigOutMismatch(n) = '1' then
                    widthCntMismatch(n) <= widthCntMismatch(n) + 1;
                elsif prev(n) = '1' then
                    lastWidthMismatch(n) <= widthCntMismatch(n);
                    widthCntMismatch(n)  <= 0;
                end if;
            end loop;
            prev := sigOutMismatch;
        end if;
    end if;
end process;

----------------------------------------------------------------------------
-- stimulus + checks
----------------------------------------------------------------------------
stimProc: process
    variable errors : integer := 0;

    -- expected-value bookkeeping: each variable is incremented by the code
    -- itself as stimuli are applied, never hand-computed, to avoid manual
    -- arithmetic mistakes in the checks below.
    variable cSweep    : integer := 0;
    variable cRstLo    : integer := 0;
    variable cRstHi    : integer := 0;
    variable cMulti    : intArr_t(0 to multiNum-1) := (others => 0);
    variable cMismatch : integer := 0;

    -- stimulus table (declared here, not inline: VHDL for-loops have no
    -- declarative part, so this cannot live next to its loop). Includes a
    -- long hold (50) to prove duration-independence up to a long duration.
    constant sweepDur : durList_t(0 to 5) := (1, 2, 3, 7, 20, 50);

    -- drive tgt(idx) high for nCycles consecutive clocks, then low.
    -- Bumps cnt: any duration produces exactly one rising edge.
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

    -- keep the clock running with no stimulus change for nCycles clocks
    procedure idle(constant nCycles : in natural) is
    begin
        for i in 1 to nCycles loop
            wait until rising_edge(clk);
        end loop;
    end procedure;

    -- generic check: compares a monitor array element (pulse count or width)
    -- against an expected value
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

    -- direct boolean assertion (e.g. a signal level check)
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
    -- power-on reset: rst starts at '1' (its declared initial value) and is
    -- released here. This process is rst's only driver (see note above).
    idle(4);
    rst <= '0';
    -- safe margin before Scenario 0's checks: the width/lastWidth latch needs
    -- one more edge than the pulse-count increment (it must see the fall,
    -- one edge after the rise).
    idle(4);

    ------------------------------------------------------------------------
    -- Scenario 0: signal already HIGH at the very first (power-on) reset.
    -- sigInPowerOn*'s '1' initial value means the reset release right above
    -- IS the stimulus: sigRst=0 (assume-low) must show a spurious edge right
    -- at release; sigRst=1 (assume-high) must show none.
    ------------------------------------------------------------------------
    checkVal("PowerOn (sigRst=0) spurious-edge count",    pulseCntPowerOnLo,  0, 1);
    checkVal("PowerOn (sigRst=0) spurious-edge width",    lastWidthPowerOnLo, 0, 1);
    checkVal("PowerOn (sigRst=1) no-spurious-edge count", pulseCntPowerOnHi,  0, 0);

    -- Mismatch: sigRst=15 (assume ALL 4 bits HIGH) but the real signal is
    -- actually LOW at power-on -- must not trigger on any bit.
    for n in 0 to multiNum-1 loop
        checkVal("Mismatch (sigRst=15, actual low) bit " & integer'image(n) & " no-spurious-edge",
                 pulseCntMismatch, n, 0);
    end loop;

    firePulse(sigInMismatch, 0, 2, cMismatch);
    idle(3);
    checkVal("Mismatch real-edge-after-poweron count", pulseCntMismatch,  0, cMismatch);
    checkVal("Mismatch real-edge-after-poweron width", lastWidthMismatch, 0, 1);

    ------------------------------------------------------------------------
    -- Scenario 1: duration sweep -- edge fires regardless of how long sigIn
    -- is held high, always a single one-cycle pulse.
    ------------------------------------------------------------------------
    for i in sweepDur'range loop
        firePulse(sigInSweep, 0, sweepDur(i), cSweep);
        idle(3);
    end loop;
    checkVal("duration-sweep count",      pulseCntSweep,  0, cSweep);
    checkVal("duration-sweep last width", lastWidthSweep, 0, 1);

    ------------------------------------------------------------------------
    -- Scenario 2/3: reset asserted while sigIn is already high.
    -- sigRst=0 (assume-low)  -> a spurious edge is expected after reset.
    -- sigRst=1 (assume-high) -> no spurious edge; a real edge afterwards
    -- still works, proving the DUT is not stuck.
    ------------------------------------------------------------------------
    wait until rising_edge(clk);
    sigInRstLo(0) <= '1';
    wait until rising_edge(clk);
    rst <= '1';
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    rst <= '0';
    wait until rising_edge(clk);
    sigInRstLo(0) <= '0';
    cRstLo := cRstLo + 1;   -- the reset-induced mismatch is expected to fire once
    idle(3);
    checkVal("RstLo (sigRst=0) spurious-edge count", pulseCntRstLo,  0, cRstLo);
    checkVal("RstLo (sigRst=0) spurious-edge width", lastWidthRstLo, 0, 1);

    checkVal("RstHi (sigRst=1) baseline count (before any stimulus)", pulseCntRstHi, 0, cRstHi);

    wait until rising_edge(clk);
    sigInRstHi(0) <= '1';
    wait until rising_edge(clk);
    rst <= '1';
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    rst <= '0';
    wait until rising_edge(clk);
    sigInRstHi(0) <= '0';
    idle(3);
    checkVal("RstHi (sigRst=1) no-spurious-edge count", pulseCntRstHi, 0, cRstHi);

    firePulse(sigInRstHi, 0, 2, cRstHi);
    idle(3);
    checkVal("RstHi (sigRst=1) real-edge-after-reset count", pulseCntRstHi,  0, cRstHi);
    checkVal("RstHi (sigRst=1) real-edge-after-reset width", lastWidthRstHi, 0, 1);

    ------------------------------------------------------------------------
    -- Scenario 4: multi-bit -- simultaneous trigger on two bits, then
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
    idle(3);
    checkVal("Multi simultaneous bit0 count", pulseCntMulti,  0, cMulti(0));
    checkVal("Multi simultaneous bit1 count", pulseCntMulti,  1, cMulti(1));
    checkVal("Multi simultaneous bit0 width", lastWidthMulti, 0, 1);
    checkVal("Multi simultaneous bit1 width", lastWidthMulti, 1, 1);
    checkVal("Multi bit2 undisturbed",        pulseCntMulti,  2, cMulti(2));
    checkVal("Multi bit3 undisturbed",        pulseCntMulti,  3, cMulti(3));

    wait until rising_edge(clk);
    sigInMulti(2) <= '1';
    wait until rising_edge(clk);
    sigInMulti(3) <= '1';        -- bit3 starts while bit2 is still high
    wait until rising_edge(clk);
    sigInMulti(2) <= '0';        -- bit2 ends first
    wait until rising_edge(clk);
    sigInMulti(3) <= '0';        -- bit3 ends later
    cMulti(2) := cMulti(2) + 1;
    cMulti(3) := cMulti(3) + 1;
    idle(3);
    checkVal("Multi staggered bit2 count",   pulseCntMulti, 2, cMulti(2));
    checkVal("Multi staggered bit3 count",   pulseCntMulti, 3, cMulti(3));
    checkVal("Multi bit0 still undisturbed", pulseCntMulti, 0, cMulti(0));
    checkVal("Multi bit1 still undisturbed", pulseCntMulti, 1, cMulti(1));

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
