library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity COUNTER_tb is                        -- El testbench no tiene puertos
end COUNTER_tb;

architecture behavioral of COUNTER_tb is
-- Instancia de la unidad bajo prueba (COUNTER)
 component COUNTER is
       generic (                                                   
           WIDTH : positive := 4;                               -- Parámetro genérico para mayor flexibilidad (si se aumenta nº plazas)
           MAX_CAPACITY : integer := 15                         -- Número de plazas por planta
        );
        Port ( RESET_N : in STD_LOGIC;                          -- Reset asíncrono activo a nivel bajo. Máxima prioridad
           CE : in STD_LOGIC;                                   -- CHIP ENABLE síncrono
           CLK : in STD_LOGIC;                                  -- Señal de reloj
           CAR_IN : in STD_LOGIC;                               -- Coche entra al parking. Señal síncrona
           CAR_OUT : in STD_LOGIC;                              -- Coche sale del parking. Señal síncrona
           FULL : out STD_LOGIC;                                -- Salida booleana - planta llena
           COUNT : out UNSIGNED (WIDTH-1 downto 0));            -- Valor de cuenta (binario de WIDTH bits)
      end component COUNTER;
      
    -- Señales para conectar con la entidad COUNTER
    signal RESET_N : STD_LOGIC := '1';      -- RESET asíncrono activo bajo
    signal CE : STD_LOGIC := '0';           -- Habilitación del chip
    signal CLK : STD_LOGIC := '0';          -- Señal de reloj
    signal CAR_IN : STD_LOGIC := '0';       -- Entrada de coche
    signal CAR_OUT : STD_LOGIC := '0';      -- Salida de coche
    signal FULL : STD_LOGIC := '0';         -- Indicador de "full"
    signal COUNT : UNSIGNED(3 downto 0);    -- Contador de coches

    -- Periodo del reloj
    constant CLK_PERIOD : time := 10 ns;

begin
    uut: COUNTER
        generic map (
            WIDTH => 4,
            MAX_CAPACITY => 15
        )
        port map (
            RESET_N => RESET_N,
            CE => CE,
            CLK => CLK,
            CAR_IN => CAR_IN,
            CAR_OUT => CAR_OUT,
            FULL => FULL,
            COUNT => COUNT
        );

    -- Generador de reloj
    CLK_process : process
    begin
        CLK <= '0';
        wait for CLK_PERIOD / 2;
        CLK <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Estímulos
    stim_proc: process
    begin        
        
        -- Test 1: Entrada de coches (CAR_IN = '1')
        CE <= '1';        -- Habilitar el contador
        wait for CLK_PERIOD;
        CAR_IN <= '1';    -- Primer coche entra
        wait for CLK_PERIOD;
        CAR_IN <= '0';    -- Se desactiva sensor CAR_IN
        wait for CLK_PERIOD;
        
        -- Test 2: Reset
        RESET_N <= '0'; -- Se activa el reset
        wait for 40 ns; -- Se asegura tiempo suficiente para el reset
        RESET_N <= '1'; -- Se desactiva el reset
        wait for CLK_PERIOD;
        
        -- Añadir más coches (entrando de uno en uno)
        for i in 1 to 5 loop
            CAR_IN <= '1';
            wait for CLK_PERIOD;
            CAR_IN <= '0';
            wait for CLK_PERIOD;
        end loop;

        -- Test 3: Salida de coches (CAR_OUT = '1')
        CAR_OUT <= '1';   -- Un coche sale
        wait for CLK_PERIOD;
        CAR_OUT <= '0';
        wait for CLK_PERIOD;

        -- Test 4: Llenado del parking
        for i in 1 to 10 loop
            CAR_IN <= '1';
            wait for CLK_PERIOD;
            CAR_IN <= '0';
            wait for CLK_PERIOD;
        end loop;

        -- Test 5: Verificación de "FULL"
        wait for 3*CLK_PERIOD; -- Se asegura tiempo suficiente para actualizar FULL
        assert FULL = '1' report "Error: El parking no está lleno cuando debería." severity error;

        -- Test 6: Intentar añadir más coches cuando está lleno
        CAR_IN <= '1';
        wait for CLK_PERIOD;
        CAR_IN <= '0';
        wait for CLK_PERIOD;
        assert COUNT = 15 report "Error: Se añadió un coche a un parking lleno." severity error;

        -- Test 7: Vaciar el parking
        for i in 1 to 15 loop
            CAR_OUT <= '1';
            wait for CLK_PERIOD;
            CAR_OUT <= '0';
            wait for CLK_PERIOD;
        end loop;

        -- Verificar si el contador está en 0 y FULL es '0'
        assert COUNT = 0 report "Error: El contador no está en 0 después de vaciar el parking." severity error;
        assert FULL = '0' report "Error: FULL no está a '0' cuando el parking está vacío." severity error;

        -- Test 8: Fin de simulación
        wait for 20 ns;
        report "Simulación completada." severity note;
        wait;
    end process;

end behavioral;