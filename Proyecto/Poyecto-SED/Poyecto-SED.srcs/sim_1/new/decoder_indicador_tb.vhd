library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decoder_indicador_tb is
end decoder_indicador_tb;

architecture Behavioral of decoder_indicador_tb is
  -- Instancia del UUT (Unit Under Test)
  component decoder_indicador is
    generic (                                                   
           NPLANTAS : positive := 2
    ); 
    Port (
      PLANTA : in std_logic_vector (NPLANTAS downto 0);
      EMER   : in std_logic;
      MOTOR_ASCENSOR : in std_logic_vector(1 downto 0);
      LED_PANTALLA   : out std_logic_vector(6 downto 0)
    );
  end component;
  
  -- Señales internas para conectar con la entidad bajo prueba
  signal PLANTA : std_logic_vector(2 downto 0);
  signal EMER   : std_logic;
  signal MOTOR_ASCENSOR : std_logic_vector(1 downto 0);
  signal LED_PANTALLA   : std_logic_vector(6 downto 0);

begin
  -- Instancia de la unidad bajo prueba
  uut: decoder_indicador
    generic map (                                                   
      NPLANTAS => 2
    ) 
    Port Map (
      PLANTA => PLANTA,
      EMER => EMER,
      MOTOR_ASCENSOR => MOTOR_ASCENSOR,
      LED_PANTALLA => LED_PANTALLA
    );

  -- Estímulos
  estimulos: process
  begin
    -- Caso 1: Emergencia activada
    EMER <= '1';
    PLANTA <= "000";
    MOTOR_ASCENSOR <= "00";
    wait for 10 ns;
    assert (LED_PANTALLA = "1111110") report "Error: EMER activada no muestra raya correctamente" severity error;

    -- Caso 2: Motor apagado (MOTOR_ASCENSOR = "00") y planta específica
    EMER <= '0';
    MOTOR_ASCENSOR <= "00";

    PLANTA <= "000"; wait for 10 ns;
    assert (LED_PANTALLA = "0000001") report "Error: Planta 0 no se muestra correctamente" severity error;

    PLANTA <= "001"; wait for 10 ns;
    assert (LED_PANTALLA = "1001111") report "Error: Planta 1 no se muestra correctamente" severity error;

    PLANTA <= "010"; wait for 10 ns;
    assert (LED_PANTALLA = "0010010") report "Error: Planta 2 no se muestra correctamente" severity error;

    PLANTA <= "011"; wait for 10 ns;
    assert (LED_PANTALLA = "0000110") report "Error: Planta 3 no se muestra correctamente" severity error;

    PLANTA <= "100"; wait for 10 ns;
    assert (LED_PANTALLA = "1111110") report "Error: Planta inválida no muestra emergencia correctamente" severity error;

    -- Caso 3: Motor subiendo (MOTOR_ASCENSOR = "10")
    MOTOR_ASCENSOR <= "10";
    wait for 10 ns;
    assert (LED_PANTALLA = "0100100") report "Error: Motor subiendo no muestra S correctamente" severity error;

    -- Caso 4: Motor bajando (MOTOR_ASCENSOR = "01")
    MOTOR_ASCENSOR <= "01";
    wait for 10 ns;
    assert (LED_PANTALLA = "0000000") report "Error: Motor bajando no muestra B correctamente" severity error;

    -- Caso 5: Condición inválida para MOTOR_ASCENSOR
    MOTOR_ASCENSOR <= "11";
    wait for 10 ns;
    assert (LED_PANTALLA = "1111110") report "Error: MOTOR_ASCENSOR inválido no muestra emergencia correctamente" severity error;

    -- Fin de la simulación
    wait;
  end process;
end Behavioral;
