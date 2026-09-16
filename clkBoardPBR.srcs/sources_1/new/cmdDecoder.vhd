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
    ppsNum    : positive;
    statusLen : positive
);
port(
    clk                : in  std_logic;
    rst                : in  std_logic;
    command_in         : in  std_logic_vector(31 downto 0);
    data_received      : in  std_logic;
    fsmState           : in  std_logic_vector(3 downto 0);
    ppsPres            : in  std_logic_vector(ppsNum-1 downto 0);
    fifoFull           : in  std_logic;
    busy               : in  std_logic_vector(zynqNum-1 downto 0);
    runCtrlBusy        : in  std_logic;
    running            : in  std_logic;
    timeout            : in  std_logic;
    timeoutFlag        : in  std_logic_vector(zynqNum-1 downto 0);
    plToAxiSBusy       : in  std_logic;
    -- level outputs
    run                : out std_logic;
    cmd_busy           : out std_logic;
    zynq_en            : out std_logic_vector(zynqNum-1 downto 0);
    pps_en             : out std_logic_vector(ppsNum-1 downto 0);
    pps_auto           : out std_logic;
    pps_trg            : out std_logic;
    ext_trg_en         : out std_logic_vector(extTrgNum-1 downto 0);
    gtu_sel            : out std_logic;
    gtuPeriod          : out std_logic_vector(15 downto 0);
    clk40M_sel         : out std_logic;
    selfTrgEn          : out std_logic;
    selfTrgScale       : out std_logic_vector(2 downto 0);
    selfTrgPeriod      : out std_logic_vector(12 downto 0);
    xGammaChannel      : out std_logic_vector(zynqNum-1 downto 0);
    masterSlave        : out std_logic_vector(31 downto 0);
    -- pulse outputs
    release_busy       : out std_logic;
    trg_command        : out std_logic;
    configure_GPS      : out std_logic;
    reset_GTU_count    : out std_logic;
    reset_l1_nr        : out std_logic_vector(zynqNum-1 downto 0);
    reset_evt_nr       : out std_logic;
    reset_all_counters : out std_logic;
    send_nack          : out std_logic;
    -- status register
    status_register    : out std_logic_vector(statusLen-1 downto 0)
);
end command_decoder;

architecture Behavioral of command_decoder is

type codeArr_t is array(natural range <>) of std_logic_vector(7 downto 0);

-- numbers: channel 0..6 (ARG1/ARG2)
constant NUM : codeArr_t(0 to 6) := (x"0F", x"33", x"55", x"66", x"99", x"AA", x"CC");

function numIdx(code : std_logic_vector(7 downto 0)) return integer is
begin
    for i in NUM'range loop
        if code = NUM(i) then
            return i;
        end if;
    end loop;

    return integer'high;
end function;

constant CMD_RUN : std_logic_vector(7 downto 0) := x"0F";
constant CMD_BSY : std_logic_vector(7 downto 0) := x"33";
constant CMD_TRG : std_logic_vector(7 downto 0) := x"55";
constant CMD_GPS : std_logic_vector(7 downto 0) := x"66";
constant CMD_PPS : std_logic_vector(7 downto 0) := x"99";
constant CMD_GTU : std_logic_vector(7 downto 0) := x"AA";
constant CMD_40M : std_logic_vector(7 downto 0) := x"CC";
constant CMD_CNT : std_logic_vector(7 downto 0) := x"F0";
constant CMD_CHN : std_logic_vector(7 downto 0) := x"3C";

constant ARG_ON      : std_logic_vector(7 downto 0) := x"0F"; -- start, set, enable, on, internal, soft, configure, pps gps, counter l1, gps 1
constant ARG_OFF     : std_logic_vector(7 downto 0) := x"F0"; -- stop, release, disable, off, external, pps clkb, counter evt, gps 2
constant ARG_PPS     : std_logic_vector(7 downto 0) := x"33"; -- trg pps, pps auto, counter gtu, ch xgamma
constant ARG_NORMAL  : std_logic_vector(7 downto 0) := x"CC"; -- trg normal, counter all
constant ARG_CLKB    : std_logic_vector(7 downto 0) := x"55"; -- trg clkb
constant ARG_SELF    : std_logic_vector(7 downto 0) := x"AA"; -- trg self
constant ARG_ALL     : std_logic_vector(7 downto 0) := x"FF"; -- channel "all" (ARG1)

constant STATUS_USED : integer := 14 + extTrgNum + 2*ppsNum + 4*zynqNum;
constant STATUS_PAD  : integer := statusLen - STATUS_USED;

constant MSTR_STR    : std_logic_vector(31 downto 0) := x"4D_53_54_52";
constant SLV_STR     : std_logic_vector(31 downto 0) := x"53_4C_56_20";

signal dataRecvFF,
       dataRecvFall,
       cmdReady,
       run_s,
       cmd_busy_s,
       pps_auto_s,
       pps_trg_s,
       clk40MSelSig,
       gtuSelSig    : std_logic;

signal ext_trg_en_s : std_logic_vector(extTrgNum-1 downto 0) := (others => '0');
signal zynq_en_s,
       xGChSig      : std_logic_vector(zynqNum-1 downto 0)   := (others => '0');
signal pps_en_s     : std_logic_vector(ppsNum-1 downto 0)    := (others => '0');

signal cmdSig,
       arg0Sig,
       arg1Sig,
       arg2Sig      : std_logic_vector(7 downto 0);

signal mstrSlvSig   : std_logic_vector(31 downto 0);

begin

assert STATUS_USED <= statusLen
    report "status_register overflow: reduce extTrgNum/zynqNum/ppsNum"
    severity failure;

run           <= run_s;
cmd_busy      <= cmd_busy_s;
zynq_en       <= zynq_en_s;
pps_en        <= pps_en_s;
pps_auto      <= pps_auto_s;
pps_trg       <= pps_trg_s;
ext_trg_en    <= ext_trg_en_s;
clk40M_sel    <= clk40MSelSig;
gtu_sel       <= gtuSelSig;
xGammaChannel <= xGChSig;
masterSlave   <= mstrSlvSig;
dataRecvFall  <= dataRecvFF and not data_received;

status_register <=  std_logic_vector(to_unsigned(0, STATUS_PAD)) &
                    busy            &   -- zynqNum   bit
                    zynq_en_s       &   -- zynqNum   bit
                    ppsPres         &   -- ppsNum    bit
                    pps_en_s        &   -- ppsNum    bit
                    ext_trg_en_s    &   -- extTrgNum bit
                    timeoutFlag     &   -- zynqNum   bit
                    xGChSig         &   -- zynqNum   bit
                    clk40MSelSig    &   -- 1 bit  -> 13
                    gtuSelSig       &   -- 1 bit  -> 12
                    timeout         &   -- 1 bit  -> 11
                    fsmState        &   -- 4 bit  -> 10..7
                    pps_auto_s      &   -- 1 bit  -> 6
                    pps_trg_s       &   -- 1 bit  -> 5
                    cmd_busy_s      &   -- 1 bit  -> 4
                    fifoFull        &   -- 1 bit  -> 3
                    plToAxiSBusy    &   -- 1 bit  -> 2
                    runCtrlBusy     &   -- 1 bit  -> 1
                    running;            -- 1 bit  -> 0

masterSlaveDecodeProc: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            mstrSlvSig <= MSTR_STR;
        elsif ext_trg_en_s(0) = '0' then
            mstrSlvSig <= MSTR_STR;
        elsif ext_trg_en_s(0) = '1' then
            mstrSlvSig <= SLV_STR;
        else
            mstrSlvSig <= (others => '0');
        end if;
    end if;
end process;

cmdArgsProc: process(clk)
begin
    if rising_edge(clk) then
        cmdReady   <= '0';

        if rst = '1' then
            dataRecvFF <= '0';
            cmdSig     <= (others => '0');
            arg0Sig    <= (others => '0');
            arg1Sig    <= (others => '0');
            arg2Sig    <= (others => '0');
        else
            dataRecvFF <= data_received;

            if dataRecvFall = '1' then
                cmdSig     <= command_in(31 downto 24);
                arg0Sig    <= command_in(23 downto 16);
                arg1Sig    <= command_in(15 downto 8);
                arg2Sig    <= command_in(7 downto 0);
                cmdReady   <= '1';
            end if;
        end if;
    end if;
end process;

decodeProc: process(clk)
    variable scale  : std_logic_vector(2 downto 0);
    variable period : std_logic_vector(12 downto 0);
    variable gtuPrd : std_logic_vector(15 downto 0);
begin
    if rising_edge(clk) then
        trg_command        <= '0';
        configure_GPS      <= '0';
        release_busy       <= '0';
        reset_GTU_count    <= '0';
        reset_l1_nr        <= (others => '0');
        reset_evt_nr       <= '0';
        reset_all_counters <= '0';
        send_nack          <= '0';

        if rst = '1' then
            scale         := (others => '0');
            period        := (others => '0');
            gtuPrd        := (others => '0');
            run_s         <= '0';
            cmd_busy_s    <= '0';
            zynq_en_s     <= (others => '0');
            pps_en_s      <= (others => '0');
            pps_auto_s    <= '0';
            pps_trg_s     <= '0';
            ext_trg_en_s  <= (others => '0');
            gtuSelSig     <= '0';
            gtuPeriod     <= (others => '0');
            clk40MSelSig  <= '0';
            selfTrgEn     <= '0';
            selfTrgScale  <= (others => '0');
            selfTrgPeriod <= (others => '0');
            xGChSig       <= (others => '0');
        else
            if cmdReady = '1' then
                case cmdSig is
                    when CMD_RUN =>
                        if arg0Sig = ARG_ON then
                            run_s <= '1';
                        elsif arg0Sig = ARG_OFF then
                            run_s <= '0';
                        else
                            send_nack <= '1';
                        end if;

                    when CMD_BSY =>
                        if arg0Sig = ARG_ON then
                            cmd_busy_s <= '1';
                        elsif arg0Sig = ARG_OFF then
                            cmd_busy_s   <= '0';
                            release_busy <= '1';
                        else
                            send_nack <= '1';
                        end if;

                    when CMD_TRG => -- all the triggers can be selected at the same time
                        scale  := arg1Sig(7 downto 5);
                        period := arg1Sig(4 downto 0) & arg2Sig;

                        if arg0Sig = ARG_ON then --trg soft
                            trg_command <= '1';
                        elsif arg0Sig = ARG_OFF and arg1Sig = ARG_ON then -- trg external enable
                            ext_trg_en_s(1) <= '1'; -- (trg from jtrg connector)
                        elsif arg0Sig = ARG_OFF and arg1Sig = ARG_OFF then -- trg external disable
                            ext_trg_en_s(1) <= '0';
                        elsif arg0Sig = ARG_PPS and arg1Sig = ARG_ON then -- trg pps enable
                            pps_trg_s       <= '1';
                        elsif arg0Sig = ARG_PPS and arg1Sig = ARG_OFF then -- trg pps disable
                            pps_trg_s <= '0';
                        elsif arg0Sig = ARG_NORMAL then -- trg normal
                            ext_trg_en_s(1) <= '0';
                            pps_trg_s       <= '0';
                            selfTrgEn       <= '0';
                        elsif arg0Sig = ARG_CLKB and arg1Sig = ARG_ON then -- trg clkb enable
                            ext_trg_en_s(0) <= '1'; -- (trg from the other clk board)
                        elsif arg0Sig = ARG_CLKB and arg1Sig = ARG_OFF then -- trg clkb disable
                            ext_trg_en_s(0) <= '0';
                        elsif arg0Sig = ARG_SELF and arg1Sig = x"00" and arg2Sig = x"00" then -- trg self disable
                            selfTrgEn       <= '0';
                            selfTrgScale  <= (others => '0');
                            selfTrgPeriod <= (others => '0');
                        elsif arg0Sig = ARG_SELF and unsigned(scale) <= 5 and unsigned(period) /= 0 then -- trg self <scale:period>
                            selfTrgEn       <= '1';
                            selfTrgScale    <= scale;
                            selfTrgPeriod   <= period;
                        else
                            send_nack <= '1';
                        end if;

                    when CMD_GPS =>
                        if arg0Sig = ARG_ON then -- gps configure <hi:lo>
                            configure_GPS <= '1';
                        else
                            send_nack <= '1';
                        end if;

                    when CMD_PPS =>
                        if arg0Sig = ARG_ON and arg1Sig = ARG_ON then -- pps gps 1
                            pps_en_s(2) <= '0';
                            pps_en_s(1) <= '1';
                            pps_en_s(0) <= '0';
                            pps_auto_s  <= '0';
                        elsif arg0Sig = ARG_ON and arg1Sig = ARG_OFF then -- pps gps 2
                            pps_en_s(2) <= '1';
                            pps_en_s(1) <= '0';
                            pps_en_s(0) <= '0';
                            pps_auto_s  <= '0';
                        elsif arg0Sig = ARG_OFF then -- pps clkb
                            pps_en_s(2) <= '0';
                            pps_en_s(1) <= '0';
                            pps_en_s(0) <= '1';
                            pps_auto_s  <= '0';
                        elsif arg0Sig = ARG_PPS then -- pps auto
                            pps_en_s   <= (others => '0');
                            pps_auto_s <= '1';
                        else
                            send_nack <= '1';
                        end if;

                    when CMD_GTU =>
                        gtuPrd := arg1Sig & arg2Sig;

                        if arg0Sig = ARG_ON and unsigned(gtuPrd) >= 2 then -- gtu internal <periodHi:periodLo>
                            gtuSelSig <= '1';
                            gtuPeriod <= gtuPrd;
                        elsif arg0Sig = ARG_OFF then -- gtu external
                            gtuSelSig <= '0';
                            gtuPeriod <= (others => '0');
                        else
                            send_nack <= '1';
                        end if;

                    when CMD_40M =>
                        if arg0Sig = ARG_ON then -- clk40m internal
                            clk40MSelSig <= '1';
                        elsif arg0Sig = ARG_OFF then -- clk40m external
                            clk40MSelSig <= '0';
                        else
                            send_nack <= '1';
                        end if;

                    when CMD_CNT =>
                        if arg0Sig = ARG_ON and numIdx(arg1Sig) < zynqNum and arg2Sig = ARG_ON  then -- counter l1 <ch> reset
                            reset_l1_nr(numIdx(arg1Sig)) <= '1';
                        elsif arg0Sig = ARG_ON and arg1Sig = ARG_ALL and arg2Sig = ARG_ON  then -- counter l1 all 
                            reset_l1_nr <= (others => '1');
                        elsif arg0Sig = ARG_OFF and arg1Sig = ARG_ON then -- counter evt reset
                            reset_evt_nr <= '1';
                        elsif arg0Sig = ARG_PPS and arg1Sig = ARG_ON then -- counter gtu reset
                            reset_GTU_count <= '1';
                        elsif arg0Sig = ARG_NORMAL and arg1Sig = ARG_ON then -- counter all reset
                            reset_all_counters <= '1';
                        else
                            send_nack <= '1';
                        end if;

                    when CMD_CHN =>
                        if arg0Sig = ARG_ON and numIdx(arg1Sig) < zynqNum then -- ch enable <n>
                            zynq_en_s(numIdx(arg1Sig)) <= '1';
                        elsif arg0Sig = ARG_ON and arg1Sig = ARG_ALL then -- ch enable all
                            zynq_en_s <= (others => '1');
                        elsif arg0Sig = ARG_OFF and numIdx(arg1Sig) < zynqNum then -- ch disable <n>
                            zynq_en_s(numIdx(arg1Sig)) <= '0';
                        elsif arg0Sig = ARG_OFF and arg1Sig = ARG_ALL then -- ch disable <n>
                            zynq_en_s <= (others => '0');
                        elsif arg0Sig = ARG_PPS and arg1Sig = ARG_ON and numIdx(arg2Sig) < zynqNum then -- ch xgamma on <n>
                            xGChSig                  <= (others => '0');
                            xGChSig(numIdx(arg2Sig)) <= '1';
                        elsif arg0Sig = ARG_PPS and arg1Sig = ARG_OFF then -- ch xgamma off
                            xGChSig <= (others => '0'); 
                        else
                            send_nack <= '1';
                        end if;

                    when others =>
                        send_nack <= '1';
                end case;
            end if;
        end if;
    end if;
end process;

end Behavioral;