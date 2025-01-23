library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SPI_SLAVE_TB is
end entity;

architecture Behavioral of SPI_SLAVE_TB is
    
    component SPI_SLAVE is
    generic (
        TAM_PALABRA : natural := 8 -- Tamaño de la palabra
    );
    port (
        RST_N    : in  std_logic;  -- Reset FPGA
        SCLK     : in  std_logic;  -- Reloj SPI STM32
        CS_N     : in  std_logic;  -- Chip select (activo en nivel bajo)
        MOSI     : in  std_logic;  -- Master output slave input (datos de STM a FPGA)
        PLANTA_PANEL : out std_logic_vector(TAM_PALABRA-5 downto 0);
        PLANTA_EXTERNA : out std_logic_vector(TAM_PALABRA-5 downto 0);
        PLANTA_ACTUAL : out std_logic_vector(TAM_PALABRA-5 downto 0)
    );
    end component;

    constant TAM_PALABRA : natural := 8;

    signal RST_N          : std_logic := '0';
    signal SCLK           : std_logic := '0';
    signal CS_N           : std_logic := '1';
    signal MOSI           : std_logic := '0';
    signal PLANTA_PANEL   : std_logic_vector(TAM_PALABRA-5 downto 0);
    signal PLANTA_EXTERNA : std_logic_vector(TAM_PALABRA-5 downto 0);
    signal PLANTA_ACTUAL  : std_logic_vector(TAM_PALABRA-5 downto 0);

    -- Periodo del reloj
    constant CLK_PERIOD : time := 20 ns;

begin
    -- Unit under test
    UUT: SPI_SLAVE
        generic map (
            TAM_PALABRA => TAM_PALABRA
        )
        port map (
            RST_N          => RST_N,
            SCLK           => SCLK,
            CS_N           => CS_N,
            MOSI           => MOSI,
            PLANTA_PANEL   => PLANTA_PANEL,
            PLANTA_EXTERNA => PLANTA_EXTERNA,
            PLANTA_ACTUAL  => PLANTA_ACTUAL
        );

    -- Generación del reloj
    SCLK <= not SCLK after CLK_PERIOD/2;
  
    --Poceso
    stim_proc: process
    
    variable DATOS_A_MOSI : std_logic_vector(TAM_PALABRA-1 downto 0) := (others => '0');
    
    begin
    
        -- Se inicializan variables
        RST_N <= '0';
        CS_N <= '1';
        MOSI <= '0';
        wait for 20 ns;

        RST_N <= '1';
        wait for 30 ns;

        -- La señal recibida es la planta pulsada en el panel
        CS_N <= '0';
        DATOS_A_MOSI := "10001000"; 
        for i in TAM_PALABRA-1 downto 0 loop
            MOSI <= DATOS_A_MOSI(i);
            wait for CLK_PERIOD;
        end loop;
        CS_N <= '1';
        wait for 100 ns;

        -- Se verifica que se han recibido
        assert PLANTA_PANEL = DATOS_A_MOSI(TAM_PALABRA-5 downto 0) report "Error: Datos no coinciden en PLANTA_PANEL" severity error;

        -- La señal recibida es la planta pulsada en el los botones externos de cada piso
        CS_N <= '0';
        DATOS_A_MOSI := "01000001";
        for i in TAM_PALABRA-1 downto 0 loop
            MOSI <= DATOS_A_MOSI(i);
            wait for CLK_PERIOD;
        end loop;
        CS_N <= '1';
        wait for 100 ns;

        -- Se verifica que se han recibido
        assert PLANTA_EXTERNA = DATOS_A_MOSI(TAM_PALABRA-5 downto 0) report "Error: Datos no coinciden en PLANTA_EXTERNA" severity error;

        -- La señal recibida es la planta actual mediante el ultrasonidos
        CS_N <= '0';
        DATOS_A_MOSI := "00100100"; 
        for i in TAM_PALABRA-1 downto 0 loop
            MOSI <= DATOS_A_MOSI(i);
            wait for CLK_PERIOD;
        end loop;
        CS_N <= '1';
        wait for 100 ns;

        -- Se verifica que se han recibido
        assert PLANTA_ACTUAL = DATOS_A_MOSI(TAM_PALABRA-5 downto 0) report "Error: Datos no coinciden en PLANTA_ACTUAL" severity error;

        -- Se resetean los botones (se ponen a 0)
        CS_N <= '0';
        DATOS_A_MOSI := "00000000"; 
        for i in TAM_PALABRA-1 downto 0 loop
            MOSI <= DATOS_A_MOSI(i);
            wait for CLK_PERIOD;
        end loop;
        CS_N <= '1';
        wait for 100 ns;
        -- Fin de simulación
        wait;
    end process;

end Behavioral;

