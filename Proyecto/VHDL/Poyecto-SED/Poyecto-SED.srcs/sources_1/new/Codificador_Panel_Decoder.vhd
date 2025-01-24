----------------------------------------------------------------------------------
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Codificador_Panel_Decoder is
    generic (
        Nplantas : positive := 4;  -- Número de plantas del ascensor
        Plantas_Bin: positive := 2 --Número de bits+1 que tiene el valor bimario de la planta
    );
    port (
        IN_PLANTA : in std_logic_vector(Nplantas-1 downto 0); --Planta que llega del panel o los sensores (?)
        OUT_PLANTA : out std_logic_vector(Plantas_BIN downto 0); -- Conversión del valor de la planta a binario
        CLK : in std_logic --Señal síncrona de reloj
    );
end Codificador_Panel_Decoder;

architecture Behavioral of Codificador_Panel_Decoder is
    signal OUT_P_i: std_logic_vector(Plantas_BIN downto 0); --Señal planta
    
begin
    codp: process (CLK)
        begin 
        if rising_edge(CLK) then
          case IN_PLANTA is
            when "0001" => OUT_P_i <= "000"; --Planta 0
            when "0010" => OUT_P_i <= "001"; --Planta 1
            when "0100" => OUT_P_i <= "010"; --Planta 2
            when "1000" => OUT_P_i <= "011"; --Planta 3
            when others => OUT_P_i <="100";  --Emergencia
          end case;
        end if;
    end process;
    OUT_PLANTA <= OUT_P_i;

end Behavioral;