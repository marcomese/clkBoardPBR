----------------------------------------------------------------------------------
-- PBR Clock Board
--
-- Module Name: clk40MCtrl
-- Create Date: 28.08.2026 14:46:50
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

library UNISIM;
use UNISIM.vcomponents.all;

entity clk40MCtrl is
generic(
    trgDelay  : integer
);
port(
    clk           : in  std_logic;
    clkSmpl       : in  std_logic;
    clk40M        : in  std_logic;
    extClk40M     : in  std_logic;
    rst           : in  std_logic;
    clk40MSel     : in  std_logic;
    enable        : in  std_logic;
    clear         : in  std_logic;
    trgIn         : in  std_logic;
    ready         : out std_logic;
    clk40MOut     : out std_logic;
    clk40MCnt     : out std_logic_vector(31 downto 0)
);
end clk40MCtrl;

architecture Behavioral of clk40MCtrl is

signal clk40MSig,
       clk40MSelReg,
       notClk40MSelReg,
       clk40MSmpl      : std_logic;

begin

clk40MOut <= clk40MSig;

clk40MSelProc: process(clk)
begin
    if rising_edge(clk) then
        clk40MSelReg    <= clk40MSel;
        notClk40MSelReg <= not clk40MSel;
    end if;
end process;

clk40MCtrlInst: BUFGCTRL
generic map(
    SIM_DEVICE   => "7SERIES",
    PRESELECT_I0 => TRUE,
    INIT_OUT     => 0
)
port map(
    I0      => extClk40M,
    I1      => clk40M,
    S0      => notClk40MSelReg,
    S1      => clk40MSelReg,
    CE0     => '1',
    CE1     => enable,
    IGNORE0 => '1',
    IGNORE1 => '1',
    O       => clk40MSig
);

clk40MSmplInst: xpm_cdc_single
generic map (
    DEST_SYNC_FF   => 2,
    INIT_SYNC_FF   => 1,
    SIM_ASSERT_CHK => 0,
    SRC_INPUT_REG  => 0
)
port map (
    src_clk  => '0',
    dest_clk => clkSmpl,
    src_in   => clk40MSig,
    dest_out => clk40MSmpl
);

clk40MCntInst: entity work.clk40MCounter
generic map(
    trgDelay  => trgDelay
)
port map(
    clk       => clk,
    clkSmpl   => clkSmpl,
    rst       => rst,
    clk40M    => clk40MSmpl,
    enable    => enable,
    clear     => clear,
    trgIn     => trgIn,
    ready     => ready,
    clk40MCnt => clk40MCnt
);

end Behavioral;