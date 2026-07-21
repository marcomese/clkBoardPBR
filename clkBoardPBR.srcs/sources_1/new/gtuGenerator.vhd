----------------------------------------------------------------------------------
-- PBR Clock Board
--
-- Module Name: gtuGenerator
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

entity gtuGenerator is
generic(
    clkPeriodNs : positive; -- clock period in nanoseconds
    gtuPeriodNs : positive  -- gtu period in nanoseconds
);
port(
    clk      : in  std_logic;
    rst      : in  std_logic;
    enable   : in  std_logic;
    gtuClock : out std_logic;
    gtuTick  : out std_logic
);
end gtuGenerator;

architecture Behavioral of gtuGenerator is

constant clkPeriodReal : real := real(clkPeriodNs)*1.0e-9;
constant gtuPeriodReal : real := real(gtuPeriodNs)*1.0e-9;

begin

glkGenInst: entity work.clockGenerator
generic map(
    clkInPeriod  => clkPeriodReal,
    clkOutPeriod => gtuPeriodReal
)
port map(
    clk            => clk,
    rst            => rst,
    enable         => enable,
    clkOut         => gtuClock,
    clkRisingEdge  => gtuTick,
    clkFallingEdge => open
);

end Behavioral;
