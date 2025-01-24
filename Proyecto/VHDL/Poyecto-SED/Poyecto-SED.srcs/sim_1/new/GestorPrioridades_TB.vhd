library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Declara la entidad del componente a testear
entity GestorPrioridades_TB is
end GestorPrioridades_TB;

architecture behavioral of GestorPrioridades_TB is
    -- Señales de test
    signal CLK : STD_LOGIC := '0';  -- Reloj
    signal RESET : STD_LOGIC := '0';  -- RESET
    signal PLANTA_PULSADA : STD_LOGIC_VECTOR(3 downto 0) := "0000";  -- Planta pulsada en cabina
    signal PLANTA_LLAMADA : STD_LOGIC_VECTOR(3 downto 0) := "0000";  -- Planta llamada desde fuera
    signal LLENO : STD_LOGIC_VECTOR(3 downto 0) := "0000";  -- Estado de las plantas (1: llena, 0: libre)
    signal ACCION_MOTOR : STD_LOGIC_VECTOR(1 downto 0) := "00";  -- Acción del motor
    signal DESTINO_FINAL : STD_LOGIC_VECTOR(3 downto 0);  -- Destino final del ascensor

    -- Componente a testear
    component GestorPrioridades is
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
    UUT: GestorPrioridades
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
        PLANTA_LLAMADA <= "1000";
        wait for 3*CLK_PERIOD;
         -- Test 2: Botón interno presionado en planta 0 y ascensor parado
        report "TEST 2:";
        PLANTA_PULSADA <= "0001";
        ACCION_MOTOR <= "01";


        -- Test 3: Botón externo pulsado y motor funcionando (almacena)
        report "TEST 3:";
        PLANTA_PULSADA <= "0000";
        PLANTA_LLAMADA <= "0001"; -- Se debe almacenar en PRIORIDADES
        wait for CLK_PERIOD;
        PLANTA_LLAMADA <= "0010"; --Se cambia el valor para comprobar que atiende prioritariamente a lo almacenado y no a lo llamado exteriormente
        ACCION_MOTOR <= "00"; -- Se pone a 0 para ver si se atiende a lo almacenado en PRIORIDADES
        ACCION_MOTOR <= "01" after 20 ns;

        -- Test 4: Motor parado, no hay llamada interna, atención vector prioridades
        report "TEST 4:";
        PLANTA_PULSADA <= "0000";
        PLANTA_LLAMADA <= "0100"; -- Debería almacenarlo porque el motor se pone en movimiento 
        wait for CLK_PERIOD;
        ACCION_MOTOR <= "01"; -- Tras movimiento, se debe ejecutar el if y guardar la planta llamada para después

        -- Test 5: Atención de la petición guardada
        report "TEST 5:";
        ACCION_MOTOR <= "00";
        wait for CLK_PERIOD; -- Debería ir a la planta 2

        -- Test 6: Comprobación del funcionamiento de planta llena
        report "TEST 6:";
        ACCION_MOTOR <= "00"; -- Ya está de antes, es para explicitarlo
        PLANTA_PULSADA <= "0010"; -- En la planta 0 nunca tiene sentido el booleano de lleno
        LLENO <= "0010";
        wait for CLK_PERIOD;
        PLANTA_LLAMADA <= "0000";
        PLANTA_PULSADA <= "0000";
        wait for CLK_PERIOD;
        LLENO <= "0000";

    end process;

end behavioral;