----------------------------------------------------------------------------------
-- PBR Clock Board
--
-- Module Name: synchronizers
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

library xpm;
use xpm.vcomponents.all;

entity synchronizers is
generic(
    zynqNum    : integer;
    ppsNum     : integer;
    extTrgNum  : integer
);
port(
    clk        : in  std_logic;
    extGtuIn   : in  std_logic;
    trgIn      : in  std_logic_vector(zynqNum-1 downto 0);
    busyIn     : in  std_logic_vector(zynqNum-1 downto 0);
    ppsIn      : in  std_logic_vector(ppsNum-1 downto 0);
    extTrgIn   : in  std_logic_vector(extTrgNum-1 downto 0);
    extGtuSync : out std_logic;
    trgSync    : out std_logic_vector(zynqNum-1 downto 0);
    busySync   : out std_logic_vector(zynqNum-1 downto 0);
    ppsSync    : out std_logic_vector(ppsNum-1 downto 0);
    extTrgSync : out std_logic_vector(extTrgNum-1 downto 0)
);
end synchronizers;

architecture Behavioral of synchronizers is

signal extGtuInSig,
       extGtuSyncSig : std_logic_vector(0 downto 0);

begin

extGtuInSig(0) <= extGtuIn;

extGtuSync     <= extGtuSyncSig(0);

extGtuSyncInst: xpm_cdc_array_single
generic map (
    DEST_SYNC_FF   => 2,
    INIT_SYNC_FF   => 0,
    SIM_ASSERT_CHK => 0,
    SRC_INPUT_REG  => 0,
    WIDTH          => 1
)
port map (
    src_clk  => '0',
    dest_clk => clk,
    src_in   => extGtuInSig,
    dest_out => extGtuSyncSig
);

trgSyncInst: xpm_cdc_array_single
generic map (
    DEST_SYNC_FF   => 2,
    INIT_SYNC_FF   => 0,
    SIM_ASSERT_CHK => 0,
    SRC_INPUT_REG  => 0,
    WIDTH          => zynqNum
)
port map (
    src_clk  => '0',
    dest_clk => clk,
    src_in   => trgIn,
    dest_out => trgSync
);

busySyncInst: xpm_cdc_array_single
generic map (
    DEST_SYNC_FF   => 2,
    INIT_SYNC_FF   => 0,
    SIM_ASSERT_CHK => 0,
    SRC_INPUT_REG  => 0,
    WIDTH          => zynqNum
)
port map (
    src_clk  => '0',
    dest_clk => clk,
    src_in   => busyIn,
    dest_out => busySync
);

ppsSyncInst: xpm_cdc_array_single
generic map (
    DEST_SYNC_FF   => 2,
    INIT_SYNC_FF   => 0,
    SIM_ASSERT_CHK => 0,
    SRC_INPUT_REG  => 0,
    WIDTH          => ppsNum
)
port map (
    src_clk  => '0',
    dest_clk => clk,
    src_in   => ppsIn,
    dest_out => ppsSync
);

extTrgSyncInst: xpm_cdc_array_single
generic map (
    DEST_SYNC_FF   => 2,
    INIT_SYNC_FF   => 0,
    SIM_ASSERT_CHK => 0,
    SRC_INPUT_REG  => 0,
    WIDTH          => extTrgNum
)
port map (
    src_clk  => '0',
    dest_clk => clk,
    src_in   => extTrgIn,
    dest_out => extTrgSync
);

end Behavioral;