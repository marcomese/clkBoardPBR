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

library xpm;
use xpm.vcomponents.all;

entity gtuCtrl is
port(
    clk         : in  std_logic;
    clkSmpl     : in  std_logic;
    rst         : in  std_logic;
    enable      : in  std_logic;
    gtuSel      : in  std_logic;
    extGtuClock : in  std_logic;
    gtuPeriod   : in  std_logic_vector(15 downto 0);
    gtuClockOut : out std_logic;
    gtuTickOut  : out std_logic
);
end gtuCtrl;

architecture Behavioral of gtuCtrl is

signal rstSmpl,
       enableSmpl,
       gtuSelSmpl,
       gtuClock,
       gtuClockSmpl,
       gtuClockFF,
       gtuEdgeSmpl   : std_logic;

signal gtuPeriodSmpl : std_logic_vector(15 downto 0);

begin

gtuClockOut <= gtuClockSmpl;

rstSmplCDC: xpm_cdc_sync_rst
generic map(
    DEST_SYNC_FF   => 2,
    INIT           => 1,
    INIT_SYNC_FF   => 0,
    SIM_ASSERT_CHK => 0
)
port map(
    src_rst  => rst,
    dest_clk => clkSmpl,
    dest_rst => rstSmpl
);

enableSmplCDC: xpm_cdc_single
generic map(
    DEST_SYNC_FF   => 2,
    INIT_SYNC_FF   => 1,
    SIM_ASSERT_CHK => 0,
    SRC_INPUT_REG  => 0
)
port map(
    src_clk  => clk,
    src_in   => enable,
    dest_clk => clkSmpl,
    dest_out => enableSmpl
);

gtuSelSmplCDC: xpm_cdc_single
generic map(
    DEST_SYNC_FF   => 2,
    INIT_SYNC_FF   => 1,
    SIM_ASSERT_CHK => 0,
    SRC_INPUT_REG  => 0
)
port map(
    src_clk  => clk,
    src_in   => gtuSel,
    dest_clk => clkSmpl,
    dest_out => gtuSelSmpl
);

gtuPeriodCDC: xpm_cdc_array_single
generic map(
    DEST_SYNC_FF   => 2,
    INIT_SYNC_FF   => 1,
    SIM_ASSERT_CHK => 0,
    SRC_INPUT_REG  => 0,
    WIDTH          => 16
)
port map(
    src_clk  => clk,
    src_in   => gtuPeriod,
    dest_clk => clkSmpl,
    dest_out => gtuPeriodSmpl
);

gtuSelClkOutProc: process(clkSmpl)
begin
    if rising_edge(clkSmpl) then
        if rstSmpl = '1' then
            gtuClockSmpl <= '0';
            gtuClockFF   <= '0';
            gtuEdgeSmpl  <= '0';
        else
            if gtuSelSmpl = '1' then
                gtuClockSmpl <= gtuClock;
            else
                gtuClockSmpl <= extGtuClock;
            end if;

            gtuClockFF <= gtuClockSmpl;
            gtuEdgeSmpl <= gtuClockSmpl and not gtuClockFF;
        end if;
    end if;
end process;

gtuTickCDC: xpm_cdc_pulse
generic map(
    DEST_SYNC_FF   => 2,
    INIT_SYNC_FF   => 1,
    REG_OUTPUT     => 1,
    RST_USED       => 1,
    SIM_ASSERT_CHK => 0
)
port map(
    src_clk    => clkSmpl,
    src_rst    => rstSmpl,
    src_pulse  => gtuEdgeSmpl,
    dest_clk   => clk,
    dest_rst   => rst,
    dest_pulse => gtuTickOut
);

gtuGenInst: entity work.gtuGenerator
port map(
    clk       => clkSmpl,
    rst       => rstSmpl,
    enable    => enableSmpl,
    gtuPeriod => gtuPeriodSmpl,
    gtuClock  => gtuClock
);

end Behavioral;