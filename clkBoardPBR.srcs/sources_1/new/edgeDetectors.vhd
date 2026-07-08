----------------------------------------------------------------------------------
-- PBR Clock Board
--
-- Module Name: edgeDetectors
-- Create Date: 01.07.2026 13:09:33
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
use work.utilsPkg.all;

entity edgeDetectors is
generic(
    sigRst      : integer;
    sigNum      : positive
);
port(
    clk         : in  std_logic;
    rst         : in  std_logic;
    sigIn       : in  std_logic_vector(sigNum-1 downto 0);
    sigOut      : out std_logic_vector(sigNum-1 downto 0)
);
end edgeDetectors;

architecture Behavioral of edgeDetectors is

signal sigFF : std_logic_vector(sigNum-1 downto 0);

begin

edgeDetProc: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            sigFF  <= std_logic_vector(to_unsigned(sigRst, sigFF'length));
            sigOut <= (others => '0');
        else
            sigFF  <= sigIn;
            sigOut <= sigIn and not sigFF;
        end if;
    end if;
end process;

end Behavioral;
