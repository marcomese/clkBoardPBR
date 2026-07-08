---------------------------------------------------------------------------------
-- Company: INFN Napoli
--
-- File: run_control_fsm.vhd
-- File history:
--      0: 2021_11_23 : file creation
--      1: 2021_12_28: inserito busy da ZYNQ
--                     cosa fare se questo segnale e' sempre alto? inserire un comando di maschera da cpu?
--      3.1: 2022_08_13: inserito trigger da PPS
--                                           NB: PPS = PPS and TRG_DA_PPS_ON (status_register(9))
--                       cambiato uscita da busy_state
--                       cambiato uscita da trOr_state
--                       cambiato valore di busy_tr_i in busy_zynq_state
--
--
--      4: 2026_05_22: adapted for PBR experiment (M. Mese)
--                     fixed GTU_count CDC 
-- Description: 
--
-- run control for Clock Board (EUSO-SPB2/PBR)
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_MISC.ALL;

-- trigger and busy signal must be already syncronized and high only for 1 clock cyle

entity run_control_fsm is
generic(
    extTrgNum : positive;
    zynqNum   : positive;
    gpsNum    : positive;
    nGtuLen   : positive
);
port(
    reset           : in  std_logic;
    clock           : in  std_logic;  
    gtuTick         : in  std_logic;
    fsmState        : out std_logic_vector(3 downto 0);
    trigger_in      : in  std_logic_vector(zynqNum-1 downto 0); 
    busy_in         : in  std_logic_vector(zynqNum-1 downto 0); 
    zynq_on         : in  std_logic_vector(zynqNum-1 downto 0);
    run_val         : in  std_logic;
    set_rel_busy    : in  std_logic;
    trigger_command : in  std_logic;
    trigger_ext     : in  std_logic_vector(extTrgNum-1 downto 0);
    triggerExtMask  : in  std_logic_vector(extTrgNum-1 downto 0);
    ppsTrgEn        : in  std_logic;
    PPS             : in  std_logic;
    N_gtu           : in  std_logic_vector(nGtuLen-1 downto 0);
    plToAxiSBusy    : in  std_logic;
    fifoFull        : in  std_logic;
    trigger_out     : out std_logic;
    busy            : out std_logic;
    reset_counters  : out std_logic 
);
end run_control_fsm;

architecture Behavioral of run_control_fsm is

type state_values is(
    idle_state,      -- default state, busy = '1'
    start_run_state, -- transition state
    wait_trg_state,  -- waiting for trigger
    trgOr_state,
    trg_cpu_state ,  -- trg_out = '1', transition state
    trg_ext_state,
    trg_PPS_state,
    busy_cpu_state,
    busy_zynq_state,
    busy_state       -- system is busy during run
);

function stateToSlv(s : state_values) return std_logic_vector is
begin
    case s is
        when idle_state       => return x"0";
        when start_run_state  => return x"1";
        when wait_trg_state   => return x"2";
        when trgOr_state      => return x"3";
        when trg_cpu_state    => return x"4";
        when trg_ext_state    => return x"5";
        when trg_PPS_state    => return x"6";
        when busy_cpu_state   => return x"7";
        when busy_zynq_state  => return x"8";
        when busy_state       => return x"9";
    end case;
end function;

signal pres_state, 
       next_state       : state_values;

signal busy_i,
       trigger_out_i,
       busy_trg_i,
       busy_trg,
       reset_counters_i,
       busy_zynq,
       busy_s,
       triggerOr,
       triggerOutSig    : std_logic;

signal extTrgMasked     : std_logic_vector(extTrgNum-1 downto 0);

signal fsmStateSig      : std_logic_vector(3 downto 0);

signal GTU_count        : unsigned(7 downto 0);

signal busyAndZynq,
       triggerAndZynq   : std_logic_vector(zynqNum-1 downto 0);

begin

busyAndZynq    <= busy_in and zynq_on;

busy_zynq      <= or_reduce(busyAndZynq);

fsmState       <= fsmStateSig;

triggerAndZynq <= trigger_in and zynq_on;

triggerOr      <= or_reduce(triggerAndZynq);

extTrgMasked   <= trigger_ext and triggerExtMask;

trigger_out    <= triggerOutSig;

busy           <= busy_s or fifoFull;

SYNC_PROC: process(clock)
begin
    if rising_edge(clock) then
        if reset='1' then 
            busy_s         <= '0' ;
            triggerOutSig  <= '0' ;
            reset_counters <= '0' ;
            busy_trg       <= '0' ;
            fsmStateSig    <= (others => '0');
    
            pres_state     <= idle_state;
        else
            busy_s         <= busy_i ;
            triggerOutSig  <= trigger_out_i ;
            reset_counters <= reset_counters_i ;
            busy_trg       <= busy_trg_i ;
            fsmStateSig    <= stateToSlv(next_state);
    
            pres_state     <= next_state;
        end if;
    end if;
end process;

COMB_PROC: process(pres_state, triggerOr, busy_zynq, N_gtu,
                   run_val, set_rel_busy, trigger_command, 
                   GTU_count, trigger_ext, PPS, extTrgMasked, fifoFull, ppsTrgEn, plToAxiSBusy)
begin
    next_state <= pres_state;
    
    case pres_state is
        when idle_state =>
            if run_val = '0' then
                next_state <= idle_state;
            elsif run_val = '1' and busy_zynq = '0' then
                next_state <= start_run_state;
            else
                next_state <= idle_state;
            end if;
        
        when start_run_state => 
            if run_val = '0' then
                next_state <= idle_state;
            elsif run_val = '1' and set_rel_busy = '1' then
                next_state <= busy_CPU_state;
            elsif run_val = '1' and busy_zynq = '1' then
                next_state <= busy_zynq_state;
            else
                next_state <= wait_trg_state; 
            end if;
        
        when wait_trg_state =>
            if run_val = '0' then
                    next_state <= idle_state;
            elsif run_val = '1' and busy_zynq = '1' then
                    next_state <= busy_zynq_state;            
            elsif run_val = '1' and triggerOr = '1' and fifoFull = '0' then
                    next_state <= trgOr_state;
            elsif run_val = '1' and trigger_command = '1' and fifoFull = '0' then
                    next_state <= trg_cpu_state;
            elsif run_val = '1' and unsigned(extTrgMasked) /= 0 and fifoFull = '0' then
                    next_state <= trg_ext_state;
            elsif run_val = '1' and PPS = '1' and ppsTrgEn = '1' and fifoFull = '0' then
                    next_state <= trg_PPS_state;
            elsif run_val = '1' and set_rel_busy = '1' then
                    next_state <= busy_CPU_state;
            else
                next_state <= wait_trg_state;
            end if;
        
        when trgOr_state => 
            if run_val = '0' then
                next_state <= idle_state;
            elsif run_val = '1' and set_rel_busy = '1' then
                next_state <= busy_CPU_state;
            else 
                next_state <= busy_state;
            end if;
        
        when trg_cpu_state => 
            if run_val = '0' then
                next_state <= idle_state;
            elsif run_val = '1' and set_rel_busy = '1' then
                next_state <= busy_CPU_state;
            else 
                next_state <= busy_state;
            end if;
        
        when trg_ext_state => 
            if run_val = '0' then
                next_state <= idle_state;
            elsif run_val = '1' and set_rel_busy = '1' then
                next_state <= busy_CPU_state;
            else 
                next_state <= busy_state;
            end if;
        
        when trg_PPS_state => 
            if run_val = '0' then
                next_state <= idle_state;
            elsif run_val = '1' and set_rel_busy = '1' then
                next_state <= busy_CPU_state;
            else 
                next_state <= busy_state;
            end if;
        
        when busy_CPU_state => 
            if run_val = '0' then
                next_state <= idle_state;
            elsif set_rel_busy = '0' then
                next_state <= wait_trg_state;
            else 
                next_state <= busy_CPU_state;
            end if;
        
        when busy_state => 
            if run_val = '0' then
                next_state <= idle_state;
            elsif set_rel_busy = '0' then
                next_state <= wait_trg_state;
            elsif GTU_count = unsigned(N_GTU)-1 then
                next_state <= busy_zynq_state;
            else 
                next_state <= busy_state;
            end if;
        
        when busy_zynq_state =>
            if run_val = '0' then
                next_state <= idle_state;
            elsif (busy_zynq = '0') and (plToAxiSBusy = '0') then
                next_state <= wait_trg_state;
            elsif set_rel_busy = '0' then
                next_state <= wait_trg_state;
            else 
                next_state <= busy_zynq_state;
            end if;
        
        when others =>
            next_state <= idle_state;
        end case;
end process;
    
OUTPUT_DECODE: process(next_state)
begin
    if next_state = idle_state then
        busy_i           <= '1' ;
        trigger_out_i    <= '0' ;
        reset_counters_i <= '0' ;
        busy_trg_i       <= '0';
    
    elsif next_state = start_run_state then 
        busy_i           <= '0' ;
        trigger_out_i    <= '0' ;
        reset_counters_i <= '1' ;
        busy_trg_i       <= '0';
    
    elsif next_state = wait_trg_state then 
        busy_i           <= '0' ;
        trigger_out_i    <= '0' ;
        reset_counters_i <= '0' ;
        busy_trg_i       <= '0';
    
    elsif next_state = trg_PPS_state then 
        busy_i           <= '0' ;
        trigger_out_i    <= '1' ;
        reset_counters_i <= '0' ;
        busy_trg_i       <= '0';
    
    elsif next_state = trg_ext_state then 
        busy_i           <= '0' ;
        trigger_out_i    <= '1' ;
        reset_counters_i <= '0' ;
        busy_trg_i       <= '0';
    
    elsif next_state = trg_cpu_state then 
        busy_i           <= '0' ;
        trigger_out_i    <= '1' ;
        reset_counters_i <= '0' ;
        busy_trg_i       <= '0';
    
    elsif next_state = trgOr_state then 
        busy_i           <= '0' ;
        trigger_out_i    <= '1' ;
        reset_counters_i <= '0' ;
        busy_trg_i       <= '0';
    
    elsif next_state = busy_cpu_state then  
        busy_i           <= '1' ;
        trigger_out_i    <= '0' ;
        reset_counters_i <= '0' ;
        busy_trg_i       <= '0';
    
    elsif next_state = busy_zynq_state then  
        busy_i           <= '1' ;
        trigger_out_i    <= '0' ;
        reset_counters_i <= '0' ;
        busy_trg_i       <= '0';
    
    elsif next_state = busy_state then  
        busy_i           <= '1' ;
        trigger_out_i    <= '0' ;
        reset_counters_i <= '0' ;
        busy_trg_i       <= '1';
    else
        busy_i           <= '1' ;
        trigger_out_i    <= '0' ;
        reset_counters_i <= '0' ;
        busy_trg_i       <= '0';
    end if; 
end process;

-- after a trigger the system is in busy for N_GTU ( 1 < n_GTU < 128 ) 
-- reset = trigger_out
gtuCntProc: process(clock)
begin
    if rising_edge(clock) then
        if reset= '1' or triggerOutSig = '1' then 
            GTU_count <= (others => '0');
        elsif gtuTick = '1' and busy_trg = '1' then -- the counter is enabled only if the trigger has been received from one of the zynq boards
            if GTU_count < unsigned(N_GTU)-1  then
                GTU_count <= GTU_count + 1;
            end if;
        end if;
    end if;
end process;
end Behavioral;