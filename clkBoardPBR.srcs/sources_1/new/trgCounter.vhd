----------------------------------------------------------------------------------
-- PBR Clock Board
--
-- Module Name: ppsControl
-- Create Date: 27.05.2026 10:33:16
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

entity trgCounter is
generic(
    trgNum : integer
);
port(
    clk      : in  std_logic;
    rst      : in  std_logic;
    clr      : in  std_logic;
    trgIn    : in  std_logic_vector(trgNum-1 downto 0);
    trgCount : out std_logic_vector((trgNum*32)-1 downto 0)
);
end trgCounter;

architecture Behavioral of trgCounter is

signal trgFF,
       trgEdge     : std_logic_vector(trgNum-1 downto 0);

signal trgCountSig : unsigned((trgNum*32)-1 downto 0);

begin

trgCount <= std_logic_vector(trgCountSig);

edgeDetProc: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            trgFF   <= (others => '0');
            trgEdge <= (others => '0');
        else
            trgFF   <= trgIn;
            trgEdge <= trgIn and not trgFF;
        end if;
    end if;
end process;

counterGen: for n in 0 to trgNum-1 generate
begin
    trgCntN: process(clk)
    begin
        if rising_edge (clk) then
            if rst = '1' or clr = '1' then
                trgCountSig(32*(n+1)-1 downto 32*n) <= (others => '0');
            elsif trgEdge(n) = '1' then
                trgCountSig(32*(n+1)-1 downto 32*n) <= trgCountSig(32*(n+1)-1 downto 32*n) + 1;
            end if;
        end if;
    end process;
end generate; 

end Behavioral;
