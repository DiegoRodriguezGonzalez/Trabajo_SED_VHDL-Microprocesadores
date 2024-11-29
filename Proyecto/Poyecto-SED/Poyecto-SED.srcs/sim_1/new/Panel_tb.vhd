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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Panel_tb is
-- No hay puertos en el testbench
end Panel_tb;

architecture TestBench of Panel_tb is
    -- Parámetros del módulo
    constant Nplantas : positive := 4; -- Número de plantas
    
    -- Señales para conectar al módulo
    signal BOTON : std_logic_vector(Nplantas-1 downto 0);
    signal EMERGENCIA : std_logic;
    signal FLAGPLANTA : std_logic_vector(Nplantas-1 downto 0);
    signal PLANTAACTUAL : std_logic_vector(Nplantas-1 downto 0);
    signal MOVIMIENTOMOTOR : std_logic_vector(1 downto 0);
    signal SALIDAEMERGENCIA : std_logic;

    -- Instancia del módulo bajo prueba (Unit Under Test, UUT)
    component Panel is
        generic (
            Nplantas : positive := 4
        );
        port (
            BOTON : in std_logic_vector(Nplantas-1 downto 0);
            EMERGENCIA : in std_logic;
            FLAGPLANTA : in std_logic_vector(Nplantas-1 downto 0);
            PLANTAACTUAL : std_logic_vector(Nplantas-1 downto 0);
            MOVIMIENTOMOTOR : out std_logic_vector(1 downto 0);
            SALIDAEMERGENCIA : out std_logic
        );
    end component;

begin
    -- Instanciación del módulo
    uut: Panel
        generic map (
            Nplantas => Nplantas
        )
        port map (
            BOTON => BOTON,
            EMERGENCIA => EMERGENCIA,
            FLAGPLANTA => FLAGPLANTA,
            PLANTAACTUAL => PLANTAACTUAL,
            MOVIMIENTOMOTOR => MOVIMIENTOMOTOR,
            SALIDAEMERGENCIA => SALIDAEMERGENCIA
        );

    -- Proceso de estimulación
    stim_proc: process
    begin
        -- Caso 1: Sin emergencia, planta actual en 0, destino a 2
        PLANTAACTUAL <= "0001" ;
        EMERGENCIA <= '0';
        BOTON <= "0100"; -- Solicitud de planta 2
        FLAGPLANTA <= "0000"; -- Ninguna planta llena
        wait for 10 ns;

        -- Caso 2: Solicitar planta 3, pero está llena
        BOTON <= "1000"; -- Solicitud de planta 3
        FLAGPLANTA <= "1000"; -- Planta 3 está llena
        wait for 10 ns;

        -- Caso 3: Emergencia activada
        EMERGENCIA <= '1';
        BOTON <= "0100"; -- Solicitud de planta 2 (sin efecto por emergencia)
        wait for 10 ns;

        -- Caso 4: Sin emergencia, planta actual en 2, destino a 0
        EMERGENCIA <= '0';
        PLANTAACTUAL <= "0100";
        BOTON <= "0001"; -- Solicitud de planta 0
        FLAGPLANTA <= "0000"; -- Ninguna planta llena
        wait for 10 ns;

        -- Caso 5: Planta solicitada es la misma en la que está
        PLANTAACTUAL <= "0001";
        BOTON <= "0001"; -- Solicitud de planta 0
        wait for 10 ns;

        -- Finalizar simulación
        wait;
    end process;

end TestBench;
