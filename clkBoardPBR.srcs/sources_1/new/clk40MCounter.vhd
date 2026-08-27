----------------------------------------------------------------------------------
-- PBR Clock Board
--
-- Module Name: clk40MCounter
-- Create Date: 27.08.2026 14:45:46
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

entity clk40MCounter is
generic(
    trgDelay  : integer
);
port(
    clk       : in  std_logic;
    clk40M    : in  std_logic;
    rst       : in  std_logic;
    enable    : in  std_logic;
    clear     : in  std_logic;
    trgIn     : in  std_logic;
    ready     : out std_logic;
    clk40MCnt : out std_logic_vector(31 downto 0)
);
end clk40MCounter;

architecture Behavioral of clk40MCounter is

signal clear40M      : std_logic;

signal trgDelBuf     : std_logic_vector(trgDelay-1 downto 0);

signal clk40MCounter : unsigned(31 downto 0);

signal clk40MCntSync : std_logic_vector(31 downto 0);

begin

ready <= trgDelBuf(0);

clearSyncInst: xpm_cdc_pulse
generic map(
    DEST_SYNC_FF   => 2,
    INIT_SYNC_FF   => 1,
    REG_OUTPUT     => 0,
    RST_USED       => 0,
    SIM_ASSERT_CHK => 0
)
port map(
    src_clk    => clk,
    src_rst    => '0',
    dest_clk   => clk40M,
    dest_rst   => '0',
    src_pulse  => clear,
    dest_pulse => clear40M
);

clk40MCntInst: process(clk40M, enable)
begin
    if enable = '0' then
        clk40MCounter <= (others => '0');
    else
        if rising_edge(clk40M) then
            if clear40M = '1' then
                clk40MCounter <= (others => '0');
            else
                clk40MCounter <= clk40MCounter + 1;
            end if;
        end if;
    end if;
end process;

clk40MCDCInst: xpm_cdc_gray
generic map (
    DEST_SYNC_FF          => 2,
    INIT_SYNC_FF          => 1,
    REG_OUTPUT            => 0,
    SIM_ASSERT_CHK        => 0,
    SIM_LOSSLESS_GRAY_CHK => 0,
    WIDTH                 => 32
)
port map (
    src_clk      => clk40M,
    src_in_bin   => std_logic_vector(clk40MCounter),
    dest_clk     => clk,
    dest_out_bin => clk40MCntSync
);

trgDelProc: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            trgDelBuf <= (others => '0');
        else
            trgDelBuf <= trgIn & trgDelBuf(trgDelBuf'left downto 1);
        end if;
    end if;
end process;

clk40MRegInst: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' or clear = '1' then
            clk40MCnt <= (others => '0');
        elsif trgDelBuf(0) = '1' then
            clk40MCnt <= clk40MCntSync;
        end if;
    end if;
end process;

end Behavioral;