----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.12.2024 17:56:30
-- Design Name: 
-- Module Name: Motor - Behavioral
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

entity Motores is
    Generic(
           TIPO : integer :=0 -- 0: motor elevación // 1: motor de fuerza (puertas)
    );
    Port ( CLK : in STD_LOGIC; -- Señal de reloj
           RESET_N : in STD_LOGIC; -- Señal de reinicio(emergencia)
           ACCION : in STD_LOGIC_VECTOR (1 downto 0); -- Acción a tratar
           MOTOR : out STD_LOGIC_VECTOR (1 downto 0); -- Resultado del bloque Motor
           TIPO_MOTOR: out integer -- Tipo de motor
           );
           
end Motores;

architecture Behavioral of Motores is

begin
TIPO_MOTOR <= TIPO; -- Asignación del tipo de motor útil para conocer aguas abajo si es el de puerta o el de la cabina
proceso_motor: process (CLK, RESET_N)
  begin
    if RESET_N = '0' then
        MOTOR <= "00";  -- Parada motor
    elsif rising_edge (CLK) then
        case ACCION is
            when "10" => 
            MOTOR <= "10"; -- Giro antihorario (subir)
            when "01" => 
            MOTOR <= "01"; -- Giro horario (bajar)
            when others => 
            MOTOR <= "00"; -- Parada               
        end case;
    end if;
  end process;
end Behavioral;
