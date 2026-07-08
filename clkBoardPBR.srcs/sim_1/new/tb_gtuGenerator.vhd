library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity tb_gtuGenerator is
end tb_gtuGenerator;

architecture Behavioral of tb_gtuGenerator is

constant clkPer    : time := 10 ns;
constant clkPeriod : integer := 10;
constant gtuPeriod : integer := 1050;

signal clk,
       rst,
       gtuClock,
       gtuTick  : std_logic := '0';

begin

rst <= '1', '0' after clkPer*5;

clk <= not clk after clkPer/2;

gtuGeneratorInst: entity work.gtuGenerator
generic map(
    clkPeriodNs => clkPeriod,
    gtuPeriodNs => gtuPeriod
)
port map(
    clk      => clk,
    rst      => rst,
    gtuClock => gtuClock,
    gtuTick  => gtuTick
);

end Behavioral;
