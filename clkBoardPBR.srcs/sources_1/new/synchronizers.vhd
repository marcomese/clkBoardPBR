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
    clkSmpl    : in  std_logic;
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

signal trgSampled,
       busySampled   : std_logic_vector(zynqNum-1 downto 0);

signal ppsSampled    : std_logic_vector(ppsNum-1 downto 0);

signal extTrgSampled : std_logic_vector(extTrgNum-1 downto 0);

signal extGtuSampled : std_logic;

begin

extGtuSmplInst: xpm_cdc_single
generic map (
    DEST_SYNC_FF   => 2,
    INIT_SYNC_FF   => 1,
    SIM_ASSERT_CHK => 0,
    SRC_INPUT_REG  => 0
)
port map (
    src_clk  => '0',
    dest_clk => clkSmpl,
    src_in   => extGtuIn,
    dest_out => extGtuSampled
);

extGtuSyncInst: xpm_cdc_single
generic map (
    DEST_SYNC_FF   => 2,
    INIT_SYNC_FF   => 1,
    SIM_ASSERT_CHK => 0,
    SRC_INPUT_REG  => 0
)
port map (
    src_clk  => clkSmpl,
    dest_clk => clk,
    src_in   => extGtuSampled,
    dest_out => extGtuSync
);

trgSmplInst: xpm_cdc_array_single
generic map (
    DEST_SYNC_FF   => 2,
    INIT_SYNC_FF   => 1,
    SIM_ASSERT_CHK => 0,
    SRC_INPUT_REG  => 0,
    WIDTH          => zynqNum
)
port map (
    src_clk  => '0',
    dest_clk => clkSmpl,
    src_in   => trgIn,
    dest_out => trgSampled
);

trgSyncGen: for i in 0 to zynqNum-1 generate
begin
    trgSyncInst: xpm_cdc_pulse
    generic map(
        DEST_SYNC_FF   => 2,
        INIT_SYNC_FF   => 1,
        REG_OUTPUT     => 0,
        RST_USED       => 0,
        SIM_ASSERT_CHK => 0
    )
    port map(
        src_clk    => clkSmpl,
        src_rst    => '0',
        dest_clk   => clk,
        dest_rst   => '0',
        src_pulse  => trgSampled(i),
        dest_pulse => trgSync(i)
    );
end generate;

busySmplInst: xpm_cdc_array_single
generic map (
    DEST_SYNC_FF   => 2,
    INIT_SYNC_FF   => 1,
    SIM_ASSERT_CHK => 0,
    SRC_INPUT_REG  => 0,
    WIDTH          => zynqNum
)
port map (
    src_clk  => '0',
    dest_clk => clkSmpl,
    src_in   => busyIn,
    dest_out => busySampled
);

busySyncInst: xpm_cdc_array_single
generic map (
    DEST_SYNC_FF   => 2,
    INIT_SYNC_FF   => 1,
    SIM_ASSERT_CHK => 0,
    SRC_INPUT_REG  => 0,
    WIDTH          => zynqNum
)
port map (
    src_clk  => clkSmpl,
    dest_clk => clk,
    src_in   => busySampled,
    dest_out => busySync
);

ppsSyncInst: xpm_cdc_array_single
generic map (
    DEST_SYNC_FF   => 2,
    INIT_SYNC_FF   => 1,
    SIM_ASSERT_CHK => 0,
    SRC_INPUT_REG  => 0,
    WIDTH          => ppsNum
)
port map (
    src_clk  => '0',
    dest_clk => clkSmpl,
    src_in   => ppsIn,
    dest_out => ppsSampled
);

ppsSyncGen: for i in 0 to ppsNum-1 generate
begin
    ppsSyncInst: xpm_cdc_pulse
    generic map(
        DEST_SYNC_FF   => 2,
        INIT_SYNC_FF   => 1,
        REG_OUTPUT     => 0,
        RST_USED       => 0,
        SIM_ASSERT_CHK => 0
    )
    port map(
        src_clk    => clkSmpl,
        src_rst    => '0',
        dest_clk   => clk,
        dest_rst   => '0',
        src_pulse  => ppsSampled(i),
        dest_pulse => ppsSync(i)
    );
end generate;

extTrgSyncInst: xpm_cdc_array_single
generic map (
    DEST_SYNC_FF   => 2,
    INIT_SYNC_FF   => 1,
    SIM_ASSERT_CHK => 0,
    SRC_INPUT_REG  => 0,
    WIDTH          => extTrgNum
)
port map (
    src_clk  => '0',
    dest_clk => clkSmpl,
    src_in   => extTrgIn,
    dest_out => extTrgSampled
);

extTrgSyncGen: for i in 0 to extTrgNum-1 generate
begin
    extTrgSyncInst: xpm_cdc_pulse
    generic map(
        DEST_SYNC_FF   => 2,
        INIT_SYNC_FF   => 1,
        REG_OUTPUT     => 0,
        RST_USED       => 0,
        SIM_ASSERT_CHK => 0
    )
    port map(
        src_clk    => clkSmpl,
        src_rst    => '0',
        dest_clk   => clk,
        dest_rst   => '0',
        src_pulse  => extTrgSampled(i),
        dest_pulse => extTrgSync(i)
    );
end generate;

end Behavioral;