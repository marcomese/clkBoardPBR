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

entity GTUcounter is
port(
    clk        : in  std_logic;
    rst        : in  std_logic;
    run        : in  std_logic;
    pps        : in  std_logic;
    gtuTick    : in  std_logic;
    trigger    : in  std_logic;
    clear      : in  std_logic;
    ready      : out std_logic;
    GTUcounted : out std_logic_vector(31 downto 0)
);
end GTUcounter;

architecture Behavioral of GTUcounter is

signal enGtuCount  : std_logic;
signal rstGtuCount : std_logic;
signal gtuCounter  : unsigned(31 downto 0);

begin

ctrlProc: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            rstGtuCount <= '1';
            enGtuCount  <= '0';
        else
            rstGtuCount <= (not run) or pps;
            enGtuCount  <=  run  and not pps;
        end if;
    end if;
end process;

gtuCountProc: process(clk)
begin
    if rising_edge(clk) then
        if rstGtuCount = '1' or clear = '1' then
            gtuCounter <= (others => '0');
        elsif enGtuCount = '1' and gtuTick = '1' then
            gtuCounter <= gtuCounter + 1;
        end if;
    end if;
end process;

gtuReg: process(clk)
begin
    if rising_edge(clk) then
        ready <= '0';

        if rst = '1' then
            GTUcounted <= (others => '0');
        elsif trigger = '1' then
            -- latch on every trigger, PPS-sourced included: during a PPS the
            -- counter is held at 0, so GTUcounted = 0 (offset from the PPS edge)
            GTUcounted <= std_logic_vector(gtuCounter);
            ready      <= '1';
        elsif rstGtuCount = '1' or clear = '1' then
            GTUcounted <= (others => '0');
        end if;
    end if;
end process;

end Behavioral;