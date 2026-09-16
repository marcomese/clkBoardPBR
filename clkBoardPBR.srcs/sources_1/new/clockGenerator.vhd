----------------------------------------------------------------------------------
-- Clock Generator
--
-- Module Name: clockGenerator
-- Create Date: 22.05.2026 15:19:25
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

entity clockGenerator is
generic(
    periodLen   : integer
);
port(
    clk            : in  std_logic;
    rst            : in  std_logic;
    enable         : in  std_logic;
    period         : in  std_logic_vector(periodLen-1 downto 0); -- output period in clk cycles, >= 2
    clkOut         : out std_logic;
    clkRisingEdge  : out std_logic;
    clkFallingEdge : out std_logic
);
end clockGenerator;

architecture Behavioral of clockGenerator is

signal clkCnt,
       cntMax,
       cntHlf,
       cntMaxIn,
       cntHlfIn : unsigned(periodLen-1 downto 0);

signal clkSig   : std_logic;

begin

clkOut   <= clkSig;
cntMaxIn <= unsigned(period) - 1;
cntHlfIn <= shift_right(unsigned(period), 1) + resize(unsigned(period(0 downto 0)), periodLen); -- ceil(period/2)

clkCntInst: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' or enable = '0' then
            cntMax         <= cntMaxIn;
            cntHlf         <= cntHlfIn;
            clkCnt         <= cntMaxIn;
            clkSig         <= '0';
            clkRisingEdge  <= '0';
            clkFallingEdge <= '0';
        elsif clkCnt = 0 then
            cntMax         <= cntMaxIn;   -- a new period takes effect here
            cntHlf         <= cntHlfIn;
            clkCnt         <= cntMaxIn;
            clkSig         <= '1';
            clkRisingEdge  <= not clkSig;
        elsif clkCnt = cntHlf then
            clkCnt         <= clkCnt - 1;
            clkSig         <= '0';
            clkFallingEdge <= clkSig;
        else
            clkCnt         <= clkCnt - 1;
            clkRisingEdge  <= '0';
            clkFallingEdge <= '0';
        end if;
    end if;
end process;

end Behavioral;
