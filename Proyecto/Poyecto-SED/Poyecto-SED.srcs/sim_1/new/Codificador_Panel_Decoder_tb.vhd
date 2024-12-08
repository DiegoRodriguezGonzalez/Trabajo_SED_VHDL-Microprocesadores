-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.12.2024 13:15:55
-- Design Name: 
-- Module Name: Codificador_Panel_Decoder - Behavioral
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

-- Entidad del testbench
entity Codificador_Panel_Decoder_tb is
-- No tiene puertos porque es un testbench
end Codificador_Panel_Decoder_tb;

architecture TestBench of Codificador_Panel_Decoder_tb is
    -- Declaración de señales para conectar con el DUT (Device Under Test)
    constant Nplantas : positive := 4;
    constant Plantas_Bin : positive := 2;
    
    signal IN_PLANTA : std_logic_vector(Nplantas-1 downto 0);
    signal IN_EMERGENCIA : std_logic;
    signal IN_MOTOR : std_logic_vector(1 downto 0);
    signal OUT_PLANTA : std_logic_vector(Plantas_Bin downto 0);
    signal OUT_MOTOR : std_logic_vector(1 downto 0);
    signal OUT_EMERGENCIA : std_logic;
    signal CLK : std_logic := '0';

    -- Instancia del diseño a probar (DUT)
    component Codificador_Panel_Decoder is
        generic (
            Nplantas : positive := 4;
            Plantas_Bin: positive := 2
        );
        port (
            IN_PLANTA : in std_logic_vector(Nplantas-1 downto 0);
            IN_EMERGENCIA : in std_logic;
            IN_MOTOR : in std_logic_vector(1 downto 0);
            OUT_PLANTA : out std_logic_vector(Plantas_Bin downto 0);
            OUT_MOTOR : out std_logic_vector(1 downto 0);
            OUT_EMERGENCIA : out std_logic;
            CLK : in std_logic
        );
    end component;

begin
    -- Instanciamos el UUT
    UUT: Codificador_Panel_Decoder
        generic map (
            Nplantas => Nplantas,
            Plantas_Bin => Plantas_Bin
        )
        port map (
            IN_PLANTA => IN_PLANTA,
            IN_EMERGENCIA => IN_EMERGENCIA,
            IN_MOTOR => IN_MOTOR,
            OUT_PLANTA => OUT_PLANTA,
            OUT_MOTOR => OUT_MOTOR,
            OUT_EMERGENCIA => OUT_EMERGENCIA,
            CLK => CLK
        );

    -- Generador de reloj
    process
    begin
        while true loop
            CLK <= not CLK;
            wait for 10 ns; -- Periodo de reloj 20 ns
        end loop;
    end process;

    -- Proceso de estimulación
    process
    begin
        -- Inicialización de señales
        IN_EMERGENCIA <= '0';
        IN_MOTOR <= "00";
        IN_PLANTA <= "0001";
        wait for 20 ns;

        -- Prueba: Motor parado, planta 0
        IN_PLANTA <= "0001";
        wait for 20 ns;
        assert (OUT_PLANTA = "000") report "Error: Planta 0 no detectada correctamente." severity error;

        -- Prueba: Motor parado, planta 1
        IN_PLANTA <= "0010";
        wait for 20 ns;
        assert (OUT_PLANTA = "001") report "Error: Planta 1 no detectada correctamente." severity error;

        -- Prueba: Motor subiendo
        IN_MOTOR <= "10";
        wait for 20 ns;
        assert (OUT_MOTOR = "01") report "Error: Movimiento subiendo no detectado correctamente." severity error;

        -- Prueba: Motor bajando
        IN_MOTOR <= "01";
        wait for 20 ns;
        assert (OUT_MOTOR = "10") report "Error: Movimiento bajando no detectado correctamente." severity error;

        -- Prueba: Emergencia
        IN_EMERGENCIA <= '1';
        wait for 20 ns;
        assert (OUT_EMERGENCIA = '0') report "Error: Emergencia no detectada correctamente." severity error;

        -- Finalizamos la simulación
        wait;
    end process;

end TestBench;
