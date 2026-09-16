----------------------------------------------------------------------------------
-- PBR Clock Board
--
-- Module Name: selfTrigger
-- Create Date: 11.09.2026
-- Target Devices: Zynq 7000 xc7z020clg484-2
--
-- Created by: Marco Mese
--
-- Description:
-- Periodic trigger generator driven by the "trg self <period>" command.
-- The period is given as scale + count (see command_decoder):
--   scale 000 = 10 ns, 001 = 100 ns, 010 = 1 us, 011 = 10 us, 100 = 100 us,
--   101 = 1 ms; count 1..8191 units.
-- A chain of divide-by-10 prescalers generates the unit ticks from the 10 ns
-- clock, a 13 bit counter on the selected tick produces the trigger pulse.
-- The chain restarts whenever the generator is enabled or the period changes,
-- so the first trigger comes exactly one period after the command.
--
-- Revision:
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity selfTrigger is
generic(
    clkPeriodNs : positive := 10
);
port(
    clk    : in  std_logic;
    rst    : in  std_logic;
    enable : in  std_logic;
    scale  : in  std_logic_vector(2 downto 0);
    period : in  std_logic_vector(12 downto 0); -- in units of the selected scale, >= 1
    trgOut : out std_logic
);
end selfTrigger;

architecture Behavioral of selfTrigger is

constant STAGES : integer := 5; -- 100 ns, 1 us, 10 us, 100 us, 1 ms

type decCnt_t is array(1 to STAGES) of unsigned(3 downto 0);

signal decCnt    : decCnt_t;
signal tick      : std_logic_vector(0 to STAGES); -- tick(0) = every clock
signal baseTick  : std_logic;
signal restart   : std_logic;
signal scaleFF   : std_logic_vector(2 downto 0);
signal periodFF  : std_logic_vector(12 downto 0);
signal periodCnt : unsigned(12 downto 0);

begin

assert clkPeriodNs = 10
    report "selfTrigger: the scale steps (10 ns, 100 ns, ...) assume a 100 MHz clock"
    severity failure;

restart <= '1' when rst = '1' or enable = '0' or scaleFF /= scale or periodFF /= period else '0';

tick(0) <= '1';

prescalerGen: for s in 1 to STAGES generate
begin
    prescalerProc: process(clk)
    begin
        if rising_edge(clk) then
            tick(s) <= '0';

            if restart = '1' then
                decCnt(s) <= (others => '0');
            elsif tick(s-1) = '1' then
                if decCnt(s) = 9 then
                    decCnt(s) <= (others => '0');
                    tick(s)   <= '1';
                else
                    decCnt(s) <= decCnt(s) + 1;
                end if;
            end if;
        end if;
    end process;
end generate;

with scale select baseTick <=
    tick(0) when "000",
    tick(1) when "001",
    tick(2) when "010",
    tick(3) when "011",
    tick(4) when "100",
    tick(5) when "101",
    '0'     when others;

periodProc: process(clk)
begin
    if rising_edge(clk) then
        trgOut   <= '0';
        scaleFF  <= scale;
        periodFF <= period;

        if restart = '1' then
            periodCnt <= unsigned(period) - 1;
        elsif baseTick = '1' then
            if periodCnt = 0 then
                trgOut    <= '1';
                periodCnt <= unsigned(period) - 1;
            else
                periodCnt <= periodCnt - 1;
            end if;
        end if;
    end if;
end process;

end Behavioral;
