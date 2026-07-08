library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_runControl is
end tb_runControl;

architecture Behavioral of tb_runControl is

constant clkPeriod           : time                          := 10 ns;
constant zynqNum             : integer                       := 4;
constant gpsNum              : integer                       := 2;
constant clkFreq             : integer                       := 100_000_000;
constant presWindow          : integer                       := 150;
constant clkPeriodNs         : integer                       := 10;
constant gtuPeriodNs         : integer                       := 1000;
constant MSG_START_RUN       : std_logic_vector(31 downto 0) := X"FFFFFFFF";
constant MSG_STOP_RUN        : std_logic_vector(31 downto 0) := X"AAAAAAAA";
constant MSG_RELEASE_BUSY    : std_logic_vector(31 downto 0) := X"55555555";
constant MSG_SET_BUSY        : std_logic_vector(31 downto 0) := X"CCCCCCCC";
constant MSG_TRIGGER         : std_logic_vector(31 downto 0) := X"33333333";
constant MSG_RESET_GPS       : std_logic_vector(31 downto 0) := X"66666666";
constant MSG_CONFIGURE_GPS   : std_logic_vector(31 downto 0) := X"99999999";
constant MSG_GPS1_ON         : std_logic_vector(31 downto 0) := X"F0F0F0F0";
constant MSG_GPS2_ON         : std_logic_vector(31 downto 0) := X"0F0F0F0F";
constant MSG_RESET_GTU_COUNT : std_logic_vector(31 downto 0) := X"5A5A5A5A";
constant MSG_RESET_TRG_COUNT : std_logic_vector(31 downto 0) := X"A5A5A5A5";
constant MSG_RESET_PCK_COUNT : std_logic_vector(31 downto 0) := X"3C3C3C3C";
constant MSG_RESET_ALL_COUNT : std_logic_vector(31 downto 0) := X"C3C3C3C3";
constant MSG_PPS_TRG_ON      : std_logic_vector(31 downto 0) := X"96969696";
constant MSG_PPS_TRG_OFF     : std_logic_vector(31 downto 0) := X"69696969";
constant MSG_MASK_EXT_TRG    : std_logic_vector(31 downto 0) := X"FF00FF00";
constant MSG_UNMASK_EXT_TRG  : std_logic_vector(31 downto 0) := X"00FF00FF";
constant MSG_SELF_TRG_ON     : std_logic_vector(31 downto 0) := X"55AA55AA";
constant MSG_SELF_TRG_OFF    : std_logic_vector(31 downto 0) := X"AA55AA55";
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
constant MSG_GPS_AUTO_ON     : std_logic_vector(31 downto 0) := X"69966996";
constant MSG_GPS_AUTO_NO     : std_logic_vector(31 downto 0) := X"96699669";

signal clk                : std_logic := '1';
signal rst                : std_logic := '1';
signal run                : std_logic := '0';
signal pps                : std_logic := '0';
signal gtuTick            : std_logic := '0';
signal gtuClock           : std_logic := '0';
signal trigger            : std_logic := '0';
signal clear              : std_logic := '0';
signal ready              : std_logic := '0';
signal GTUcounted         : std_logic_vector(31 downto 0) := (others => '0');
signal command_in         : std_logic_vector(31 downto 0) := (others => '0');
signal data_received      : std_logic := '0';
signal fsmState           : std_logic_vector(3 downto 0) := (others => '0');
signal trigger_flag       : std_logic_vector(zynqNum-1 downto 0):= (others => '0');
signal gpsPres            : std_logic_vector(gpsNum-1 downto 0):= (others => '0');
signal fifoFull           : std_logic := '0';
signal busy               : std_logic_vector(zynqNum-1 downto 0):= (others => '0');
signal runCtrlBusy        : std_logic := '0';
signal plToAxiSBusy       : std_logic := '0';
signal cmd_busy           : std_logic := '0';
signal zynq_en            : std_logic_vector(zynqNum-1 downto 0):= (others => '0');
signal gps_en             : std_logic_vector(gpsNum-1 downto 0):= (others => '0');
signal gps_auto           : std_logic := '0';
signal pps_trg            : std_logic := '0';
signal ext_trg_en         : std_logic := '0';
signal self_trg           : std_logic := '0';
signal trg_command        : std_logic := '0';
signal configure_GPS      : std_logic := '0';
signal reset_GPS          : std_logic := '0';
signal reset_GTU_count    : std_logic := '0';
signal reset_l1_nr        : std_logic := '0';
signal reset_evt_nr       : std_logic := '0';
signal reset_all_counters : std_logic := '0';
signal send_nack          : std_logic := '0';
signal status_register    : std_logic_vector(31 downto 0):= (others => '0');
signal ppsIn              : std_logic_vector(gpsNum-1 downto 0) := (others => '0');
signal ppsOut             : std_logic := '0';
signal ppsCnt             : std_logic_vector(31 downto 0) := (others => '0');

begin

stimProc: process

procedure sendCmd(cmd : in std_logic_vector(31 downto 0)) is
begin
    command_in    <= cmd;
    data_received <= '1', '0' after clkPeriod+100 ps;
end procedure;

begin
    wait until rst = '0';

    wait for clkPeriod;

    sendCmd(MSG_START_RUN);

    wait for clkPeriod*5;

    sendCmd(MSG_GPS_AUTO_ON);

    wait for clkPeriod;

    wait;
end process;

rst <= '0' after clkPeriod*5;

clk <= not clk after clkPeriod/2;

gtuGeninst: entity work.gtuGenerator
generic map(
    clkPeriodNs => clkPeriodNs,
    gtuPeriodNs => gtuPeriodNs
)
port map(
    clk      => clk,
    rst      => rst,
    gtuClock => gtuClock,
    gtuTick  => gtuTick
);

gtuCounterInst: entity work.gtuCounter
port map(
    clk        => clk,
    rst        => rst,
    run        => run,
    pps        => pps,
    gtuTick    => gtuTick,
    trigger    => trigger,
    clear      => clear,
    ready      => ready,
    GTUcounted => GTUcounted
);

ppsPresInst: entity work.ppsPresent
generic map(
    presWindow => presWindow,
    gpsNum     => gpsNum
)
port map(
    clk     => clk,
    rst     => rst,
    ppsIn   => ppsIn,
    present => gpsPres
);

ppsCtrlInst: entity work.ppsControl
generic map(
    clkFreq => clkFreq,
    gpsNum  => gpsNum
)
port map(
    clk     => clk,
    rst     => rst,
    gpsAuto => gps_auto,
    gpsSel  => gps_en,
    gpsPres => gpsPres,
    ppsIn   => ppsIn,
    ppsOut  => ppsOut,
    ppsCnt  => ppsCnt
);

cmdDecInst: entity work.command_decoder
generic map(
    zynqNum            => zynqNum,
    gpsNum             => gpsNum
)
port map(
    clk                => clk,
    rst                => rst,
    command_in         => command_in,
    data_received      => data_received,
    fsmState           => fsmState,
    trigger_flag       => trigger_flag,
    gpsPres            => gpsPres,
    fifoFull           => fifoFull,
    busy               => busy,
    runCtrlBusy        => runCtrlBusy,
    plToAxiSBusy       => plToAxiSBusy,
    run                => run,
    cmd_busy           => cmd_busy,
    zynq_en            => zynq_en,
    gps_en             => gps_en,
    gps_auto           => gps_auto,
    pps_trg            => pps_trg,
    ext_trg_en         => ext_trg_en,
    self_trg           => self_trg,
    trg_command        => trg_command,
    configure_GPS      => configure_GPS,
    reset_GPS          => reset_GPS,
    reset_GTU_count    => reset_GTU_count,
    reset_l1_nr        => reset_l1_nr,
    reset_evt_nr       => reset_evt_nr,
    reset_all_counters => reset_all_counters,
    send_nack          => send_nack,
    status_register    => status_register
);

end Behavioral;
