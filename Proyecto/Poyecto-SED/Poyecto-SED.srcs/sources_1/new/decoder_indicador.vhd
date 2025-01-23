library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decoder_indicador is

  generic (                                                   
    NPLANTAS : positive := 2                             -- Parámetro genérico para mayor flexibilidad (si se aumenta nº plantas)
  );

  Port (
    PLANTA : in std_logic_vector (NPLANTAS downto 0);     -- Indica la planta. En total 4
    EMER  : in std_logic;
    MOTOR_ASCENSOR : in std_logic_vector(1 downto 0);  -- Motor indica subiendo o bajando
    LED_PANTALLA  : out std_logic_vector(6 downto 0)   -- Se muestra por los segmentos el número o letra
  );
end decoder_indicador;

architecture Behavioral of decoder_indicador is
    
begin
  process (EMER,PLANTA,MOTOR_ASCENSOR)
  begin
    if EMER = '1' then
      LED_PANTALLA <= "1111110";        -- Se pone una raya. Equivale a emergencia
    elsif MOTOR_ASCENSOR = "00" then
      case PLANTA is
        when "000" => LED_PANTALLA <= "0000001";    -- Se representa un 0
        when "001" => LED_PANTALLA <= "1001111";    -- Se representa un 1   
        when "010" => LED_PANTALLA <= "0010010";    -- Se representa un 2
        when "011" => LED_PANTALLA <= "0000110";    -- Se representa un 3
        when others => LED_PANTALLA <="1111110";    --Lo mismo que emer
      end case;
    else
      case MOTOR_ASCENSOR is
        when "01" => LED_PANTALLA <= "0000000";  -- Ascensor bajando. Se representa con B
        when "10" => LED_PANTALLA <= "0100100";  -- Ascensor subiendo. Se representa con S
        when others => LED_PANTALLA <= "1111110";          --Lo mismo que emer
      end case;
    end if;
  end process;
end Behavioral;
