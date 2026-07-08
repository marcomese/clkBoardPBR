---------------------------------------------------------------------------------
-- Company: INFN Napoli
--
-- File: trgFlagBuilder.vhd
-- File history:
--      0: 2026_05_22: adapted for PBR experiment (M. Mese)
-- 
-- Description: 
--
-- trgFlagBuilder for Clock Board (EUSO-SPB2/PBR)
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_MISC.ALL;

entity trgFlagBuilder is
generic(
    trgNum       : positive
);
port(
    clk          : in  std_logic;
    rst          : in  std_logic;
    running      : in  std_logic;
    trg_out      : in  std_logic;
    trgIn        : in  std_logic_vector(trgNum-1 downto 0);
    ready        : out std_logic;
    triggerFlags : out std_logic_vector(trgNum-1 downto 0)
);
end trgFlagBuilder;

architecture Behavioral of trgFlagBuilder is

signal  trgInDelayed : std_logic_vector(trgNum-1 downto 0);

begin

trgFlagReg: process(clk, rst)
begin
    if rising_edge(clk) then
        ready <= '0';

        if rst = '1' then
            triggerFlags <= (others => '0');
        elsif running = '1' and trg_out = '1' then
            triggerFlags <= trgIn;
            ready        <= '1';
        end if;
    end if;
end process;

end Behavioral;
