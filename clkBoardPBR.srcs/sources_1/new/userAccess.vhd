----------------------------------------------------------------------------------
-- PBR Clock Board
--
-- Module Name: userAccess
-- Create Date: 10.09.2026 17:1:45
-- Target Devices: Zynq 7000 xc7z020clg484-2
--
-- Created by: Marco Mese
--
-- Revision:
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity userAccess is
port(
    clk          : in  std_logic;
    usrAccessOut : out std_logic_vector(31 downto 0)
);
end userAccess;

architecture Behavioral of userAccess is

signal usrAccessData : std_logic_vector(31 downto 0);

begin

usrAccessInst: USR_ACCESSE2
port map(
    CFGCLK    => open,
    DATA      => usrAccessData,
    DATAVALID => open
);

usrAccessProc: process(clk)
begin
    if rising_edge(clk) then
        usrAccessOut <= usrAccessData;
    end if;
end process;

end Behavioral;