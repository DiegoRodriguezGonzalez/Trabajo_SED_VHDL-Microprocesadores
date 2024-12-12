----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.12.2024 19:54:04
-- Design Name: 
-- Module Name: GestorPrioridades_TB - Behavioral
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
       
         -- Test 2: Botón interno presionado en planta 0 y ascensor parado
        PLANTA_PULSADA <= "0001";
        ACCION_MOTOR <= "00";
        wait for CLK_PERIOD;
        if DESTINO_FINAL /= "0000" then
        ACCION_MOTOR <= "01";
        end if;

        -- Test 3: Botón interno presionado en planta llena y ascensor parado
        LLENO <= "1010";
        PLANTA_PULSADA <= "0010";
        wait for CLK_PERIOD;

        -- Test 4: Botón externo presionado y ascensor parado
        PLANTA_PULSADA <= "0000";
        PLANTA_LLAMADA <= "0100";
        LLENO <= "1000";
        wait for CLK_PERIOD;

        -- Test 5: Botón externo presionado y ascensor en movimiento
        LLENO <= "0000";
        ACCION_MOTOR <= "00";
        PLANTA_LLAMADA <= "1000";
        wait for CLK_PERIOD;

        -- Test 6: Múltiples botones presionados con memoria de prioridades
        PLANTA_LLAMADA <= "0000";
        wait for CLK_PERIOD;
        PLANTA_LLAMADA <= "0000";
        wait for CLK_PERIOD;

        -- Test 7: Limpieza de prioridades al atender llamada
        ACCION_MOTOR <= "00";
        wait for CLK_PERIOD;

        -- Test 8: Repetición de llamada externa ya en memoria
        ACCION_MOTOR <= "10";
        PLANTA_LLAMADA <= "1100"; -- Mismo valor que ya estaba en PRIORIDADES
        wait for CLK_PERIOD;


    end process;

end behavioral;
