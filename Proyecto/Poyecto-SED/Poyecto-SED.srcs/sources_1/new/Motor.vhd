library ieee;
use ieee.std_logic_1164.all;

entity Motor is
    generic
    (
        constant speed: integer :=19_000    -- Velocidad del motor
    );
    port(
        CLK : in std_logic; -- Reloj
        ORDEN_MOTOR : in std_logic_vector(1 downto 0); -- Orden de subir, bajar o quieto
        PWM1, PWM2 : out std_logic -- Salidas PWM para el motor
    );
end Motor;

architecture Behavioral of Motor is
  signal count: integer range 0 to 50_000 := 0; 

begin
process(CLK)
begin
    if rising_edge(CLK) then
        -- Se incrementa el contador para ajustar el PWM (ciclo de trabajo de 0,6)
        count <= count + 1;
        if (count = 49_999) then
            count <= 0;
        end if;

        -- Generar señal PWM 
        if (count < speed) then
            case ORDEN_MOTOR is
                when "10" =>        -- Motor sube
                    PWM1 <= '1';
                    PWM2 <= '0';
                when "01" =>        -- Motor baja
                    PWM1 <= '0';
                    PWM2 <= '1';
                when others =>      -- Ascensor quieto
                    PWM1 <= '0';
                    PWM2 <= '0';
            end case;
        else                        -- En cualquier otro caso está quieto
            PWM1 <= '0';
            PWM2 <= '0';
        end if;
    end if;
end process;
end Behavioral;

