library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_runControl is
end tb_runControl;

architecture Behavioral of tb_runControl is

constant clkPeriod    : time     := 10 ns;
constant zynqNum      : positive := 4;
constant ppsNum       : positive := 3;
constant extTrgNum    : positive := 2;
constant clkFreq      : positive := 1000;      -- small, so the internal PPS is observable in sim
constant ppsWidth     : positive := 10;
constant ppsRstVal    : integer  := 1;
constant presWindow   : integer  := 2000;
constant clkPeriodNs  : positive := 10;
constant gtuPeriodNs  : positive := 1000;

-- command opcodes (must match cmdDecoder.vhd)
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
constant MSG_GTU_INTERNAL_ON : std_logic_vector(31 downto 0) := X"FFFF0000";
constant MSG_GTU_INTERNAL_NO : std_logic_vector(31 downto 0) := X"0000FFFF";


signal clk                : std_logic := '1';
signal rst                : std_logic := '1';

-- command_decoder interface
signal command_in         : std_logic_vector(31 downto 0) := (others => '0');
signal data_received      : std_logic := '0';
signal fsmState           : std_logic_vector(3 downto 0) := (others => '0');
signal fifoFull           : std_logic := '0';
signal busy               : std_logic_vector(zynqNum-1 downto 0) := (others => '1');
signal plToAxiSBusy       : std_logic := '0';
signal run                : std_logic;
signal cmd_busy           : std_logic;
signal zynq_en            : std_logic_vector(zynqNum-1 downto 0);
signal pps_en             : std_logic_vector(ppsNum-1 downto 0);
signal pps_auto           : std_logic;
signal pps_trg            : std_logic;
signal ext_trg_en         : std_logic_vector(extTrgNum-1 downto 0);
signal gtu_sel            : std_logic;
signal trg_command        : std_logic;
signal configure_GPS      : std_logic;
signal reset_GTU_count    : std_logic;
signal reset_l1_nr        : std_logic;
signal reset_evt_nr       : std_logic;
signal reset_all_counters : std_logic;
signal send_nack          : std_logic;
signal status_register    : std_logic_vector(31 downto 0);

-- pps chain
signal ppsIn              : std_logic_vector(ppsNum-1 downto 0) := (others => '0');
signal ppsEdge            : std_logic_vector(ppsNum-1 downto 0);
signal ppsPres            : std_logic_vector(ppsNum-1 downto 0);
signal ppsOut             : std_logic;
signal ppsEdgeOut         : std_logic;
signal ppsCnt             : std_logic_vector(31 downto 0);

-- gtu chain
signal gtuClock           : std_logic;
signal gtuTick            : std_logic;
signal gtuReady           : std_logic;
signal GTUcounted         : std_logic_vector(31 downto 0);

signal dataRdy,
       evtRdy,
       rstGtuOut,
       rstTrgOut,
       rstEvtOut          : std_logic;
signal evtNum             : std_logic_vector(31 downto 0);
signal trgCount           : std_logic_vector((zynqNum*32)-1 downto 0);

-- run_control_fsm interface
--   board-side inputs are stimulus; configuration comes from command_decoder,
--   'running'/'busy'/'trigger_out' come from the FSM (as wired in the block design)
signal trigger_in         : std_logic_vector(zynqNum-1 downto 0) := (others => '0');
signal trigger_ext        : std_logic_vector(extTrgNum-1 downto 0) := (others => '0');
signal N_gtu              : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(64, 8));
signal trigger_out        : std_logic;
signal runBusy            : std_logic;   -- run_control_fsm 'busy' output (global busy)
signal reset_counters     : std_logic;
signal running            : std_logic;
signal timeout            : std_logic;
signal timeoutFlag        : std_logic_vector(zynqNum-1 downto 0);

begin

rst    <= '0' after clkPeriod*5;
clk    <= not clk after clkPeriod/2;

-- external PPS on channel 0: one clock-wide pulse every 200 clocks
--ppsGen: process(clk)
--    variable cnt : integer range 0 to 199 := 0;
--begin
--    if rising_edge(clk) then
--        ppsIn(0) <= '0';
--        if rst = '1' then
--            cnt := 0;
--        elsif cnt = 199 then
--            cnt      := 0;
--            ppsIn(0) <= '1';
--        else
--            cnt := cnt + 1;
--        end if;
--    end if;
--end process;

stimProc: process

procedure sendCmd(cmd : in std_logic_vector(31 downto 0)) is
begin
    command_in    <= cmd;
    data_received <= '1', '0' after clkPeriod + 100 ps;
end procedure;

begin
    wait until rst = '0';
    wait for clkPeriod*2;
    
    busy <= (others => '1');

    sendCmd(MSG_ZYNQ0_ON);
    wait for clkPeriod*5;

    sendCmd(MSG_ZYNQ3_ON);
    wait for clkPeriod*5;

    sendCmd(MSG_START_RUN);
    wait for clkPeriod*5;

    sendCmd(MSG_GPS1_ON);
    wait for clkPeriod*5;

    sendCmd(MSG_GPS_AUTO_ON);
    wait for clkPeriod*5;

--    sendCmd(MSG_PPS_TRG_ON);
--    wait for clkPeriod*5;

    sendCmd(MSG_UNMASK_EXT_TRG0);
    wait for clkPeriod*5;

    sendCmd(MSG_GTU_INTERNAL_ON);
    wait for clkPeriod*5;

    sendCmd(MSG_TRIGGER);
    wait for clkPeriod*10;

    busy <= "0111";
    wait for clkPeriod*10;

    -- inject an L1 trigger from board 1 into the FSM and observe the dead time
    trigger_in <= "0010";
    wait for clkPeriod;
    trigger_in <= "0000";
    wait for clkPeriod*180;

    sendCmd(MSG_STOP_RUN);
    wait for clkPeriod*5;

    wait for clkPeriod*1000;

    sendCmd(MSG_START_RUN);
    wait for clkPeriod*5;

    busy <= "0110";

    wait for clkPeriod*100;

    trigger_in <= "1010";
    wait for clkPeriod;
    trigger_in <= "0000";
    wait for clkPeriod*180;

    sendCmd(MSG_STOP_RUN);
    wait for clkPeriod*5;

    wait for clkPeriod*1000;

    sendCmd(MSG_START_RUN);
    wait for clkPeriod*5;


    wait;
end process;

gtuGenInst: entity work.gtuGenerator
generic map(
    clkPeriodNs => clkPeriodNs,
    gtuPeriodNs => gtuPeriodNs
)
port map(
    clk      => clk,
    rst      => rst,
    enable   => running,
    gtuClock => gtuClock,
    gtuTick  => gtuTick
);

ppsEdgeInst: entity work.edgeDetectors
generic map(
    sigRst => 1,
    sigNum => ppsNum
)
port map(
    clk    => clk,
    rst    => rst,
    sigIn  => ppsIn,
    sigOut => ppsEdge
);

ppsPresInst: entity work.ppsPresent
generic map(
    presWindow => presWindow,
    ppsRstVal  => ppsRstVal,
    ppsNum     => ppsNum
)
port map(
    clk     => clk,
    rst     => rst,
    ppsIn   => ppsEdge,
    present => ppsPres
);

ppsCtrlInst: entity work.ppsControl
generic map(
    clkFreq  => clkFreq,
    ppsWidth => ppsWidth,
    ppsNum   => ppsNum
)
port map(
    clk        => clk,
    rst        => rst,
    enable     => running,
    clear      => reset_all_counters,
    ppsAuto    => pps_auto,
    ppsSel     => pps_en,
    ppsPres    => ppsPres,
    ppsEdgeIn  => ppsEdge,
    ppsOut     => ppsOut,
    ppsEdgeOut => ppsEdgeOut,
    ppsCnt     => ppsCnt
);

gtuCounterInst: entity work.GTUcounter
port map(
    clk        => clk,
    rst        => rst,
    run        => running,
    pps        => ppsEdgeOut,
    gtuTick    => gtuTick,
    trigger    => trigger_out,
    clear      => rstGtuOut,
    ready      => gtuReady,
    dataReady  => dataRdy,
    GTUcounted => GTUcounted
);

trgCntInst: entity work.trgCounter
generic map(
    trgNum => zynqNum
)
port map(
    clk      => clk,
    rst      => rst,
    clr      => rstTrgOut,
    trgIn    => trigger_in,
    trgCount => trgCount
);

cntRstCtrlInst: entity work.counterRstCtrl
port map(
    clk        => clk,
    rst        => rst,
    rstAll     => reset_all_counters,
    rstGtu     => reset_GTU_count,
    rstTrg     => reset_l1_nr,
    rstEvt     => reset_evt_nr,
    rstFromRun => reset_counters,
    rstGtuOut  => rstGtuOut,
    rstTrgOut  => rstTrgOut,
    rstEvtOut  => rstEvtOut
);

evtCounterInst: entity work.reg_event_number
port map(
    clock   => clk,
    reset   => rst,
    load    => trigger_out,
    clear   => rstEvtOut,
    ready   => evtRdy,
    reg_out => evtNum
);

dataBuilderInst: entity work.dataBuilder
generic map(
    trgNum    => zynqNum+extTrgNum,
    dataWords => 6
)
port map(
    clk       => clk,
    rst       => rst,
    evtNum    => evtNum,
    evtRdy    => evtRdy,
    gtuCount  => GTUcounted,
    gtuRdy    => gtuReady,
    trgFlag   => "000000",
    trgFRdy   => '1',
    aliveT    => x"00000000",
    deadT     => x"00000000",
    aDTRdy    => '1',
    statusReg => status_register,
    dataRdy   => dataRdy,
    dataOut   => open
);

cmdDecInst: entity work.command_decoder
generic map(
    extTrgNum => extTrgNum,
    zynqNum   => zynqNum,
    ppsNum    => ppsNum
)
port map(
    clk                => clk,
    rst                => rst,
    command_in         => command_in,
    data_received      => data_received,
    fsmState           => fsmState,
    ppsPres            => ppsPres,
    fifoFull           => fifoFull,
    busy               => busy,
    runCtrlBusy        => runBusy,
    plToAxiSBusy       => plToAxiSBusy,
    run                => run,
    timeout            => timeout,
    timeoutFlag        => timeoutFlag,
    running            => running,
    cmd_busy           => cmd_busy,
    zynq_en            => zynq_en,
    pps_en             => pps_en,
    pps_auto           => pps_auto,
    pps_trg            => pps_trg,
    ext_trg_en         => ext_trg_en,
    gtu_sel            => gtu_sel,
    trg_command        => trg_command,
    configure_GPS      => configure_GPS,
    reset_GTU_count    => reset_GTU_count,
    reset_l1_nr        => reset_l1_nr,
    reset_evt_nr       => reset_evt_nr,
    reset_all_counters => reset_all_counters,
    send_nack          => send_nack,
    status_register    => status_register
);

runCtrlInst: entity work.run_control_fsm
generic map(
    extTrgNum => extTrgNum,
    zynqNum   => zynqNum,
    gpsNum    => ppsNum,
    nGtuLen   => 8,
    nClkTOut  => 100,
    nClkRst   => 32
)
port map(
     reset           => rst,
     clock           => clk,
     gtuTick         => gtuTick,
     fsmState        => fsmState,
     trigger_in      => trigger_in,
     busy_in         => busy,
     zynq_on         => zynq_en,
     run_val         => run,
     set_rel_busy    => cmd_busy,
     trigger_command => trg_command,
     trigger_ext     => trigger_ext,
     triggerExtMask  => ext_trg_en,
     ppsTrgEn        => pps_trg,
     PPS             => ppsEdgeOut,
     N_gtu           => N_gtu,
     plToAxiSBusy    => plToAxiSBusy,
     fifoFull        => fifoFull,
     trigger_out     => trigger_out,
     busy            => runBusy,
     reset_counters  => reset_counters,
     timeout         => timeout,
     timeoutFlag     => timeoutFlag,
     running         => running
);

end Behavioral;