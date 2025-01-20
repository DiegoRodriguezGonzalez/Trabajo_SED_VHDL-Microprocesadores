----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.11.2024 20:56:33
-- Design Name: 
-- Module Name: COUNTER - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values


-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity COUNTER is
    generic (                                                   
           WIDTH : positive := 4;                               -- Parámetro genérico para mayor flexibilidad (si se aumenta nº plazas)
           MAX_CAPACITY : integer := 5                         -- Número de plazas por planta
    );
    Port ( RESET_N : in STD_LOGIC;                              -- Reset asíncrono activo a nivel bajo. Máxima prioridad
           CE : in STD_LOGIC;                                   -- CHIP ENABLE síncrono
           CLK : in STD_LOGIC;                                  -- Señal de reloj
           CAR_IN : in STD_LOGIC;                               -- Coche entra al parking. Señal síncrona
           CAR_OUT : in STD_LOGIC;                              -- Coche sale del parking. Señal síncrona
           FULL : out STD_LOGIC;                                -- Salida booleana - planta llena
           COUNT : out UNSIGNED (WIDTH-1 downto 0));            -- Valor de cuenta (binario de WIDTH bits)
       
end COUNTER;

architecture Behavioral of COUNTER is
                                             
begin
    cnt: process(CLK,RESET_N)
        variable count_i : UNSIGNED(WIDTH-1 downto 0):= (others => '0');
        variable full_i : STD_LOGIC := '0';    
      begin
        if RESET_N = '0' then                                               -- Si se pide RESET
            count_i := (others => '0');
            full_i := '0';
        elsif RISING_EDGE (CLK) then                                        -- No RESET y R_E de CLK
          if CE = '1' then                                                  -- Chip activado
            if CAR_IN = '1' and full_i = '0' then
                count_i := count_i + 1;                                     -- Añadir coche
            end if;
            if CAR_OUT = '1' and to_integer(count_i) > 0 then
                count_i := count_i - 1;                                     -- Quitar coche
            end if;
          end if;
          --full_i <= '1' when count_i = MAX_CAPACITY else '0';           NO VÁLIDA SI NO ES VHDL 2008
          if to_integer(count_i) = MAX_CAPACITY then full_i := '1'; 
          else full_i := '0';
          end if;
      end if;
      COUNT <= count_i;         
                                           
       FULL <= full_i;  
    end process;
    
     

end Behavioral;
