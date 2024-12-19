library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SPI_SLAVE is
    generic (
        TAM_PALABRA : natural := 8 -- Tamaño de la palabra
    );
    port (
        -- CLK      : in  std_logic;  -- Reloj FPGA
        RST_N    : in  std_logic;  -- Reset FPGA
        SCLK     : in  std_logic;  -- Reloj SPI STM32
        CS_N     : in  std_logic;  -- Chip select (activo en nivel bajo)
        MOSI     : in  std_logic;  -- Master output slave input (datos de STM a FPGA)
        MISO     : out std_logic;  -- Master input slave output (datos de FPGA a STM)
        REG     : out std_logic_vector(TAM_PALABRA-1 downto 0); -- Datos recibidos
        DOUT     : out std_logic
        --DOUT_VLD : out std_logic  -- Datos válidos recibidos
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
    -- Sincronización de SCLK
    --signal sclk_sync_1   : std_logic := '0';
    --signal sclk_sync_2   : std_logic := '0';
    --signal sclk_rise     : std_logic := '0';
    --signal sclk_fall     : std_logic := '0';

begin
    -- Sincroniza SCLK al dominio de reloj CLK (evita metaestabilidad y no se pueden
    -- poner relojes anidados)
   -- process (SCLK)
   -- begin
   --     if rising_edge(SCLK) then
    --        sclk_sync_1 <= SCLK;
    --        sclk_sync_2 <= sclk_sync_1;
            -- Detecta flancos
    --        sclk_rise <= sclk_sync_1 and not sclk_sync_2; -- Flanco ascendente
     --       sclk_fall <= not sclk_sync_1 and sclk_sync_2; -- Flanco descendente
     --   end if;
    --end process;
    
    -- Cada vez que se recibe un dato (MOSI), incrementa el contador y se registran en la variable.
    -- Se trata de un registro de desplazamiento.
    process (SCLK)
    begin
        if rising_edge(SCLK) then
            if RST_N = '0' or CS_N = '1' then
                contador <= (others => '0');
            else
                contador <= contador + 1;
                data_reg <= data_reg(TAM_PALABRA-2 downto 0) & MOSI; 
            end if;
        end if;
    end process;

    -- Cuando se alcanza el máximo, los datos son válidos.
    process (SCLK)
    begin
        if rising_edge(SCLK) then
            if contador = "111" then
                valido <= '1';
            else
                valido <= '0';
            end if;
        end if;
    end process;

    -- Se realiza otro registro de desplazamiento para MISO (a STM32).
    -- Se puede eliminar si no se utiliza.
    process (SCLK)
    begin
        if rising_edge(SCLK) then
            if RST_N = '0' or CS_N = '1' then
                miso_shift_reg <= (others => '0');  
            else
                miso_shift_reg <= data_reg(TAM_PALABRA-2 downto 0) & '0';  -- Desplazamiento del contenido
                miso_data <= miso_shift_reg(TAM_PALABRA-1);  -- Se envía el MSB por MISO
            end if;
        end if;
    end process;
    -- Se asignan las variables a las salidas.
    REG <= data_reg;  
    DOUT <= data_reg(data_reg'left);  -- Se asigna el MSB a la salida
    --DOUT_VLD <= valido; -- No necesario  
    MISO <= miso_data;  -- El MSB 
    
end Behavioral;