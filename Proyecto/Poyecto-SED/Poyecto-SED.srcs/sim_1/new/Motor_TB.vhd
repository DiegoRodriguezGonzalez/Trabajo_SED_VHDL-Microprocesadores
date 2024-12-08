----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.12.2024 18:33:05
-- Design Name: 
-- Module Name: Motor_TB - Behavioral
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

entity Motor_tb is
    -- El testbench no necesita puertos
end Motor_tb;

architecture Behavioral of Motor_tb is
    -- Componentes y señales internas
    component Motores
        Generic(
            TIPO : integer := 0 -- Motor de elevación
        );
        Port (
            CLK        : in  STD_LOGIC;
            RESET_N    : in  STD_LOGIC;
            ACCION     : in  STD_LOGIC_VECTOR(1 downto 0);
            MOTOR      : out STD_LOGIC_VECTOR(1 downto 0);
            TIPO_MOTOR : out integer
        );
    end component;

    -- Señales internas para conectar a la UUT (UNIT Under Test)
    signal CLK        : STD_LOGIC := '0';
    signal RESET_N    : STD_LOGIC := '1';
    signal ACCION     : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal MOTOR      : STD_LOGIC_VECTOR(1 downto 0);
    signal TIPO_MOTOR : integer;

    -- Parámetro del tipo de motor
    constant TIPO : integer := 0; 
begin
    -- Instancia del módulo Motor
    UUT: Motores
        generic map (
            TIPO => TIPO
        )
        port map (
            CLK => CLK,
            RESET_N => RESET_N,
            ACCION => ACCION,
            MOTOR => MOTOR,
            TIPO_MOTOR => TIPO_MOTOR
        );

    -- Generador de reloj
    clock_gen: process
    begin
     for I in 0 to 10 loop
            CLK <= '1';
            wait for 10 ns;
            CLK <= '0';
            wait for 10 ns;
     end loop;
    end process;

    -- Proceso de prueba
    stim: process
    begin
        -- Emergencia activa
        RESET_N <= '0';
        wait for 30 ns;

        -- Salida de reinicio
        RESET_N <= '1';
        wait for 5 ns;

        -- Probar acción: "10" (subir)
        ACCION <= "10";
        wait for 10 ns;

        -- Probar acción: "01" (bajar)
        ACCION <= "01";
        wait for 10 ns;

        -- Probar acción: "00" (parada)
        ACCION <= "00";
        wait for 10 ns;

        -- Probar acción no esperada (por ejemplo, "11")
        ACCION <= "11";
        wait for 40 ns;

    end process;
end Behavioral;
