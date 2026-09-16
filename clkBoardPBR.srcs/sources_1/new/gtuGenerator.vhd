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
port(
    clk       : in  std_logic;
    rst       : in  std_logic;
    enable    : in  std_logic;
    gtuPeriod : in std_logic_vector(15 downto 0);
    gtuClock  : out std_logic;
    gtuTick   : out std_logic
);
end gtuGenerator;

architecture Behavioral of gtuGenerator is

begin

glkGenInst: entity work.clockGenerator
generic map(
    periodLen    => gtuPeriod'length
)
port map(
    clk            => clk,
    rst            => rst,
    enable         => enable,
    period         => gtuPeriod,
    clkOut         => gtuClock,
    clkRisingEdge  => gtuTick,
    clkFallingEdge => open
);

end Behavioral;
