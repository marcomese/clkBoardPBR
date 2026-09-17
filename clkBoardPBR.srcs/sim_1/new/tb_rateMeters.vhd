library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_rateMeters is
end tb_rateMeters;

architecture Behavioral of tb_rateMeters is

constant clkPeriod  : time := 10 ns;
constant sig0Period : time := 1 us;
constant sig1Period : time := 5 us;
constant sig2Period : time := 3.7 us;

constant sigNum  : positive := 3;
constant rateLen : positive := 32;
constant clkFreq : positive := 100_000_000;

signal clk      : std_logic := '1';
signal rst      : std_logic := '1';
signal sigIn    : std_logic_vector(sigNum-1 downto 0) := (others => '0');
signal sigEdges : std_logic_vector(sigNum-1 downto 0) := (others => '0');
signal rateOut  : std_logic_vector((sigNum*rateLen)-1 downto 0) := (others => '0');

begin

rst <= '0' after clkPeriod*5;

clk <= not clk after clkPeriod/2;

sigIn(0) <= not sigIn(0) after sig0Period/2;
sigIn(1) <= not sigIn(1) after sig1Period/2;
sigIn(2) <= not sigIn(2) after sig2Period/2;

edgesInst: entity work.edgeDetectors
generic map(
    sigRst => 0,
    sigNum => sigNum
)
port map(
    clk    => clk,
    rst    => rst,
    sigIn  => sigIn,
    sigOut => sigEdges
);

rateMetersInst: entity work.rateMeters
generic map(
    sigNum  => sigNum,
    rateLen => rateLen,
    clkFreq => clkFreq
)
port map(
    clk     => clk,
    rst     => rst,
    sigIn   => sigEdges,
    rateOut => rateOut
);

end Behavioral;
