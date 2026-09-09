library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

library UNISIM;
use UNISIM.vcomponents.all;

entity tb_clk40MCounter is
end tb_clk40MCounter;

architecture Behavioral of tb_clk40MCounter is

constant clkPeriod     : time := 10 ns;
constant clkSmplPeriod : time := 5 ns;
constant clk40MPeriod  : time := 25 ns;

-- swept range of trgDelay (0 is not supported: trgDelBuf would be a null range)
constant nMin         : integer := 1;
constant nMax         : integer := 7;

-- number of distinct trigger phases: clk, clkSmpl and clk40M repeat their
-- relative phase every 50 ns, i.e. every 5 clk periods
constant phaseNum     : integer := 5;

-- The table printed by stimProc gives, for every phase and every trgDelay, the
-- difference between the latched value and the number of 40 MHz cycles the
-- BUFGCE had actually emitted at the trigger instant. The smallest trgDelay
-- whose column is zero on all phases is the minimum that guarantees the record
-- carries the count at the trigger and not an older one. Expected latency to
-- cover: 2 clkSmpl cycles for the edge detector in the counter, 1 clkSmpl plus
-- 2 clk for xpm_cdc_gray (src_gray_ff, dest_graysync_ff, REG_OUTPUT = 0).

type cntArr_t is array(nMin to nMax) of std_logic_vector(31 downto 0);

signal clk       : std_logic := '1';
signal clkSmpl   : std_logic := '1';
signal clk40M    : std_logic := '1';
signal clk40MSig : std_logic;
signal rst       : std_logic := '1';
signal enable    : std_logic := '0';
signal clear     : std_logic := '0';
signal trgIn     : std_logic := '0';

signal readyArr     : std_logic_vector(nMin to nMax);
signal clk40MCntArr : cntArr_t;

-- reference: number of 40 MHz cycles actually emitted by the BUFGCE
signal refCnt    : integer := 0;
signal refAtTrg  : integer := 0;

begin

clk     <= not clk after clkPeriod/2;

clkSmpl <= not clkSmpl after clkSmplPeriod/2;

clk40M  <= not clk40M after clk40MPeriod/2;

clk40MBUFGCEInst: BUFGCE
port map(
    I  => clk40M,
    CE => enable,
    O  => clk40MSig
);

refProc: process(clk40MSig, enable)
begin
    if enable = '0' then
        refCnt <= 0;
    elsif rising_edge(clk40MSig) then
        refCnt <= refCnt + 1;
    end if;
end process;

dutGen: for n in nMin to nMax generate
    clk40MCounterInst: entity work.clk40MCounter
    generic map(
        trgDelay => n
    )
    port map(
        clk       => clk,
        clkSmpl   => clkSmpl,
        clk40M    => clk40MSig,
        rst       => rst,
        enable    => enable,
        clear     => clear,
        trgIn     => trgIn,
        ready     => readyArr(n),
        clk40MCnt => clk40MCntArr(n)
    );
end generate;

stimProc: process
    variable l : line;
begin
    wait for clkPeriod*5;
    rst <= '0';
    wait for clkPeriod*10;

    enable <= '1';

    write(l, string'("phase   emitted    error for trgDelay = "));
    for n in nMin to nMax loop
        write(l, n);
        write(l, string'("  "));
    end loop;
    writeline(output, l);

    -- one trigger per phase: 1000 ns is an integer number of both clock
    -- periods, so k extra clk cycles select the phase
    for k in 0 to phaseNum-1 loop
        wait for 1000 ns;

        for j in 1 to k loop
            wait until rising_edge(clk);
        end loop;

        wait until rising_edge(clk);
        trgIn    <= '1';
        refAtTrg <= refCnt;
        wait until rising_edge(clk);
        trgIn    <= '0';

        -- wait for the slowest instance to latch
        for j in 1 to nMax+8 loop
            wait until rising_edge(clk);
        end loop;

        write(l, string'("  "));
        write(l, k);
        write(l, string'("     "));
        write(l, refAtTrg);
        write(l, string'("        "));
        for n in nMin to nMax loop
            write(l, to_integer(unsigned(clk40MCntArr(n))) - refAtTrg);
            write(l, string'("  "));
        end loop;
        writeline(output, l);
    end loop;

    write(l, string'("done"));
    writeline(output, l);

    wait;
end process;

end Behavioral;
