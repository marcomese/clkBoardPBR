----------------------------------------------------------------------------------
-- PBR Clock Board
--
-- Module Name: pulseExtender
-- Create Date: 01.07.2026 13:29:14
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

entity pulseExtender is
generic(
    sigWidth : positive;
    sigNum   : positive
);
port(
    clk    : in  std_logic;
    rst    : in  std_logic;
    sigIn  : in  std_logic_vector(sigNum-1 downto 0);
    sigOut : out std_logic_vector(sigNum-1 downto 0)
);
end pulseExtender;

architecture Behavioral of pulseExtender is

type counterArr_t is array(integer range <>) of unsigned(bitsNum(sigWidth)-1 downto 0);

signal sigWCntEn : std_logic_vector(sigNum-1 downto 0);

signal sigWCnt   : counterArr_t(sigNum-1 downto 0);

begin

w1Gen: if sigWidth <= 1 generate
begin
    sigOut <= sigIn;
end generate;

wGreaterThan1Gen: if sigWidth > 1 generate
    sigWCntGen: for n in 0 to sigNum-1 generate
    begin
        sigWCntProc: process(clk)
        begin
            if rising_edge(clk) then
                if rst = '1' then
                    sigOut(n)    <= '0';
                    sigWCntEn(n) <= '0';
                    sigWCnt(n)   <= to_unsigned(sigWidth-1, sigWCnt(n)'length);
                else
                    if sigIn(n) = '1' then
                        sigOut(n)    <= '1';
                        sigWCntEn(n) <= '1';
                    end if;
        
                    if sigWCnt(n) = 0 then
                        sigOut(n)    <= '0';
                        sigWCntEn(n) <= '0';
                        sigWCnt(n)   <= to_unsigned(sigWidth-1, sigWCnt(n)'length);
                    elsif sigWCntEn(n) = '1' then
                        sigWCnt(n) <= sigWCnt(n) - 1;
                    end if;
                end if;
            end if;
        end process;
    end generate;
end generate;


end Behavioral;
