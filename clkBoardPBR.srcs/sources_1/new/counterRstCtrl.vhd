----------------------------------------------------------------------------------
-- PBR Clock Board
--
-- Module Name: counterRstCtrl
-- Create Date: 27.05.2026 13:08:12
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

entity counterRstCtrl is
port(
    clk        : in  std_logic;
    rst        : in  std_logic;
    rstAll     : in  std_logic;
    rstGtu     : in  std_logic;
    rstTrgN    : in  std_logic;
    rstEvtN    : in  std_logic;
    rstFromRun : in  std_logic;
    rstGtuOut  : out std_logic;
    rstTrgNOut : out std_logic;
    rstEvtNOut : out std_logic
);
end counterRstCtrl;

architecture Behavioral of counterRstCtrl is

begin

rstProc: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            rstGtuOut  <= '0';
            rstTrgNOut <= '0';
            rstEvtNOut <= '0';
        else
            rstGtuOut  <= rstAll or rstGtu;
            rstTrgNOut <= rstAll or rstFromRun or rstTrgN;
            rstEvtNOut <= rstAll or rstFromRun or rstEvtN;
        end if;
    end if;
end process;

end Behavioral;