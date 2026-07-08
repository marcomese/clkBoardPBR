----------------------------------------------------------------------------------
-- Clock Generator
--
-- Module Name: clockGenerator
-- Create Date: 22.05.2026 15:19:25
-- Target Devices: Zynq 7000 xc7z020clg484-2
--
-- Created by: Marco Mese
--
-- Revision:
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use work.utilsPkg.all;

entity clockGenerator is
generic(
    clkInPeriod    : real;
    clkOutPeriod   : real
);
port(
    clk            : in  std_logic;
    rst            : in  std_logic;
    clkOut         : out std_logic;
    clkRisingEdge  : out std_logic;
    clkFallingEdge : out std_logic
);
end clockGenerator;

architecture Behavioral of clockGenerator is

constant cntMax : integer := integer(clkOutPeriod/clkInPeriod);
constant cntHlf : integer := integer(ceil(real(cntMax)/2.0));
constant cntLen : integer :=  bitsNum(cntMax);

signal clkSig : std_logic;

signal clkCnt : unsigned(cntLen-1 downto 0);

begin

clkOut <= clkSig;

clkCntInst: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            clkCnt         <= to_unsigned(cntMax-1, clkCnt'length);
            clkSig         <= '0';
            clkRisingEdge  <= '0';
            clkFallingEdge <= '0';
        elsif clkCnt = 0 then
            clkCnt         <= to_unsigned(cntMax-1, clkCnt'length);
            clkSig         <= '1';
            clkRisingEdge  <= not clkSig;
        elsif clkCnt = cntHlf then
            clkCnt         <= clkCnt - 1;
            clkSig         <= '0';
            clkFallingEdge <= clkSig;
        else
            clkCnt         <= clkCnt - 1;
            clkRisingEdge  <= '0';
            clkFallingEdge <= '0';
        end if;
    end if;
end process;

end Behavioral;
