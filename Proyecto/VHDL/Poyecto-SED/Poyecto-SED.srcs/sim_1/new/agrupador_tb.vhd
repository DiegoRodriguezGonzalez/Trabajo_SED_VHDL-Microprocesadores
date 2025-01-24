library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity agrupador_tb is
end agrupador_tb;

architecture Behavioral of agrupador_tb is
   -- Declaración componente
    component agrupador
        generic (
            NPlantas : positive := 4  -- Número de plantas del ascensor
        );
        port (
            PLANTA0 : in std_logic;
            PLANTA1 : in std_logic;
            PLANTA2 : in std_logic;
            PLANTA3 : in std_logic;
            SALIDA  : out std_logic_vector(NPlantas-1 downto 0)
        );
    end component;
    
    signal PLANTA0 : std_logic := '0';
    signal PLANTA1 : std_logic := '0';
    signal PLANTA2 : std_logic := '0';
    signal PLANTA3 : std_logic := '0';
    signal SALIDA  : std_logic_vector(3 downto 0);

begin
    --Unit under test (UUT)
    uut: agrupador
        generic map (
            NPlantas => 4  -- Número de plantas
        )
        port map (
            PLANTA0 => PLANTA0,
            PLANTA1 => PLANTA1,
            PLANTA2 => PLANTA2,
            PLANTA3 => PLANTA3,
            SALIDA  => SALIDA
        );
        
    --Estímulos
    stim_proc: process
    begin
        -- Caso 1: Todas las señales en '0'
        PLANTA0 <= '0'; PLANTA1 <= '0'; PLANTA2 <= '0'; PLANTA3 <= '0';
        wait for 10 ns;

        -- Caso 2: Señales alternadas
        PLANTA0 <= '1'; PLANTA1 <= '0'; PLANTA2 <= '1'; PLANTA3 <= '0';
        wait for 10 ns;

        -- Caso 3: Todas las señales en '1'
        PLANTA0 <= '1'; PLANTA1 <= '1'; PLANTA2 <= '1'; PLANTA3 <= '1';
        wait for 10 ns;

        -- Caso 4: Señales alternadas
        PLANTA0 <= '0'; PLANTA1 <= '1'; PLANTA2 <= '0'; PLANTA3 <= '1';
        wait for 10 ns;
        -- Finalización simulación
        wait for 600 ns;
        assert false
        report "[PASSED]: simulation finished."
        severity failure;
    end process;
end Behavioral;
