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


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FSM is
    generic (
        Nplantas : positive := 4;  -- Número de plantas del ascensor
      	constant TIEMPO_ABRIR : integer := 3;
      	constant TIEMPO_CERRAR : integer := 3;
      	constant TIEMPO_ABIERTO : integer := 3;
      	constant TIEMPO_ESPERA : integer := 3
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

type STATE_T is (S0_ESPERA, S1_SUBIENDO, S2_BAJANDO, S3_PUERTA_ABRIENDO, S4_PUERTA_ABIERTA, S5_PUERTA_CERRANDO, S6_EMERGENCIA); --Estado
signal cur_state :  STATE_T := S0_ESPERA;
signal nxt_state :  STATE_T;

begin 
      inicio: process (EMERGENCIA, CLK)
      begin
      		if EMERGENCIA = '1' then
              cur_state <= S6_EMERGENCIA;
      		elsif rising_edge (CLK)then
              cur_state <= nxt_state;
    		end if;
      end process;
      

   secuencia: process(cur_state, PLANTAACTUAL, DESTINO, CLK)
      
    variable contador_abrir: integer  := 0;
    variable contador_cerrar: integer  := 0;
    variable contador_abierto: integer := 0;
    variable contador_espera: integer := 0;
      
        begin
		  nxt_state <= cur_state; --Se conserva estado actual si no pasa nada
		  
		  case cur_state is
            
            when S0_ESPERA => --Estado de espera antes de recibir orden a realizar
                contador_abrir := contador_abrir+1;
                if contador_abrir = TIEMPO_ABRIR then
                    contador_abrir := 0;
                    if PLANTAACTUAL < DESTINO then
                      nxt_state <= S1_SUBIENDO;
                    elsif PLANTAACTUAL > DESTINO then
                      nxt_state <= S2_BAJANDO;
                     else 
                       nxt_state <= S3_PUERTA_ABRIENDO;
                     end if;
                end if;
            when S1_SUBIENDO => --Estado ascensor sube
            if PLANTAACTUAL = DESTINO then
              nxt_state <= S3_PUERTA_ABRIENDO;
            end if;
            
            when S2_BAJANDO => --Estado ascensor baja
            if PLANTAACTUAL = DESTINO then
              nxt_state <= S3_PUERTA_ABRIENDO;
            end if;
            
            when S3_PUERTA_ABRIENDO => --Estado se abren puertas. Destino alcanzado  
                contador_abrir := contador_abrir + 1;
                if contador_abrir = TIEMPO_ABRIR then
                    contador_abrir := 0;
                    nxt_state <= S4_PUERTA_ABIERTA;
              end if;
            
            when S4_PUERTA_ABIERTA => --Estado puertas permanecen abiertas para salida/entrada.    
                    contador_abierto := contador_abierto + 1;
                if contador_abierto = TIEMPO_ABIERTO then
            		contador_abierto := 0;
                    nxt_state <= S5_PUERTA_CERRANDO;
                end if;
            
            when S5_PUERTA_CERRANDO => --Estado se cierran puertas     
                    contador_cerrar := contador_cerrar + 1;
                if contador_cerrar = TIEMPO_CERRAR then
            		contador_cerrar := 0;
                    nxt_state <= S0_ESPERA;
             	end if;
            
            when S6_EMERGENCIA => --Estado de emergencia
             if EMERGENCIA = '0' then
            	nxt_state <= S0_ESPERA;
            end if;
          end case;
		end process; 

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