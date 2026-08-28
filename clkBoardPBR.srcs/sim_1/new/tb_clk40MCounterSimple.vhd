library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity tb_clk40MCounterSimple is
end tb_clk40MCounterSimple;

architecture Behavioral of tb_clk40MCounterSimple is

constant clkPeriod    : time := 10 ns;
constant clk40MPeriod : time := 25 ns;

-- il clock esterno e' volutamente a una frequenza diversa (25 MHz) cosi' dal
-- solo conteggio si capisce quale delle due sorgenti il mux sta selezionando
constant extClkPeriod : time := 40 ns;

constant trgDelay     : integer := 4;

signal clk       : std_logic := '1';
signal clk40M    : std_logic := '1';
signal extClk40M : std_logic := '1';
signal extClkOn  : std_logic := '1';   -- '0' simula il cavo staccato
signal rst       : std_logic := '1';
signal clk40MSel : std_logic := '0';   -- '0' = esterno, '1' = interno
signal enable    : std_logic := '0';
signal clear     : std_logic := '0';
signal trgIn     : std_logic := '0';

signal ready     : std_logic;
signal clk40MOut : std_logic;
signal clk40MCnt : std_logic_vector(31 downto 0);

-- riferimenti: fronti realmente presenti su ciascuna sorgente da quando e' partito il run
signal refInt    : integer := 0;
signal refExt    : integer := 0;

begin

clk       <= not clk    after clkPeriod/2;
clk40M    <= not clk40M after clk40MPeriod/2;
extClk40M <= (not extClk40M) and extClkOn after extClkPeriod/2;

refIntProc: process(clk40M, enable)
begin
    if enable = '0' then
        refInt <= 0;
    elsif rising_edge(clk40M) then
        refInt <= refInt + 1;
    end if;
end process;

refExtProc: process(extClk40M, enable)
begin
    if enable = '0' then
        refExt <= 0;
    elsif rising_edge(extClk40M) then
        refExt <= refExt + 1;
    end if;
end process;

stimProc: process
    variable l : line;

    procedure trig(msg : in string) is
    begin
        wait until rising_edge(clk);
        trgIn <= '1';
        wait until rising_edge(clk);
        trgIn <= '0';
        for i in 1 to trgDelay + 4 loop
            wait until rising_edge(clk);
        end loop;
        write(l, msg);
        write(l, string'("  sel="));
        write(l, std_logic'image(clk40MSel));
        write(l, string'("  refInt="));
        write(l, refInt);
        write(l, string'("  refExt="));
        write(l, refExt);
        write(l, string'("  latched="));
        write(l, to_integer(unsigned(clk40MCnt)));
        writeline(output, l);
    end procedure;

begin
    wait for clkPeriod*5;
    rst <= '0';
    wait for clkPeriod*10;

    -- 1) default dopo il reset: sorgente esterna presente
    enable <= '1';
    wait for 3 us;
    trig("esterno presente      ");

    -- 2) passaggio a interno, fatto a run fermo
    enable <= '0';
    wait for 1 us;
    clk40MSel <= '1';
    wait for 1 us;
    enable <= '1';
    wait for 3 us;
    trig("interno               ");

    -- 3) con l'interno selezionato il contatore deve fermarsi a run fermo (CE1 = enable)
    enable <= '0';
    wait for 2 us;
    enable <= '1';
    wait for 3 us;
    trig("interno dopo restart  ");

    -- 4) ritorno all'esterno, sempre a run fermo
    enable <= '0';
    wait for 1 us;
    clk40MSel <= '0';
    wait for 1 us;
    enable <= '1';
    wait for 3 us;
    trig("esterno di nuovo      ");

    -- 5) caso patologico: esterno selezionato ma assente (cavo staccato)
    enable    <= '0';
    wait for 1 us;
    extClkOn  <= '0';
    wait for 1 us;
    enable    <= '1';
    wait for 3 us;
    trig("esterno ASSENTE       ");

    -- 6) si deve poter tornare all'interno anche con l'esterno fermo: e' il
    --    motivo per cui IGNORE0 vale '1'
    enable    <= '0';
    wait for 1 us;
    clk40MSel <= '1';
    wait for 1 us;
    enable    <= '1';
    wait for 3 us;
    trig("recupero su interno   ");

    write(l, string'("fine"));
    writeline(output, l);
    wait;
end process;

clk40MCounterInst: entity work.clk40MCounter
generic map(
    trgDelay => trgDelay
)
port map(
    clk       => clk,
    clk40M    => clk40M,
    extClk40M => extClk40M,
    rst       => rst,
    clk40MSel => clk40MSel,
    enable    => enable,
    clear     => clear,
    trgIn     => trgIn,
    ready     => ready,
    clk40MOut => clk40MOut,
    clk40MCnt => clk40MCnt
);

end Behavioral;
