---------------------------------------------------------------------------------
-- Company: INFN Napoli
--
-- File: aliveDeadTCounter.vhd
-- File history:
--      0: 2026_05_26: adapted for PBR experiment (M. Mese)
-- 
-- Description: 
--
-- aliveDeadTCounter for Clock Board (EUSO-SPB2/PBR)
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity aliveDeadTCounter is
port(
    clk    : in  std_logic;
    rst    : in  std_logic;
    busy   : in  std_logic;
    trgIn  : in  std_logic;
    ready  : out std_logic;
    aliveT : out std_logic_vector(31 downto 0);
    deadT  : out std_logic_vector(31 downto 0)
);
end aliveDeadTCounter;

architecture Behavioral of aliveDeadTCounter is

signal busyFF    : std_logic;
signal rstAlive  : std_logic;
signal rstDead   : std_logic;
signal cntAlive  : unsigned(31 downto 0);
signal cntDead   : unsigned(31 downto 0);
signal aliveTSig : std_logic_vector(31 downto 0);
signal deadTSig  : std_logic_vector(31 downto 0);

begin

edgeProc: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            busyFF   <= '0';
            rstAlive <= '1';
            rstDead  <= '1';
        else
            busyFF   <= busy;
            rstAlive <= busy and not busyFF;
            rstDead  <= not busy and busyFF;
        end if;
    end if;
end process;

aliveProc: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' or rstAlive = '1' then
            cntAlive <= (others => '0');
        elsif busy = '0' then
            cntAlive <= cntAlive + 1;
        end if;
    end if;
end process;

deadProc: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' or rstDead = '1' then
            cntDead <= (others => '0');
        elsif busy = '1' then
            cntDead <= cntDead + 1;
        end if;
    end if;
end process;

tProc: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            aliveTSig <= (others => '0');
            deadTSig  <= (others => '0');
        else
            if rstAlive = '1' then
                aliveTSig <= std_logic_vector(cntAlive);
            end if;

            if rstDead = '1' then
                deadTSig <= std_logic_vector(cntDead);
            end if;
        end if;
    end if;
end process;

outProc: process(clk)
begin
    if rising_edge(clk) then
        ready <= '0';

        if rst = '1' then
            aliveT <= (others => '0');
            deadT  <= (others => '0');
        elsif trgIn = '1' then
            aliveT <= aliveTSig;
            deadT  <= deadTSig;
            ready  <= '1';
        end if;
    end if;
end process;

end Behavioral;