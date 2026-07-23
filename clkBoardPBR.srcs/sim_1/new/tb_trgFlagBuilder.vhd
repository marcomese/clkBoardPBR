library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_trgFlagBuilder is
end tb_trgFlagBuilder;

architecture Behavioral of tb_trgFlagBuilder is

constant clkPeriod     : time     := 10 ns;
constant trgNum        : integer  := 4;
constant extTrgNum     : positive := 2;
constant gpsNum        : positive := 2;
constant nGtuLen       : positive := 4;
constant nClkTOut      : positive := 100;
constant nClkRst       : positive := 32;
constant sigWidth      : positive := 10;

signal clk             : std_logic := '1';
signal rst             : std_logic := '1';
signal running         : std_logic := '0';
signal trgIn           : std_logic_vector(trgNum-1 downto 0) := (others => '0');
signal ready           : std_logic := '0';
signal triggerFlags    : std_logic_vector(trgNum-1 downto 0) := (others => '0');
signal gtuTick         : std_logic;
signal fsmState        : std_logic_vector(3 downto 0) := (others => '0');
signal trigger_in      : std_logic_vector(trgNum-1 downto 0) := (others => '0');
signal trgExtended     : std_logic_vector(trgNum-1 downto 0) := (others => '0');
signal busy_in         : std_logic_vector(trgNum-1 downto 0) := (others => '0');
signal zynq_on         : std_logic_vector(trgNum-1 downto 0) := (others => '0');
signal run_val         : std_logic := '0';
signal cmd_busy        : std_logic := '0';
signal release_busy    : std_logic := '0';
signal trigger_command : std_logic := '0';
signal trigger_ext     : std_logic_vector(extTrgNum-1 downto 0) := (others => '0');
signal triggerExtMask  : std_logic_vector(extTrgNum-1 downto 0) := (others => '0');
signal ppsTrgEn        : std_logic := '0';
signal PPS             : std_logic := '0';
signal N_gtu           : std_logic_vector(nGtuLen-1 downto 0) := (others => '0');
signal plToAxiSBusy    : std_logic := '0';
signal fifoFull        : std_logic := '0';
signal trigger_out     : std_logic := '0';
signal busy            : std_logic := '0';
signal reset_counters  : std_logic := '0';
signal timeout         : std_logic;
signal timeoutFlag     : std_logic_vector(trgNum-1 downto 0);

begin

stimProc: process
begin
    wait until rst = '0';
    wait for clkPeriod;

    run_val <= '1';
    zynq_on <= "1111";
    wait for clkPeriod*5;

    trigger_in <= "0100";
    wait for clkPeriod;
    trigger_in <= "0000";

    wait;
end process;

rst <= '0' after clkPeriod*5;

clk <= not clk after clkPeriod/2;

trgFlagBuilderInst: entity work.trgFlagBuilder
generic map(
    trgNum => trgNum
)
port map(
    clk          => clk,
    rst          => rst,
    running      => running,
    trg_out      => trigger_out,
    trgIn        => trgExtended,
    ready        => ready,
    triggerFlags => triggerFlags
);

pulseExtInst: entity work.pulseExtender
generic map(
    sigWidth => sigWidth,
    sigNum   => trgNum
)
port map(
    clk    => clk,
    rst    => rst,
    sigIn  => trigger_in,
    sigOut => trgExtended
);

runCtrlInst: entity work.run_control_fsm
generic map(
    extTrgNum => extTrgNum,
    zynqNum   => trgNum,
    gpsNum    => gpsNum,
    nGtuLen   => nGtuLen,
    nClkTOut  => nClkTOut,
    nClkRst   => nClkRst
)
port map(
    reset           => rst,
    clock           => clk,
    gtuTick         => gtuTick,
    fsmState        => fsmState,
    trigger_in      => trigger_in,
    busy_in         => busy_in,
    zynq_on         => zynq_on,
    run_val         => run_val,
    cmd_busy        => cmd_busy,
    release_busy    => release_busy,
    trigger_command => trigger_command,
    trigger_ext     => trigger_ext,
    triggerExtMask  => triggerExtMask,
    ppsTrgEn        => ppsTrgEn,
    PPS             => PPS,
    N_gtu           => N_gtu,
    plToAxiSBusy    => plToAxiSBusy,
    fifoFull        => fifoFull,
    trigger_out     => trigger_out,
    busy            => busy,
    reset_counters  => reset_counters,
    timeout         => timeout,
    timeoutFlag     => timeoutFlag,
    running         => running
);

end Behavioral;
