library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_ppsControl is
end tb_ppsControl;

architecture Behavioral of tb_ppsControl is

constant clkPeriod   : time    := 10 ns;
constant clkFreq     : positive := 100_000_000; -- Hz
constant pps1Period  : time    := 10 ms;
constant pps2Period  : time    := 5 ms;
constant pps3Period  : time    := 15 ms;
constant presWindow  : integer := 1_000_000; -- ns
constant ppsNum      : positive := 3;
constant ppsWidth    : positive := 10;
constant ppsRstVal   : integer := 4;

signal clk,
       rst,
       ppsAuto,
       pps1En,
       pps2En,
       pps3En  : std_logic := '1';

signal enable,
       clear   : std_logic := '0';

signal ppsOut  : std_logic;

signal ppsCnt  : std_logic_vector(31 downto 0);

signal ppsIn   : std_logic_vector(ppsNum-1 downto 0) := (ppsNum-1 => '0',
                                                         others   => '0');

signal ppsEdge : std_logic_vector(ppsNum-1 downto 0) := (others => '0');

signal ppsSel,
       ppsPres : std_logic_vector(ppsNum-1 downto 0) := (others => '0');

begin

rst <= '0' after clkPeriod*5;

enable <= '1' after clkPeriod*6, '0' after 50 ms, '1' after 150 ms;

clk <= not clk after clkPeriod/2;

pps1En <= '0' after 100 ms;
pps2En <= '0' after 300 ms;
pps3En <= '0' after 500 ms;

ppsIn(0) <= (not ppsIn(0)) and pps1En after pps1Period/2, '0' after 100 ms;
ppsIn(1) <= (not ppsIn(1)) and pps2En after pps2Period/2;
ppsIn(2) <= (not ppsIn(2)) and pps3En after pps3Period/2;

ppsPresInst: entity work.ppsPresent
generic map(
    presWindow => presWindow,
    ppsRstVal  => ppsRstVal,
    ppsNum     => ppsNum
)
port map(
    clk     => clk,
    rst     => rst,
    ppsIn   => ppsIn,
    present => ppsPres
);

ppsEdgeInst: entity work.edgeDetectors
generic map(
    sigRst => 1,
    sigNum => ppsNum
)
port map(
    clk    => clk,
    rst    => rst,
    sigIn  => ppsIn,
    sigOut => ppsEdge
);

ppsCtrlInst: entity work.ppsControl
generic map(
    clkFreq  => clkFreq,
    ppsWidth => ppsWidth,
    ppsNum   => ppsNum
)
port map(
    clk       => clk,
    rst       => rst,
    enable    => enable,
    clear     => clear,
    ppsAuto   => ppsAuto,
    ppsSel    => ppsSel,
    ppsPres   => ppsPres,
    ppsEdgeIn => ppsEdge,
    ppsOut    => ppsOut,
    ppsCnt    => ppsCnt
);

end Behavioral;