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
        TIEMPO_ABRIR : integer := 200_000_000; --Tiempo que las puertas se están abriendo
        TIEMPO_CERRAR : integer := 200_000_000; --Tiempo que las puertas se están cerrando
        TIEMPO_ABIERTO : integer := 400_000_000; --Tiempo que las puertas permanecen abiertas
        TIEMPO_ESPERA : integer := 100_000_000 --Tiempo con las puertas cerradas hasta que se analiza el nuevo destino
    );
    port (
        DESTINO : in std_logic_vector(Nplantas-1 downto 0); -- Petición para ir a una nueva planta
        EMERGENCIA : in std_logic;  -- Aviso de emergencia activo a nivel alto
        PLANTAACTUAL : in std_logic_vector(Nplantas-1 downto 0); -- Planta actual del ascensor recogido por el sensor
        CLK : in std_logic; --Señal síncrona de reloj
        MOVIMIENTOMOTOR : out std_logic_vector(1 downto 0); -- Orden de movimiento del motor
        MOVIMIENTOPUERTA : out std_logic_vector(1 downto 0); -- Orden de movimiento de la puerta
        SALIDAEMERGENCIA : out std_logic;  -- Indicador de emergencia
        ESTADO_ACTUAL : out std_logic_vector(3 downto 0)--Estado en el que se encuentra el sistema
        );
end FSM;

architecture Behavioral of FSM is
    type STATE_T is (S0_ESPERA, S1_SUBIENDO, S2_BAJANDO, S3_PUERTA_ABRIENDO, S4_PUERTA_ABIERTA, S5_PUERTA_CERRANDO, S6_EMERGENCIA); -- Estado
    signal cur_state : STATE_T := S0_ESPERA; --Estado actuañ
    signal nxt_state : STATE_T; --Siguiente estado al que se transiciona

    signal contador_abrir_i : integer := 0; --Contador del tiempo de apertura de las puertas 
    signal contador_cerrar_i : integer := 0; --Contador del tiempo de cerrado de las puertas
    signal contador_abierto_i : integer := 0; --Contador del tiempo que las puertas permanecen abiertas
    SIGNAL contador_estado_0 : integer :=0; --Contador de tiempo hasta la asimilzación de un nuevo destino
    signal listo_0: std_logic := '0'; --Señal pasa tiempo de asimilación
    signal listo_3: std_logic := '0'; --Señal pasa tiempo de apertura
    signal listo_4: std_logic := '0'; --Señal pasa tiempo abierto
    signal listo_5: std_logic := '0'; --Señal pasa tiempo de cerrado
    
begin 

    -- Proceso de control secuencial
    inicio: process (EMERGENCIA, CLK)
    begin
        if EMERGENCIA = '1' then --Entrada de emergencia asíncrona
            cur_state <= S6_EMERGENCIA; --Se pasa al estado de emergencia
        elsif rising_edge(CLK) then --Con cada flanco de reloj se transiciona al siguiente estado previsto
            cur_state <= nxt_state;
        end if;
    end process;

    -- Proceso de la lógica de transición de estados
    secuencia: process (cur_state, PLANTAACTUAL, DESTINO, listo_0, listo_3, listo_4, listo_5, EMERGENCIA)
    begin
        nxt_state <= cur_state; -- Se conserva el estado actual si no pasa nada

        case cur_state is
            when S0_ESPERA =>
              -- Se incluye tiempo pequeño para que la FSM pueda 
              -- asimilar el nuevo destino que le llega y no permanezca en el estado 0.
              if listo_0 = '1' then      
                if DESTINO /= "0000" then --Destino introducido
                 if unsigned(PLANTAACTUAL) < unsigned(DESTINO) then --Destino mayor que posición actual
                    nxt_state <= S1_SUBIENDO; --Cabina sube
                 elsif unsigned(PLANTAACTUAL) > unsigned(DESTINO) then --Destino menor que posición actual
                    nxt_state <= S2_BAJANDO; --Cabina baja
                 else
                    nxt_state <= S3_PUERTA_ABRIENDO; --Destino seleccionado coincide con posición actual
                end if;
                else 
                    nxt_state <= S0_ESPERA; --Si no se introduce destino se permanece esperando uno
                end if;
              end if;
                
            when S1_SUBIENDO =>
                if PLANTAACTUAL = DESTINO then --Se alcanza el destino
                    nxt_state <= S3_PUERTA_ABRIENDO;
                end if;

            when S2_BAJANDO =>
                if PLANTAACTUAL = DESTINO then --Se alcanza el destino
                    nxt_state <= S3_PUERTA_ABRIENDO;
                end if;

            when S3_PUERTA_ABRIENDO =>
                if  listo_3 = '1' then --Ha transcurrido el tiempo de apertura
                    nxt_state <= S4_PUERTA_ABIERTA;
                end if;

            when S4_PUERTA_ABIERTA =>
                if  listo_4 = '1' then --Ha transcurrido el tiempo abierto
                    nxt_state <= S5_PUERTA_CERRANDO;
                end if;

            when S5_PUERTA_CERRANDO =>
                 if  listo_5 = '1' then --Ha transcurrido el tiempo de cerrado
                    nxt_state <= S0_ESPERA;
                end if;

            when S6_EMERGENCIA =>
                if EMERGENCIA = '0' then --Se desactiva la entrada de emergencia
                    nxt_state <= S0_ESPERA; --Se reinicia el ciclo
                end if;
        end case;
    end process;

    -- Contadores y asignaciones
   temporizadores: process (cur_state, CLK)
    begin
     if rising_edge(CLK) then
        case cur_state is
            when S0_ESPERA =>
                listo_5 <= '0'; --Anula listo del estado anterior y resetea todos los contadores
                contador_abrir_i <= 0;
                contador_abierto_i <= 0;
                contador_cerrar_i <= 0;
                contador_estado_0 <= contador_estado_0 + 1; --Incrementa temporizador de espera para la asimilación
                if contador_estado_0 = TIEMPO_ESPERA - 2 then --Si se alcanza el tiempo establecido se activa la señal de listo
                    listo_0 <= '1';
                end if;

            when S1_SUBIENDO => --Resetea todos los contadores
                contador_abrir_i <= 0;
                contador_abierto_i <= 0;
                contador_cerrar_i <= 0;
                contador_estado_0 <= 0;
                listo_0 <= '0';--Anula el listo del estado anterior
                
            when S2_BAJANDO => --Resetea todos los contadores
                contador_abrir_i <= 0;
                contador_abierto_i <= 0;
                contador_cerrar_i <= 0;
                contador_estado_0 <= 0;
                listo_0 <= '0'; --Anula el listo del estado anterior
                               
            when S3_PUERTA_ABRIENDO => --Resetea todos los contadores
                contador_abierto_i <= 0;
                contador_cerrar_i <= 0;
                contador_estado_0 <= 0;
                listo_0 <= '0'; --Anula el listo del posible estado anterior
                contador_abrir_i <= contador_abrir_i + 1; --Incrementa temporizador de apertura
                if contador_abrir_i = TIEMPO_ABRIR - 2 then --Si se alcanza el tiempo establecido se activa la señal de listo
                 listo_3 <= '1';
                end if;

            when S4_PUERTA_ABIERTA => --Resetea todos los contadores y la señal de listo del estado anterior
                listo_3 <= '0';
                contador_abrir_i <= 0;
                contador_cerrar_i <= 0;
                contador_abierto_i <= contador_abierto_i + 1; --Incrementa temporizador de apertura
                if contador_abierto_i = TIEMPO_ABIERTO - 2 then --Si se alcanza el tiempo establecido se activa la señal de listo
                 listo_4 <= '1';
                end if;

            when S5_PUERTA_CERRANDO =>  --Resetea todos los contadores y la señal de listo del estado anterior
                listo_4 <= '0';
                contador_abrir_i <= 0;
                contador_abierto_i <= 0;
                contador_cerrar_i <= contador_cerrar_i + 1; --Incrementa temporizador de apertura
                if contador_cerrar_i = TIEMPO_CERRAR - 2 then --Si se alcanza el tiempo establecido se activa la señal de listo
                 listo_5 <= '1';
                end if;

            when S6_EMERGENCIA => --resetea todos los contadores y las señales de listo
                contador_abrir_i <= 0;
                contador_abierto_i <= 0;
                contador_cerrar_i <= 0;
                contador_estado_0 <= 0;
                listo_0 <= '0';
                listo_3 <= '0';
                listo_4 <= '0';
                listo_5 <= '0';
                
        end case;
        end if;
    end process;

    -- Salidas de la FSM
    salidas: process (cur_state)
    begin
        case cur_state is
            when S0_ESPERA =>
                MOVIMIENTOMOTOR <= "00"; --Motor cabina no se mueve
                MOVIMIENTOPUERTA <= "00"; --Motor puertas no se mueve
                SALIDAEMERGENCIA <= '0'; --Señal de emergencia no se activa
                ESTADO_ACTUAL <= "0000"; --Estado actual 0

            when S1_SUBIENDO =>
                MOVIMIENTOMOTOR <= "10"; --Motor cabina sube
                MOVIMIENTOPUERTA <= "00"; --Motor puertas no se mueve
                SALIDAEMERGENCIA <= '0'; --Señal de emergencia no se activa
                ESTADO_ACTUAL <= "0001"; --Estado actual 1

            when S2_BAJANDO =>
                MOVIMIENTOMOTOR <= "01";  --Motor cabina baja
                MOVIMIENTOPUERTA <= "00"; --Motor puertas no se mueve
                SALIDAEMERGENCIA <= '0'; --Señal de emergencia no se activa
                ESTADO_ACTUAL <= "0010";  --Estado actual 2

            when S3_PUERTA_ABRIENDO =>
                MOVIMIENTOMOTOR <= "00"; --Motor cabina no se mueve
                MOVIMIENTOPUERTA <= "10"; --Motor puertas abre
                SALIDAEMERGENCIA <= '0'; --Señal de emergencia no se activa
                ESTADO_ACTUAL <= "0011"; --Estado actual 3

            when S4_PUERTA_ABIERTA =>
                MOVIMIENTOMOTOR <= "00"; --Motor cabina no se mueve
                MOVIMIENTOPUERTA <= "00"; --Motor puertas no se mueve
                SALIDAEMERGENCIA <= '0'; --Señal de emergencia no se activa
                ESTADO_ACTUAL <= "0100"; --Estado actual 4

            when S5_PUERTA_CERRANDO => 
                MOVIMIENTOMOTOR <= "00"; --Motor cabina no se mueve
                MOVIMIENTOPUERTA <= "01"; --Motor puertas cierra
                SALIDAEMERGENCIA <= '0'; --Señal de emergencia no se activa
                ESTADO_ACTUAL <= "0101";  --Estado actual 5

            when S6_EMERGENCIA =>
                MOVIMIENTOMOTOR <= "00"; --Motor cabina no se mueve
                MOVIMIENTOPUERTA <= "00"; --Motor puertas no se mueve
                SALIDAEMERGENCIA <= '1'; --Señal de emergencia se activa
                ESTADO_ACTUAL <= "0110";  --Estado actual 6
        end case;
    end process;
end Behavioral;