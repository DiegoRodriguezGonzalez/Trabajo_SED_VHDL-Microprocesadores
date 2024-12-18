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

entity Codificador_Panel_Decoder_tb is
end Codificador_Panel_Decoder_tb;

architecture TestBench of Codificador_Panel_Decoder_tb is

    -- Component Declaration for the Unit Under Test (UUT)
    component Codificador_Panel_Decoder
        generic (
            Nplantas : positive := 4;  -- Número de plantas del ascensor
            Plantas_Bin: positive := 2 -- Número de bits+1 que tiene el valor binario de la planta
        );
        port (
            IN_PLANTA : in std_logic_vector(Nplantas-1 downto 0); -- Planta que llega del panel o los sensores
            OUT_PLANTA : out std_logic_vector(Plantas_Bin downto 0); -- Conversión del valor de la planta a binario
            CLK : in std_logic -- Señal síncrona de reloj
        );
    end component;

    -- Signals for the testbench
    signal IN_PLANTA_tb : std_logic_vector(3 downto 0);  -- Entrada de planta (4 bits)
    signal OUT_PLANTA_tb : std_logic_vector(2 downto 0);  -- Salida de planta (2 bits)
    signal CLK_tb : std_logic := '0';  -- Reloj de prueba (inicialmente '0')

    -- Clock period
    constant clk_period : time := 10 ns; 

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: Codificador_Panel_Decoder
        generic map (
            Nplantas => 4,  -- Número de plantas
            Plantas_Bin => 2  -- 2 bits de salida
        )
        port map (
            IN_PLANTA => IN_PLANTA_tb,
            OUT_PLANTA => OUT_PLANTA_tb,
            CLK => CLK_tb
        );

    -- Clock process
    clk_process :process
    begin
        CLK_tb <= '0';
        wait for clk_period / 2;
        CLK_tb <= '1';
        wait for clk_period / 2;
    end process;

    -- Stimulus process
    stimulus_process: process
    begin
        -- Test 1: Planta 0
        IN_PLANTA_tb <= "0001";  -- Planta 0
        wait for clk_period;
        assert (OUT_PLANTA_tb = "00") report "Error: Planta 0" severity error;

        -- Test 2: Planta 1
        IN_PLANTA_tb <= "0010";  -- Planta 1
        wait for clk_period;
        assert (OUT_PLANTA_tb = "01") report "Error: Planta 1" severity error;

        -- Test 3: Planta 2
        IN_PLANTA_tb <= "0100";  -- Planta 2
        wait for clk_period;
        assert (OUT_PLANTA_tb = "10") report "Error: Planta 2" severity error;

        -- Test 4: Planta 3
        IN_PLANTA_tb <= "1000";  -- Planta 3
        wait for clk_period;
        assert (OUT_PLANTA_tb = "11") report "Error: Planta 3" severity error;

        -- Test 5: Estado de emergencia (ninguna planta)
        IN_PLANTA_tb <= "1111";  -- Entrada de emergencia (ninguna planta válida)
        wait for clk_period;
        assert (OUT_PLANTA_tb = "10") report "Error: Emergencia" severity error;

        -- End simulation
        wait;
    end process;

end TestBench;

