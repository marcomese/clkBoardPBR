----------------------------------------------------------------------------------
-- PBR Clock Board
--
-- Module Name: trgValidation
-- Create Date: 24.06.2026 14:21:05
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

entity trgValidation is
generic(
    nClkDelay   : positive;
    trgOutWidth : positive;
    trgNum      : positive
);
port(
    clk         : in  std_logic;
    rst         : in  std_logic;
    trgIn       : in  std_logic_vector(trgNum-1 downto 0);
    trgOut      : out std_logic_vector(trgNum-1 downto 0)
);
end trgValidation;

architecture Behavioral of trgValidation is

type delCntArray_t is array(integer range <>) of unsigned(bitsNum(nClkDelay)-1 downto 0);

type trgOutCntArray_t is array(integer range <>) of unsigned(bitsNum(trgOutWidth)-1 downto 0);

signal delCnt    : delCntArray_t(trgNum-1 downto 0);

signal trgCnt    : trgOutCntArray_t(trgNum-1 downto 0);

signal trgEn     : std_logic_vector(trgNum-1 downto 0);

signal trgOutSig : std_logic_vector(trgNum-1 downto 0);

begin

valGen: for n in 0 to trgNum-1 generate
begin
    trgExtProc: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                trgEn(n)  <= '0';
                trgCnt(n) <= (others => '0');
                trgOut(n) <= '0';
            elsif trgEn(n) = '0' then
                trgOut(n) <= '0';

                if trgOutSig(n) = '1' then
                    trgEn(n)  <= '1';
                    trgCnt(n) <= (others => '0');
                    trgOut(n) <= '1';
                end if;
            else
                trgOut(n) <= '1';

                if trgCnt(n) = trgOutWidth-1 then
                    trgEn(n)  <= '0';
                    trgOut(n) <= '0';
                    trgCnt(n) <= (others => '0');
                else
                    trgCnt(n) <= trgCnt(n) + 1;
                end if;
            end if;
        end if;
    end process;

    valNProc: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                delCnt(n)    <= (others => '0');
                trgOutSig(n) <= '0';
            else
                trgOutSig(n) <= '0';

                if trgIn(n) = '1' then
                    if delCnt(n) < nClkDelay-1 then
                        delCnt(n) <= delCnt(n) + 1;
                    elsif delCnt(n) = nClkDelay-1 then
                        trgOutSig(n) <= '1';
                        delCnt(n)    <= delCnt(n) + 1;
                    end if;
                else
                    delCnt(n) <= (others => '0');
                end if;
            end if;
        end if;
    end process;
end generate;

end Behavioral;
