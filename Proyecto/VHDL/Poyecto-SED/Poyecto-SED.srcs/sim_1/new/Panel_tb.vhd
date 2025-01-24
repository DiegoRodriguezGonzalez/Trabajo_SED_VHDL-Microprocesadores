----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.11.2024 12:09:30
-- Design Name: 
-- Module Name: Panel_tb - TestBench
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


-- Declaración de la entidad del Testbench (sin puertos, ya que es solo para simulación)
entity FSM_tb is
end entity FSM_tb;

architecture TestBench of FSM_tb is

    constant TIEMPO_DESCARGA : positive := 10;

    -- Componentes del panel a probar
    component FSM
        generic (
            Nplantas : positive := 4;  -- Número de plantas
            TIEMPO_ABRIR : positive := 3;  -- Nuevo tiempo de apertura en ciclos (1 us)
            TIEMPO_CERRAR : positive := 3;  -- Nuevo tiempo de cierre en ciclos (1 us)
            TIEMPO_ABIERTO : positive := 3  -- Nuevo tiempo de puertas abiertas (1 us)
        );
        port (
            DESTINO : in std_logic_vector(3 downto 0); -- Ajustado a 4 bits para 4 plantas
            EMERGENCIA : in std_logic;
            PLANTAACTUAL : in std_logic_vector(3 downto 0); -- Ajustado a 4 bits para 4 plantas
            CLK : in std_logic;
            MOVIMIENTOMOTOR : out std_logic_vector(1 downto 0);
            MOVIMIENTOPUERTA : out std_logic_vector(1 downto 0);
            SALIDAEMERGENCIA : out std_logic;
            ESTADO_ACTUAL : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Señales para la instanciación del módulo FSM
    signal DESTINO : std_logic_vector(3 downto 0) := "0000"; -- Planta destino inicial
    signal EMERGENCIA : std_logic := '0'; -- Emergencia desactivada
    signal PLANTAACTUAL : std_logic_vector(3 downto 0) := "0000"; -- Planta actual
    signal CLK : std_logic := '0'; -- Reloj inicializado a 0
    signal MOVIMIENTOMOTOR : std_logic_vector(1 downto 0);
    signal MOVIMIENTOPUERTA : std_logic_vector(1 downto 0);
    signal SALIDAEMERGENCIA : std_logic;
    signal ESTADO_ACTUAL : std_logic_vector(3 downto 0);

begin

    -- Instanciación del módulo FSM
    uut: FSM
        port map (
            DESTINO => DESTINO,
            EMERGENCIA => EMERGENCIA,
            PLANTAACTUAL => PLANTAACTUAL,
            CLK => CLK,
            MOVIMIENTOMOTOR => MOVIMIENTOMOTOR,
            MOVIMIENTOPUERTA => MOVIMIENTOPUERTA,
            SALIDAEMERGENCIA => SALIDAEMERGENCIA,
            ESTADO_ACTUAL => ESTADO_ACTUAL
        );

    -- Generación del reloj (CLK) con ciclo de 1 ns
    clk_process : process
    begin
        CLK <= '0';
        wait for 5 ns;  -- Ajuste a 1 ns para simular en ciclos de 1 ns
        CLK <= '1';
        wait for 5 ns;
    end process;

    -- Estímulos para el testbench
    stimulus_process : process
    begin
         
        -- Caso 1: Prueba de funcionamiento normal (ascensor sube)
        PLANTAACTUAL <= "0001";  -- Planta actual: Planta 0
        DESTINO <= "0010";  -- Destino: Planta 1
        EMERGENCIA <= '0';  -- No hay emergencia
        wait for 50 ns;
        PLANTAACTUAL <= "0010";  -- Llega al destino
        wait for 100 ns;
        
        -- Caso 2: El ascensor baja
        PLANTAACTUAL <= "0100";  -- Planta actual: Planta 2
        DESTINO <= "0001";  -- Destino: Planta 1
        EMERGENCIA <= '0';  -- No hay emergencia
        wait for 50 ns;
        PLANTAACTUAL <= "0010";  -- Planta intermedia
        wait for 100 ns;
        PLANTAACTUAL <= "0100";  -- Llega a la planta destino
        
        
        -- Caso 3: El ascensor llega a la planta de destino y las puertas se abren
        PLANTAACTUAL <= "0001";  -- Planta actual: Planta 1
        DESTINO <= "0001";  -- Destino: Planta 1 (ya se ha llegado)
        EMERGENCIA <= '0';  -- No hay emergencia
        wait for 50 ns;

        -- Caso 4: Emergencia activada
        EMERGENCIA <= '1';  -- Activamos la emergencia
        wait for 50 ns;  -- Esperar un tiempo para observar el comportamiento

        -- Caso 5: Emergencia desactivada y regreso al estado inicial
        EMERGENCIA <= '0';  -- Desactivamos la emergencia
        wait for 50 ns;  -- Esperar un tiempo para observar el comportamiento

        -- Caso 6: El ascensor está en espera sin movimiento
        PLANTAACTUAL <= "0000";  -- Planta actual: Planta 0
        DESTINO <= "0000";  -- No hay destino (ascensor espera)
        wait for 50 ns;  -- Esperar un tiempo para observar el comportamiento

        -- Fin de la simulación
        wait;
    end process;

end architecture TestBench;
