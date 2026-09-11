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

library xpm;
use xpm.vcomponents.all;

entity userAccess is
port(
    clk          : in  std_logic;
    usrAccessOut : out std_logic_vector(31 downto 0)
);
end userAccess;

architecture Behavioral of userAccess is

signal usrAccessData : std_logic_vector(31 downto 0);
signal usrAccessVal,
       usrAccessSync : std_logic;
signal usrAccessFF   : std_logic_vector(31 downto 0) := (others => '0');

begin

usrAccessOut <= usrAccessFF;

usrAccessInst: USR_ACCESSE2
port map(
    CFGCLK    => open,
    DATA      => usrAccessData,
    DATAVALID => usrAccessVal
);

usrAccessValSyncInst: xpm_cdc_single
generic map (
    DEST_SYNC_FF   => 2,
    INIT_SYNC_FF   => 1,
    SIM_ASSERT_CHK => 0,
    SRC_INPUT_REG  => 0
)
port map (
    src_clk  => '0',
    dest_clk => clk,
    src_in   => usrAccessVal,
    dest_out => usrAccessSync
);

usrAccessProc: process(clk)
begin
    if rising_edge(clk) then
        if usrAccessSync = '1' then
            usrAccessFF <= usrAccessData;
        end if;
    end if;
end process;

end Behavioral;