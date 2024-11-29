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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Panel is
    generic (
        Nplantas : positive := 4  -- Número de plantas del ascensor
    );
    port (
        BOTON : in std_logic_vector(Nplantas-1 downto 0); -- Botones que establecen planta deseada
        EMERGENCIA : in std_logic;  -- Aviso de emergencia activo a nivel alto
        FLAGPLANTA : in std_logic_vector(Nplantas-1 downto 0); -- Indicador de si la planta está llena
        PLANTAACTUAL : in std_logic_vector(Nplantas-1 downto 0); -- Planta actual del ascensor
        MOVIMIENTOMOTOR : out std_logic_vector(1 downto 0); -- Orden de movimiento del motor
        SALIDAEMERGENCIA : out std_logic  -- Indicador de emergencia
    );
end Panel;

architecture Behavioral of Panel is
begin

    process(BOTON, EMERGENCIA, FLAGPLANTA, PLANTAACTUAL)
    variable Destino : integer range Nplantas-1 downto 0 := 0; -- Planta a la que se desea ir
    variable PlantaActualInt : integer range Nplantas-1 downto 0 := 0; -- Planta actual como número entero
    variable DestinoEncontrado : boolean := false; -- Indica si se encontró un destino válido
    begin
        PlantaActualInt := to_integer(unsigned(PLANTAACTUAL)); --Convierte la planta actual en número entero
        if EMERGENCIA = '1' then -- Caso de emergencia
            SALIDAEMERGENCIA <= '1'; -- Aviso de emergencia activado
            MOVIMIENTOMOTOR <= "00"; -- Motor detenido
        else -- Si no hay emergencia
            SALIDAEMERGENCIA <= '0'; -- Aviso de emergencia desactivado
            for i in 0 to Nplantas-1 loop
                if BOTON(i) = '1' and FLAGPLANTA(i)= '0' then --Comprueba planta a planta si hay solicitud de ir y su capacidad no está llena
                    Destino := to_integer(unsigned(BOTON)); -- Establecer destino
                    exit;
                 else
                    Destino := PlantaActualInt;
                end if;
            end loop;
            if PlantaActualInt < Destino then --Si la planta a la que se quiere ir es superior al actual
                MOVIMIENTOMOTOR <= "01"; -- Orden de subir al motor
            elsif PlantaActualInt > Destino then --Si la planta a la que se quiere ir es inferior que la actual
                MOVIMIENTOMOTOR <= "10"; -- Orden de bajar al motor
            else --Planta de destino equivale a la actual
                MOVIMIENTOMOTOR <= "00"; -- Motor parado
            end if;
        end if;
    end process;

end Behavioral;
