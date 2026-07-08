---------------------------------------------------------------------------------
-- Company: INFN Napoli
--
-- File: command_decoder.vhd
-- File history:
--      0: 2026_05_22: adapted for PBR experiment (M. Mese)
-- 
-- Description: 
--
-- command_decoder for Clock Board (EUSO-SPB2/PBR)
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity command_decoder is
generic(
    extTrgNum : positive;
    zynqNum   : positive;
    ppsNum    : positive
);
port(
    clk                : in  std_logic;
    rst                : in  std_logic;
    command_in         : in  std_logic_vector(31 downto 0);
    data_received      : in  std_logic;
    fsmState           : in  std_logic_vector(3 downto 0);
    trigger_flag       : in  std_logic_vector(zynqNum-1 downto 0);
    ppsPres            : in  std_logic_vector(ppsNum-1 downto 0);
    fifoFull           : in  std_logic;
    busy               : in  std_logic_vector(zynqNum-1 downto 0);
    runCtrlBusy        : in  std_logic;
    plToAxiSBusy       : in  std_logic;
    -- level outputs
    run                : out std_logic;
    cmd_busy           : out std_logic;
    zynq_en            : out std_logic_vector(zynqNum-1 downto 0);
    pps_en             : out std_logic_vector(ppsNum-1 downto 0);
    pps_auto           : out std_logic;
    pps_trg            : out std_logic;
    ext_trg_en         : out std_logic_vector(extTrgNum-1 downto 0);
    -- pulse outputs
    trg_command        : out std_logic;
    configure_GPS      : out std_logic;
    reset_GTU_count    : out std_logic;
    reset_l1_nr        : out std_logic;
    reset_evt_nr       : out std_logic;
    reset_all_counters : out std_logic;
    send_nack          : out std_logic;
    -- status register
    status_register    : out std_logic_vector(31 downto 0)
);
end command_decoder;

architecture Behavioral of command_decoder is

constant MSG_START_RUN       : std_logic_vector(31 downto 0) := X"FFFFFFFF";
constant MSG_STOP_RUN        : std_logic_vector(31 downto 0) := X"AAAAAAAA";
constant MSG_RELEASE_BUSY    : std_logic_vector(31 downto 0) := X"55555555";
constant MSG_SET_BUSY        : std_logic_vector(31 downto 0) := X"CCCCCCCC";
constant MSG_TRIGGER         : std_logic_vector(31 downto 0) := X"33333333";
constant MSG_CONFIGURE_GPS   : std_logic_vector(31 downto 0) := X"99999999";
constant MSG_GPS1_ON         : std_logic_vector(31 downto 0) := X"F0F0F0F0";
constant MSG_GPS2_ON         : std_logic_vector(31 downto 0) := X"0F0F0F0F";
constant MSG_CLKPPS_ON       : std_logic_vector(31 downto 0) := X"33CCCC33";
constant MSG_RESET_GTU_COUNT : std_logic_vector(31 downto 0) := X"5A5A5A5A";
constant MSG_RESET_L1_COUNT  : std_logic_vector(31 downto 0) := X"A5A5A5A5";
constant MSG_RESET_EVT_COUNT : std_logic_vector(31 downto 0) := X"3C3C3C3C";
constant MSG_RESET_ALL_COUNT : std_logic_vector(31 downto 0) := X"C3C3C3C3";
constant MSG_PPS_TRG_ON      : std_logic_vector(31 downto 0) := X"96969696";
constant MSG_PPS_TRG_OFF     : std_logic_vector(31 downto 0) := X"69696969";
constant MSG_MASK_EXT_TRG0   : std_logic_vector(31 downto 0) := X"FF00FF00";
constant MSG_UNMASK_EXT_TRG0 : std_logic_vector(31 downto 0) := X"00FF00FF";
constant MSG_MASK_EXT_TRG1   : std_logic_vector(31 downto 0) := X"FF0000FF";
constant MSG_UNMASK_EXT_TRG1 : std_logic_vector(31 downto 0) := X"00FFFF00";
constant MSG_NO_ZYNQ0        : std_logic_vector(31 downto 0) := X"33CC33CC";
constant MSG_NO_ZYNQ1        : std_logic_vector(31 downto 0) := X"CC33CC33";
constant MSG_NO_ZYNQ2        : std_logic_vector(31 downto 0) := X"99669966";
constant MSG_NO_ZYNQ3        : std_logic_vector(31 downto 0) := X"66996699";
constant MSG_ZYNQ0_ON        : std_logic_vector(31 downto 0) := X"0FF00FF0";
constant MSG_ZYNQ1_ON        : std_logic_vector(31 downto 0) := X"F00FF00F";
constant MSG_ZYNQ2_ON        : std_logic_vector(31 downto 0) := X"A55AA55A";
constant MSG_ZYNQ3_ON        : std_logic_vector(31 downto 0) := X"5AA55AA5";
constant MSG_GPS1_NO         : std_logic_vector(31 downto 0) := X"C33CC33C";
constant MSG_GPS2_NO         : std_logic_vector(31 downto 0) := X"3CC33CC3";
constant MSG_CLKPPS_NO       : std_logic_vector(31 downto 0) := X"3333CCCC";
constant MSG_GPS_AUTO_ON     : std_logic_vector(31 downto 0) := X"69966996";
constant MSG_GPS_AUTO_NO     : std_logic_vector(31 downto 0) := X"96699669";

constant STATUS_USED         : integer := 12 + extTrgNum + 2*ppsNum + 3*zynqNum;
constant STATUS_PAD          : integer := 32 - STATUS_USED;

signal dataRecv,
       dataRecvFF,
       run_s,
       cmd_busy_s,
       pps_auto_s,
       pps_trg_s    : std_logic;

signal ext_trg_en_s : std_logic_vector(extTrgNum-1 downto 0) := (others => '0');
signal zynq_en_s    : std_logic_vector(zynqNum-1 downto 0)   := (others => '0');
signal pps_en_s     : std_logic_vector(ppsNum-1 downto 0)    := (others => '0');

begin

run        <= run_s;
cmd_busy   <= cmd_busy_s;
zynq_en    <= zynq_en_s;
pps_en     <= pps_en_s;
pps_auto   <= pps_auto_s;
pps_trg    <= pps_trg_s;
ext_trg_en <= ext_trg_en_s;

status_register <=  std_logic_vector(to_unsigned(0, STATUS_PAD)) &
                    trigger_flag    &   -- zynqNum   bit
                    busy            &   -- zynqNum   bit
                    zynq_en_s       &   -- zynqNum   bit
                    ppsPres         &   -- ppsNum    bit
                    pps_en_s        &   -- ppsNum    bit
                    ext_trg_en_s    &   -- extTrgNum bit
                    '0'             &   -- 1 bit  -> 11 (reserved)
                    fsmState        &   -- 4 bit  -> 10..7
                    pps_auto_s      &   -- 1 bit  -> 6
                    pps_trg_s       &   -- 1 bit  -> 5
                    cmd_busy_s      &   -- 1 bit  -> 4
                    fifoFull        &   -- 1 bit  -> 3
                    plToAxiSBusy    &   -- 1 bit  -> 2
                    runCtrlBusy     &   -- 1 bit  -> 1
                    run_s;              -- 1 bit  -> 0

assert STATUS_USED <= 32
    report "status_register overflow: ridurre extTrgNum/zynqNum/ppsNum"
    severity failure;

decodeProc: process(clk)
begin
    if rising_edge(clk) then
        trg_command        <= '0';
        configure_GPS      <= '0';
        reset_GTU_count    <= '0';
        reset_l1_nr        <= '0';
        reset_evt_nr       <= '0';
        reset_all_counters <= '0';
        send_nack          <= '0';

        if rst = '1' then
            dataRecvFF   <= '0';
            dataRecv     <= '0';
            run_s        <= '0';
            cmd_busy_s   <= '0';
            zynq_en_s    <= (others => '0');
            pps_en_s     <= (others => '0');
            pps_auto_s   <= '0';
            pps_trg_s    <= '0';
            ext_trg_en_s <= (others => '0');
        else
            dataRecvFF <= data_received;
            dataRecv   <= dataRecvFF;

            if dataRecvFF = '1' and dataRecv = '0' then
                case command_in is
                    when MSG_START_RUN       => run_s              <= '1';
                    when MSG_STOP_RUN        => run_s              <= '0';
                    when MSG_SET_BUSY        => cmd_busy_s         <= '1';
                    when MSG_RELEASE_BUSY    => cmd_busy_s         <= '0';
                    when MSG_TRIGGER         => trg_command        <= '1';
                    when MSG_CONFIGURE_GPS   => configure_GPS      <= '1';
                    when MSG_GPS1_ON         => pps_en_s(1)        <= '1';
                    when MSG_GPS1_NO         => pps_en_s(1)        <= '0';
                    when MSG_GPS2_ON         => pps_en_s(2)        <= '1';
                    when MSG_GPS2_NO         => pps_en_s(2)        <= '0';
                    when MSG_CLKPPS_ON       => pps_en_s(0)        <= '1';
                    when MSG_CLKPPS_NO       => pps_en_s(0)        <= '0';
                    when MSG_GPS_AUTO_ON     => pps_auto_s         <= '1';
                    when MSG_GPS_AUTO_NO     => pps_auto_s         <= '0';
                    when MSG_RESET_GTU_COUNT => reset_GTU_count    <= '1';
                    when MSG_RESET_L1_COUNT  => reset_l1_nr        <= '1';
                    when MSG_RESET_EVT_COUNT => reset_evt_nr       <= '1';
                    when MSG_RESET_ALL_COUNT => reset_all_counters <= '1';
                    when MSG_PPS_TRG_ON      => pps_trg_s          <= '1';
                    when MSG_PPS_TRG_OFF     => pps_trg_s          <= '0';
                    when MSG_UNMASK_EXT_TRG0 => ext_trg_en_s(0)    <= '1';
                    when MSG_MASK_EXT_TRG0   => ext_trg_en_s(0)    <= '0';
                    when MSG_UNMASK_EXT_TRG1 => ext_trg_en_s(1)    <= '1';
                    when MSG_MASK_EXT_TRG1   => ext_trg_en_s(1)    <= '0';
                    when MSG_ZYNQ0_ON        => zynq_en_s(0)       <= '1';
                    when MSG_NO_ZYNQ0        => zynq_en_s(0)       <= '0';
                    when MSG_ZYNQ1_ON        => zynq_en_s(1)       <= '1';
                    when MSG_NO_ZYNQ1        => zynq_en_s(1)       <= '0';
                    when MSG_ZYNQ2_ON        => zynq_en_s(2)       <= '1';
                    when MSG_NO_ZYNQ2        => zynq_en_s(2)       <= '0';
                    when MSG_ZYNQ3_ON        => zynq_en_s(3)       <= '1';
                    when MSG_NO_ZYNQ3        => zynq_en_s(3)       <= '0';
                    when others              => send_nack          <= '1';
                end case;
            end if;
        end if;
    end if;
end process;

end Behavioral;