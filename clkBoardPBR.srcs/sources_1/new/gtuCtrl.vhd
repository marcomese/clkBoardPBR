----------------------------------------------------------------------------------
-- PBR Clock Board
--
-- Module Name: gtuCtrl
-- Create Date: 10.07.2026 15:11:19
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

entity gtuCtrl is
port(
    clk         : in  std_logic;
    rst         : in  std_logic;
    enable      : in  std_logic;
    gtuSel      : in  std_logic;
    extGtuClock : in  std_logic;
    extGtuTick  : in  std_logic;
    gtuPeriod   : in  std_logic_vector(15 downto 0);
    gtuClockOut : out std_logic;
    gtuTickOut  : out std_logic
);
end gtuCtrl;

architecture Behavioral of gtuCtrl is

signal gtuClock,
       gtuTick   : std_logic;

begin

gtuSelProc: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            gtuClockOut <= '0';
            gtuTickOut  <= '0';
        else
            if gtuSel = '1' then
                gtuClockOut <= gtuClock;
                gtuTickOut  <= gtuTick;
            else
                gtuClockOut <= extGtuClock;
                gtuTickOut  <= extGtuTick;
            end if;
        end if;
    end if;
end process;

gtuGenInst: entity work.gtuGenerator
port map(
    clk       => clk,
    rst       => rst,
    enable    => enable,
    gtuPeriod => gtuPeriod,
    gtuClock  => gtuClock,
    gtuTick   => gtuTick
);

end Behavioral;
