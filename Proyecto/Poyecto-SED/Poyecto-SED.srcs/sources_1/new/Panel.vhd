----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.11.2024 11:42:12
-- Design Name: 
-- Module Name: Panel - Behavioral
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
use IEEE.NUMERIC_STD.ALL; -- Para convertir entre std_logic_vector e integer

entity FSM is
    generic (
        Nplantas : positive := 4;  -- Número de plantas del ascensor
        TIEMPO_ABRIR : integer := 3;
        TIEMPO_CERRAR : integer := 3;
        TIEMPO_ABIERTO : integer := 3;
        TIEMPO_ESPERA : integer := 3
    );
    port (
        DESTINO : in std_logic_vector(Nplantas-1 downto 0); -- Petición para ir a una nueva planta
        EMERGENCIA : in std_logic;  -- Aviso de emergencia activo a nivel alto
        PLANTAACTUAL : in std_logic_vector(Nplantas-1 downto 0); -- Planta actual del ascensor recogido por el sensor
        CLK : in std_logic;
        MOVIMIENTOMOTOR : out std_logic_vector(1 downto 0); -- Orden de movimiento del motor
        MOVIMIENTOPUERTA : out std_logic_vector(1 downto 0); -- Orden de movimiento de la puerta
        SALIDAEMERGENCIA : out std_logic;  -- Indicador de emergencia
        ESTADO_ACTUAL : out std_logic_vector(3 downto 0)
        );
end FSM;

architecture Behavioral of FSM is
    type STATE_T is (S0_ESPERA, S1_SUBIENDO, S2_BAJANDO, S3_PUERTA_ABRIENDO, S4_PUERTA_ABIERTA, S5_PUERTA_CERRANDO, S6_EMERGENCIA); -- Estado
    signal cur_state : STATE_T := S0_ESPERA;
    signal nxt_state : STATE_T;

    signal contador_abrir_i : integer := 0;
    signal contador_cerrar_i : integer := 0;
    signal contador_abierto_i : integer := 0;
    signal contador_espera_i : integer := 0;
    signal listo_0: std_logic := '0';
    signal listo_3: std_logic := '0';
    signal listo_4: std_logic := '0';
    signal listo_5: std_logic := '0';
    
begin 

    -- Proceso de control secuencial
    inicio: process (EMERGENCIA, CLK)
    begin
        if EMERGENCIA = '1' then
            cur_state <= S6_EMERGENCIA;
        elsif rising_edge(CLK) then
            cur_state <= nxt_state;
        end if;
    end process;

    -- Proceso de la lógica de transición de estados
    secuencia: process (cur_state, PLANTAACTUAL, DESTINO, listo_0, listo_3, listo_4, listo_5)
    begin
        nxt_state <= cur_state; -- Se conserva el estado actual si no pasa nada

        case cur_state is
            when S0_ESPERA =>
                if listo_0 = '1' then 
                 if unsigned(PLANTAACTUAL) < unsigned(DESTINO) then
                    nxt_state <= S1_SUBIENDO;
                 elsif unsigned(PLANTAACTUAL) > unsigned(DESTINO) then
                    nxt_state <= S2_BAJANDO;
                 else
                    nxt_state <= S3_PUERTA_ABRIENDO;
                end if;
                end if;
                
            when S1_SUBIENDO =>
                if PLANTAACTUAL = DESTINO then
                    nxt_state <= S3_PUERTA_ABRIENDO;
                end if;

            when S2_BAJANDO =>
                if PLANTAACTUAL = DESTINO then
                    nxt_state <= S3_PUERTA_ABRIENDO;
                end if;

            when S3_PUERTA_ABRIENDO =>
                if  listo_3 = '1' then
                    nxt_state <= S4_PUERTA_ABIERTA;
                end if;

            when S4_PUERTA_ABIERTA =>
                if  listo_4 = '1' then
                    nxt_state <= S5_PUERTA_CERRANDO;
                end if;

            when S5_PUERTA_CERRANDO =>
                 if  listo_5 = '1' then
                    nxt_state <= S0_ESPERA;
                end if;

            when S6_EMERGENCIA =>
                if EMERGENCIA = '0' then
                    nxt_state <= S0_ESPERA;
                end if;
        end case;
    end process;

    -- Contadores y asignaciones
   temporizadores: process (cur_state, CLK)
    begin
     if rising_edge(CLK) then
        case cur_state is
            when S0_ESPERA =>
                listo_5 <= '0';
                contador_abrir_i <= 0;
                contador_abierto_i <= 0;
                contador_cerrar_i <= 0;
                contador_espera_i <= contador_espera_i + 1;
                if contador_espera_i >= TIEMPO_ESPERA -2 then
                 listo_0 <= '1';
                end if;
                
                when S1_SUBIENDO =>
                listo_0 <= '0';
                contador_abrir_i <= 0;
                contador_abierto_i <= 0;
                contador_cerrar_i <= 0;
                contador_espera_i <= 0;
                
                when S2_BAJANDO =>
                listo_0 <= '0';
                contador_abrir_i <= 0;
                contador_abierto_i <= 0;
                contador_cerrar_i <= 0;
                contador_espera_i <= 0;
                
            when S3_PUERTA_ABRIENDO =>
                listo_0 <= '0';
                contador_abierto_i <= 0;
                contador_cerrar_i <= 0;
                contador_espera_i <= 0;
                contador_abrir_i <= contador_abrir_i + 1;
                if contador_abrir_i = TIEMPO_ABRIR - 2 then
                 listo_3 <= '1';
                end if;

            when S4_PUERTA_ABIERTA =>
                listo_3 <= '0';
                contador_abrir_i <= 0;
                contador_cerrar_i <= 0;
                contador_espera_i <= 0;
                contador_abierto_i <= contador_abierto_i + 1;
                if contador_abierto_i = TIEMPO_ABIERTO - 2 then
                 listo_4 <= '1';
                end if;

            when S5_PUERTA_CERRANDO =>
                listo_4 <= '0';
                contador_abrir_i <= 0;
                contador_abierto_i <= 0;
                contador_espera_i <= 0;
                contador_cerrar_i <= contador_cerrar_i + 1;
                if contador_cerrar_i = TIEMPO_CERRAR - 2 then
                 listo_5 <= '1';
                end if;

            when S6_EMERGENCIA =>
                contador_abrir_i <= 0;
                contador_abierto_i <= 0;
                contador_cerrar_i <= 0;
                contador_espera_i <= 0;
        end case;
        end if;
    end process;

    -- Salidas de la FSM
    salidas: process (cur_state)
    begin
        case cur_state is
            when S0_ESPERA =>
                MOVIMIENTOMOTOR <= "00";
                MOVIMIENTOPUERTA <= "00";
                SALIDAEMERGENCIA <= '0';
                ESTADO_ACTUAL <= "0000"; 

            when S1_SUBIENDO =>
                MOVIMIENTOMOTOR <= "10";
                MOVIMIENTOPUERTA <= "00";
                SALIDAEMERGENCIA <= '0';
                ESTADO_ACTUAL <= "0001"; 

            when S2_BAJANDO =>
                MOVIMIENTOMOTOR <= "01";
                MOVIMIENTOPUERTA <= "00";
                SALIDAEMERGENCIA <= '0';
                ESTADO_ACTUAL <= "0010"; 

            when S3_PUERTA_ABRIENDO =>
                MOVIMIENTOMOTOR <= "00";
                MOVIMIENTOPUERTA <= "10";
                SALIDAEMERGENCIA <= '0';
                ESTADO_ACTUAL <= "0011"; 

            when S4_PUERTA_ABIERTA =>
                MOVIMIENTOMOTOR <= "00";
                MOVIMIENTOPUERTA <= "00";
                SALIDAEMERGENCIA <= '0';
                ESTADO_ACTUAL <= "0100"; 

            when S5_PUERTA_CERRANDO =>
                MOVIMIENTOMOTOR <= "00";
                MOVIMIENTOPUERTA <= "01";
                SALIDAEMERGENCIA <= '0';
                ESTADO_ACTUAL <= "0101"; 

            when S6_EMERGENCIA =>
                MOVIMIENTOMOTOR <= "00";
                MOVIMIENTOPUERTA <= "00";
                SALIDAEMERGENCIA <= '1';
                ESTADO_ACTUAL <= "0110"; 
        end case;
    end process;
end Behavioral;