----------------------------------------------------------------------------------
-- PBR Clock Board
--
-- Module Name: ppsPresent
-- Create Date: 26.05.2026 13:01:31
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

entity ppsPresent is
generic(
    presWindow : integer;
    ppsRstVal  : integer;
    ppsNum     : integer
);
port(
    clk     : in  std_logic;
    rst     : in  std_logic;
    ppsIn   : in  std_logic_vector(ppsNum-1 downto 0);
    present : out std_logic_vector(ppsNum-1 downto 0)
);
end ppsPresent;

architecture Behavioral of ppsPresent is

type intArr_t is array(0 to ppsNum-1) of integer range 0 to presWindow-1;

signal waiting,
       presentSig   : std_logic_vector(ppsNum-1 downto 0);

signal presWCounter : intArr_t;

begin

present <= presentSig;

ppsPresGen: for n in 0 to ppsNum-1 generate
    ppsNPresProc: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                presentSig(n)   <= '1';
                presWCounter(n) <= 0;
                waiting(n)      <= '0';
            else
                if ppsIn(n) = '1' then
                    presentSig(n)   <= '1';
                    presWCounter(n) <= 0;
                    waiting(n)      <= '1';
                elsif waiting(n) = '1' then
                    if presWCounter(n) = presWindow-1 then
                        presentSig(n)   <= '0';
                        waiting(n)      <= '0';
                        presWCounter(n) <= 0;
                    else
                        presWCounter(n) <= presWCounter(n) + 1;
                    end if;
                else
                    if presWCounter(n) = presWindow-1 then
                        presentSig(n)   <= '0';
                        presWCounter(n) <= 0;
                    else
                        presWCounter(n) <= presWCounter(n) + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
end generate;

end Behavioral;