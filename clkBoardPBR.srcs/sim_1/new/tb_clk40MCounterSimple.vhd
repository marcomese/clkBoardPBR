library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.vcomponents.all;

entity tb_clk40MCounterSimple is
end tb_clk40MCounterSimple;

architecture Behavioral of tb_clk40MCounterSimple is

constant clkPeriod    : time := 10 ns;
constant clk40MPeriod : time := 25 ns;
constant trgDelay     : integer := 4;

signal clk       : std_logic := '1';
signal clk40M    : std_logic := '1';
signal clk40MSig : std_logic;
signal rst       : std_logic := '1';
signal enable    : std_logic := '0';
signal clear     : std_logic := '0';
signal trgIn     : std_logic := '0';
signal ready     : std_logic;
signal clk40MCnt : std_logic_vector(31 downto 0);

-- number of 40 MHz cycles actually emitted by the BUFGCE, to compare with clk40MCnt
signal refCnt    : integer := 0;

begin

stimProc: process
begin
    wait for clkPeriod*5;
    rst <= '0';
    wait for clkPeriod*10;

    enable <= '1';

    wait for clkPeriod*39;
    trgIn <= '1', '0' after clkPeriod+100 ps;

    wait for clkPeriod*100;
    trgIn <= '1', '0' after clkPeriod+100 ps;

    -- counters reset while the run is going on
    wait for clkPeriod*50;
    clear <= '1', '0' after clkPeriod+100 ps;

    wait for clkPeriod*50;
    trgIn <= '1', '0' after clkPeriod+100 ps;

    -- stop and restart the run: the counter must start again from zero
    wait for clkPeriod*50;
    enable <= '0';

    wait for clkPeriod*50;
    enable <= '1';

    wait for clkPeriod*60;
    trgIn <= '1', '0' after clkPeriod+100 ps;

    wait;
end process;

clk    <= not clk after clkPeriod/2;

clk40M <= not clk40M after clk40MPeriod/2;

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

clk40MCounterInst: entity work.clk40MCounter
generic map(
    trgDelay => trgDelay
)
port map(
    clk       => clk,
    clk40M    => clk40MSig,
    rst       => rst,
    enable    => enable,
    clear     => clear,
    trgIn     => trgIn,
    ready     => ready,
    clk40MCnt => clk40MCnt
);

end Behavioral;
