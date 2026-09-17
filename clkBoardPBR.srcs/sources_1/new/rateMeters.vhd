----------------------------------------------------------------------------------
-- PBR Clock Board
--
-- Module Name: rateMeters
-- Create Date: 17.09.2026 13:51:45
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
use work.utilsPkg.all;

entity rateMeters is
generic(
    sigNum  : positive;
    rateLen : positive;
    clkFreq : positive
);
port(
    clk     : in  std_logic;
    rst     : in  std_logic;
    sigIn   : in  std_logic_vector(sigNum-1 downto 0);
    rateOut : out std_logic_vector((sigNum*rateLen)-1 downto 0)
);
end rateMeters;

architecture Behavioral of rateMeters is

type rateMeters_t is array(integer range <>) of unsigned(rateLen-1 downto 0);

signal secCnt      : unsigned(bitsNum(clkFreq) downto 0); -- MSB = overflow

signal rateMeters  : rateMeters_t(sigNum-1 downto 0);

begin

rateGen: for i in 0 to sigNum-1 generate
    rateOutProc: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                rateOut((rateLen*(i+1))-1 downto rateLen*i) <= (others => '0');
            elsif secCnt(secCnt'left) = '1' then
                rateOut((rateLen*(i+1))-1 downto rateLen*i) <= std_logic_vector(rateMeters(i));
            end if;
        end if;
    end process;

    rateMeterProc: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                rateMeters(i) <= (others => '0');
            elsif secCnt(secCnt'left) = '1' then
                rateMeters(i) <= (0 => sigIn(i), others => '0'); -- counts a signal happening during counter wrapping
            elsif sigIn(i) = '1' then
                rateMeters(i) <= rateMeters(i) + 1;
            end if;
        end if;
    end process;
end generate;

secCntProc: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' or secCnt(secCnt'left) = '1' then
            secCnt <= to_unsigned(clkFreq-2, secCnt'length);
        else
            secCnt <= secCnt - 1;
        end if;
    end if;
end process;

end Behavioral;
