library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_dataBuilder is
end tb_dataBuilder;

architecture Behavioral of tb_dataBuilder is

constant clkPeriod : time := 10 ns;
constant trgNum    : integer := 4;
constant dataWords : integer := 6;

signal clk,
       rst       : std_logic := '1';

signal evtRdy,
       gtuRdy,
       trgFRdy,
       aDTRdy,
       dataRdy   : std_logic := '0';

signal evtNum,
       gtuCount,
       aliveT,
       deadT,
       statusReg : std_logic_vector(31 downto 0) := (others => '0');
signal trgFlag   : std_logic_vector(trgNum-1 downto 0) := (others => '0');
signal dataOut   : std_logic_vector(32*dataWords-1 downto 0) := (others => '0');

begin

stimProc: process
begin
-- data n 1
    wait for clkPeriod*10;

    evtNum   <= std_logic_vector(to_unsigned(13, evtNum'length));
    evtRdy   <= '1', '0' after clkPeriod+100 ps;

    wait for clkPeriod*2;

    gtuCount <= std_logic_vector(to_unsigned(134, gtuCount'length));
    gtuRdy   <= '1', '0' after clkPeriod+100 ps;

    wait for clkPeriod*10;

    trgFlag  <= "0101";
    trgFRdy  <= '1', '0' after clkPeriod+100 ps;

    wait for clkPeriod*3;
    
    aliveT   <= std_logic_vector(to_unsigned(1000, aliveT'length));
    deadT    <= std_logic_vector(to_unsigned(45, deadT'length));
    aDTRdy   <= '1', '0' after clkPeriod+100 ps;

-- data n 2

    wait for clkPeriod*10;

    evtNum   <= std_logic_vector(to_unsigned(3, evtNum'length));
    evtRdy   <= '1', '0' after clkPeriod+100 ps;

    wait for clkPeriod*2;

    gtuCount <= std_logic_vector(to_unsigned(14, gtuCount'length));
    gtuRdy   <= '1', '0' after clkPeriod+100 ps;

    wait for clkPeriod*10;

    trgFlag  <= "0101";
    trgFRdy  <= '1', '0' after clkPeriod+100 ps;

    wait for clkPeriod*3;
    
    aliveT   <= std_logic_vector(to_unsigned(1030, aliveT'length));
    deadT    <= std_logic_vector(to_unsigned(435, deadT'length));
    aDTRdy   <= '1', '0' after clkPeriod+100 ps;

-- simultaneous

    wait for clkPeriod*10;

    evtNum   <= std_logic_vector(to_unsigned(13, evtNum'length));
    evtRdy   <= '1', '0' after clkPeriod+100 ps;

    gtuCount <= std_logic_vector(to_unsigned(134, gtuCount'length));
    gtuRdy   <= '1', '0' after clkPeriod+100 ps;

    trgFlag  <= "0101";
    trgFRdy  <= '1', '0' after clkPeriod+100 ps;
    
    aliveT   <= std_logic_vector(to_unsigned(1000, aliveT'length));
    deadT    <= std_logic_vector(to_unsigned(45, deadT'length));
    aDTRdy   <= '1', '0' after clkPeriod+100 ps;

    wait;
end process;

rst <= '0' after clkPeriod*5;

clk <= not clk after clkPeriod/2;

dataBuilderInst: entity work.dataBuilder
generic map(
    trgNum    => trgNum,
    dataWords => dataWords
)
port map(
    clk       => clk,
    rst       => rst,
    evtNum    => evtNum,
    evtRdy    => evtRdy,
    gtuCount  => gtuCount,
    gtuRdy    => gtuRdy,
    trgFlag   => trgFlag,
    trgFRdy   => trgFRdy,
    aliveT    => aliveT,
    deadT     => deadT,
    aDTRdy    => aDTRdy,
    statusReg => statusReg,
    dataRdy   => dataRdy,
    dataOut   => dataOut
);

end Behavioral;