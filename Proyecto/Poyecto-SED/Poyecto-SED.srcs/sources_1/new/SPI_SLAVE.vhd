library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SPI_SLAVE is
    generic (
        TAM_PALABRA : natural := 8 -- Tamaño de la palabra
    );
    port (
        CLK      : in  std_logic;  -- Reloj FPGA
        RST      : in  std_logic;  -- Reset FPGA
        SCLK     : in  std_logic;  -- Reloj SPI STM32
        CS_N     : in  std_logic;  -- Chip select (activo en nivel bajo)
        MOSI     : in  std_logic;  -- Master output slave input (datos de STM a FPGA)
        MISO     : out std_logic;  -- Master input slave output (datos de FPGA a STM)
        DOUT     : out std_logic_vector(TAM_PALABRA-1 downto 0); -- Datos recibidos
        DOUT_VLD : out std_logic  -- Datos válidos recibidos
    );
end entity;

architecture Behavioral of SPI_SLAVE is
    constant MAX : natural := 3; --Contador que crece cuando recibe los datos.
    signal contador : unsigned(MAX-1 downto 0) := (others => '0');
    signal data_reg : std_logic_vector(TAM_PALABRA-1 downto 0) := (others => '0');
    signal valido : std_logic := '0';
    signal mosi_sync : std_logic;
    signal miso_shift_reg : std_logic_vector(TAM_PALABRA-1 downto 0) := (others => '0');  
    signal miso_data : std_logic := '0'; -- Para el bit más significativo de MISO
begin

    -- Cada vez que se recibe un dato (MOSI), incrementa el contador y se registran en la variable.
    -- Se trata de un registro de desplazamiento.
    process (CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' or CS_N = '1' then
                contador <= (others => '0');
            elsif rising_edge(SCLK) then
                contador <= contador + 1;
                data_reg <= data_reg(TAM_PALABRA-2 downto 0) & MOSI; 
            end if;
        end if;
    end process;

    -- Cuando se alcanza el máximo, los datos son válidos.
    process (CLK)
    begin
        if rising_edge(CLK) then
            if contador = "111" and rising_edge(SCLK) then
                valido <= '1';
            else
                valido <= '0';
            end if;
        end if;
    end process;

    -- Se realiza otro registro de desplazamiento para MISO (a STM32).
    -- Se puede eliminar si no se utiliza.
    process (CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' or CS_N = '1' then
                miso_shift_reg <= (others => '0');  
            elsif rising_edge(SCLK) then
                miso_shift_reg <= data_reg(TAM_PALABRA-2 downto 0) & '0';  -- Desplazamiento del contenido
                miso_data <= miso_shift_reg(TAM_PALABRA-1);  -- Se envía el MSB por MISO
            end if;
        end if;
    end process;
    
    -- Se asignan las variables a las salidas.
    DOUT <= data_reg;  
    DOUT_VLD <= valido;  
    MISO <= miso_data;  -- El MSB 
    
end Behavioral;