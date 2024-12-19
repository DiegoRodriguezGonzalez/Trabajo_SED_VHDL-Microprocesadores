library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity GestiorPrioridad2_TB is
--  Port ( );
end GestiorPrioridad2_TB;

architecture Behavioral of GestiorPrioridad2_TB is

    -- Señales de test
    signal CLK : STD_LOGIC := '0';  -- Reloj
    signal RESET : STD_LOGIC := '0';  -- RESET
    signal PLANTA_PULSADA : STD_LOGIC_VECTOR(3 downto 0) := "0000";  -- Planta pulsada en cabina
    signal PLANTA_LLAMADA : STD_LOGIC_VECTOR(3 downto 0) := "0000";  -- Planta llamada desde fuera
    signal LLENO : STD_LOGIC_VECTOR(3 downto 0) := "0000";  -- Estado de las plantas (1: llena, 0: libre)
    signal ACCION_MOTOR : STD_LOGIC_VECTOR(1 downto 0) := "00";  -- Acción del motor
    signal DESTINO_FINAL : STD_LOGIC_VECTOR(3 downto 0);  -- Destino final del ascensor

    -- Componente a testear
    component GestorPrioridades2 is
        Generic(
            NUMERO_PLANTAS: INTEGER := 4
        );
        Port ( 
            CLK : in STD_LOGIC;  
            RESET : in STD_LOGIC;    
            PLANTA_PULSADA : in STD_LOGIC_VECTOR (3 downto 0);  
            PLANTA_LLAMADA : in STD_LOGIC_VECTOR (3 downto 0);  
            LLENO : in STD_LOGIC_VECTOR (3 downto 0);  
            ACCION_MOTOR : in STD_LOGIC_VECTOR (1 downto 0); 
            DESTINO_FINAL : out STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;

    -- Generación del reloj
    constant CLK_PERIOD : time := 10 ns;

    begin
    -- Instanciación del gestor
    UUT: GestorPrioridades2
        port map (
            CLK => CLK,
            RESET => RESET,
            PLANTA_PULSADA => PLANTA_PULSADA,
            PLANTA_LLAMADA => PLANTA_LLAMADA,
            LLENO => LLENO,
            ACCION_MOTOR => ACCION_MOTOR,
            DESTINO_FINAL => DESTINO_FINAL
        );

    -- Generación de reloj
    CLK_process :process
    begin
        CLK <= '0';
        wait for CLK_PERIOD / 2;
        CLK <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Estímulos de prueba
    reset_est: process
    begin
        -- Test 1: RESET
        RESET <= '1';
        wait for 20 ns;
        RESET <= '0';
        wait for 100 ns;        
    end process;
    
    stim_proc: process
    begin
        wait for 3*CLK_PERIOD;
         -- Test 2: Botón interno presionado en planta 0 y ascensor parado
        report "TEST 2:";
        PLANTA_PULSADA <= "0001";
        ACCION_MOTOR <= "00";
        wait for CLK_PERIOD;
        ACCION_MOTOR <= "01";

        -- Test 3: Botón interno/externo pulsado y motor funcionando (ignora)
        report "TEST 3:";
        PLANTA_PULSADA <= "0010";
        PLANTA_LLAMADA <= "0000"; 
        wait for CLK_PERIOD;
        PLANTA_PULSADA <= "0000";
        PLANTA_LLAMADA <= "0010";
        ACCION_MOTOR <= "00" after 10 ns;

        -- Test 4: Motor parado, llamada interna, comprobación planta llena
        report "TEST 4:";
        PLANTA_PULSADA <= "0100";
        PLANTA_LLAMADA <= "0010"; 
        ACCION_MOTOR <= "01";
        LLENO <= "0100";
        wait for CLK_PERIOD;
        ACCION_MOTOR <= "00"; 
        
        -- Test 5: Llamada externa con planta llena, debe hacerla
        report "TEST 5:";
        PLANTA_PULSADA <= "0000";
        PLANTA_LLAMADA <= "0010"; 
        LLENO <= "0010";
        ACCION_MOTOR <= "01";
        wait for CLK_PERIOD; -- Debería ir a la planta 2
        ACCION_MOTOR <= "00";
        
    end process;

end Behavioral;
