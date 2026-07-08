---------------------------------------------------------------------------------
-- Company: INFN Napoli
--
-- File: reg_event_number.vhd
-- File history:
--      0: 2026_05_22: adapted for PBR experiment (M. Mese)
-- 
-- Description: 
--
-- reg_event_number for Clock Board (EUSO-SPB2/PBR)
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity reg_event_number is
port(
    clock   : in   std_logic;
    reset   : in   std_logic;
    load    : in   std_logic;
    clear   : in   std_logic;
    ready   : out  std_logic;
    reg_out : out  std_logic_vector(31 downto 0)
);
end reg_event_number;

architecture Behavioral of reg_event_number is

signal counter    : unsigned(31 downto 0);
signal loadRegOut : std_logic;

begin

countProc: process(clock) 
begin
    if rising_edge(clock) then
        loadRegOut <= '0';

        if reset ='1' or clear = '1' then 
            counter    <= (others => '0');
        elsif load = '1' then
            counter    <= counter + 1;
            loadRegOut <= '1';
        end if;
    end if;
end process;

reg_event_number: process(clock)
begin
    if rising_edge(clock) then
        ready <= '0';

        if reset = '1' or clear = '1' then
            reg_out <= (others => '0');
        elsif loadRegOut = '1' then
            reg_out <= std_logic_vector(counter);
            ready   <= '1';
        end if;
    end if;
end process;

end Behavioral;
