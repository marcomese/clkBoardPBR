----------------------------------------------------------------------------------
-- PBR Clock Board
--
-- Module Name: dataBuilder
-- Create Date: 26.05.2026 15:54:13
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

entity dataBuilder is
generic(
    trgNum    : integer;
    dataWords : integer  -- number of 32 bit words in data
);
port(
    clk       : in  std_logic;
    rst       : in  std_logic;
    evtNum    : in  std_logic_vector(31 downto 0);
    evtRdy    : in  std_logic;
    gtuCount  : in  std_logic_vector(31 downto 0);
    gtuRdy    : in  std_logic;
    ppsCount  : in  std_logic_vector(31 downto 0);
    trgFlag   : in  std_logic_vector(trgNum-1 downto 0);
    trgFRdy   : in  std_logic;
    aliveT    : in  std_logic_vector(31 downto 0);
    deadT     : in  std_logic_vector(31 downto 0);
    aDTRdy    : in  std_logic;
    statusReg : in  std_logic_vector(31 downto 0);
    dataRdy   : out std_logic;
    dataOut   : out std_logic_vector(32*dataWords-1 downto 0)
);
end dataBuilder;

architecture Behavioral of dataBuilder is

signal dRdySig    : std_logic;

signal rdySig     : std_logic_vector(3 downto 0);

signal trgFlagSig : std_logic_vector(31 downto 0);

begin

trgFlagSig(trgFlagSig'left downto trgNum) <= (others => '0');
trgFlagSig(trgNum-1 downto 0)             <= trgFlag;

dataOutProc: process(clk)
begin
    if rising_edge(clk) then
        dataRdy <= '0';

        if rst = '1' then
            dataOut <= (others => '0');
        elsif dRdySig = '1' then
            dataRdy <= '1';
            dataOut <= evtNum     &
                       gtuCount   &
                       ppsCount   & 
                       trgFlagSig & 
                       aliveT     &
                       deadT      &
                       statusReg;
        end if;
    end if;
end process;

rdyProc: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' or dRdySig = '1' then
            rdySig  <= (others => '0');
            dRdySig <= '0';
        else
            dRdySig <= and_reduce(rdySig);

            if evtRdy = '1' then
                rdySig(3) <= '1';
            end if;

            if gtuRdy = '1' then
                rdySig(2) <= '1';
            end if;

            if trgFRdy = '1' then
                rdySig(1) <= '1';
            end if;

            if aDTRdy = '1' then
                rdySig(0) <= '1';
            end if;
        end if;
    end if;
end process;

end Behavioral;
