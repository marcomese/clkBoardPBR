----------------------------------------------------------------------------------
-- PBR Clock Board
--
-- Module Name: ppsControl
-- Create Date: 26.05.2026 11:52:15
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
use IEEE.STD_LOGIC_MISC.ALL;

entity ppsControl is
generic(
    clkFreq    : positive;
    ppsWidth   : positive;
    ppsNum     : positive
);
port(
    clk        : in  std_logic;
    rst        : in  std_logic;
    clear      : in  std_logic;
    ppsAuto    : in  std_logic;
    ppsSel     : in  std_logic_vector(ppsNum-1 downto 0);
    ppsPres    : in  std_logic_vector(ppsNum-1 downto 0);
    ppsEdgeIn  : in  std_logic_vector(ppsNum-1 downto 0);
    ppsOut     : out std_logic;
    ppsEdgeOut : out std_logic;
    ppsCnt     : out std_logic_vector(31 downto 0)
);
end ppsControl;

architecture Behavioral of ppsControl is

signal   secCounter    : integer range 0 to clkFreq-1;

signal   internalPPS,
         ppsEdgeSig,
         secCounterEn,
         secCounterRst : std_logic;

signal   ppsOutSig,
         ppsEdgeSlv    : std_logic_vector(0 downto 0);

signal   ppsCntSig     : unsigned(31 downto 0);

begin

ppsOut        <= ppsOutSig(0);

ppsEdgeOut    <= ppsEdgeSig;

ppsEdgeSlv(0) <= ppsEdgeSig;

ppsCnt        <= std_logic_vector(ppsCntSig);

ppsMuxInst: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            ppsEdgeSig    <= '0';
            secCounterEn  <= '0';
            secCounterRst <= '1'; 
        elsif ppsAuto = '1' then
            ppsEdgeSig    <= internalPPS;
            secCounterEn  <= '1';
            secCounterRst <= '0';
            
            for g in ppsNum-1 downto 0 loop        -- the LSB of ppsPres has priority (IN1bit1->gps2,
                if ppsPres(g) = '1' then           --                                  IN1bit0->gps1,
                    ppsEdgeSig    <= ppsEdgeIn(g); --                                  IN0bit0->CC clk pps) <- highest priority
                    secCounterEn  <= '0';
                    secCounterRst <= '1';
                end if;
            end loop;
        else
            ppsEdgeSig    <= '0';
            secCounterEn  <= '0';
            secCounterRst <= '0';
    
            for g in ppsNum-1 downto 0 loop
                if ppsSel(g) = '1' then
                    ppsEdgeSig    <= ppsEdgeIn(g);
                    secCounterEn  <= '0';
                    secCounterRst <= '1';
                end if;
            end loop;
        end if;
    end if;
end process;

secCountInst: process(clk)
begin
    if rising_edge(clk) then
        internalPPS <= '0';

        if rst = '1' or secCounterRst = '1' then
            secCounter  <= 0;
        elsif secCounter = clkFreq-1 then
            secCounter  <= 0;
            internalPPS <= '1';
        elsif secCounterEn = '1' then
            secCounter  <= secCounter + 1;
        end if;
    end if;
end process;

ppsCounterProc: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            ppsCntSig  <= (others => '0');
        else
            if clear = '1' then
                ppsCntSig <= (others => '0');
            elsif ppsEdgeSig = '1' then
                ppsCntSig <= ppsCntSig + 1;
            end if;
        end if;
    end if;
end process;

pulseExtenderInst: entity work.pulseExtender
generic map(
    sigWidth => ppsWidth,
    sigNum   => 1
)
port map(
    clk    => clk,
    rst    => rst,
    sigIn  => ppsEdgeSlv,
    sigOut => ppsOutSig
);

end Behavioral;
