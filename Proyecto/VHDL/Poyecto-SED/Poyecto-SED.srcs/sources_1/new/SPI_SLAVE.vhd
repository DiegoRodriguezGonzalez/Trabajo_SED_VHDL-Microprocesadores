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
      --  MISO     : out std_logic;  -- Master input slave output (datos de FPGA a STM)
        PLANTA_PANEL : out std_logic_vector(TAM_PALABRA-5 downto 0);
        PLANTA_EXTERNA : out std_logic_vector(TAM_PALABRA-5 downto 0);
        PLANTA_ACTUAL : out std_logic_vector(TAM_PALABRA-5 downto 0)
    );
end entity;

architecture Behavioral of SPI_SLAVE is
    constant MAX : natural := 3; --Contador que crece cuando recibe los datos.
    signal contador : unsigned(MAX-1 downto 0) := (others => '0');
    signal valido : std_logic := '0';
    signal mosi_sync : std_logic;
    signal miso_shift_reg : std_logic_vector(TAM_PALABRA-1 downto 0) := (others => '0');  
    signal miso_data : std_logic := '0'; -- Para el bit más significativo de MISO

begin
    -- Cada vez que se recibe un dato (MOSI), incrementa el contador y se registran en la variable.
    -- Se trata de un registro de desplazamiento.
    process (SCLK)
    -- Se declara variable para que se actualice en el mismo ciclo.
    variable data_reg : std_logic_vector(TAM_PALABRA-1 downto 0) := (others => '0');
    begin
        if rising_edge(SCLK) then
            if RST_N = '0' or CS_N = '1' then
                contador <= (others => '0');
            else
                -- Se incrementa el contador para que, cuando reciba los 8 bits, se actualicen las salidas.
                contador <= contador + 1;
                data_reg := data_reg(TAM_PALABRA-2 downto 0) & MOSI;
                -- Cuando se alcanzan los 8 bits, se actualizan las salidas ya que ha recibido toda la información.
                if contador = "111" then
                  --valido <= '1';
                  -- Primer caso prioritario: cuando se quieren resetear las salidas del botón interno y botón externo. Controlado desde STM para que 
                  -- funcione como un botón. No es reset como tal ya que la señal viene desde STM32. La planta actual nunca se pone a 0.
                  if data_reg(TAM_PALABRA-1) = '0' and data_reg(TAM_PALABRA-2) = '0' and data_reg(TAM_PALABRA-3) = '0' and data_reg(TAM_PALABRA-4) = '0' then
                    PLANTA_PANEL <= (others => '0');
                    PLANTA_EXTERNA <= (others => '0');
                  elsif data_reg(TAM_PALABRA-1) = '1' then
                    PLANTA_PANEL <= data_reg(TAM_PALABRA-5 downto 0);
                  elsif data_reg(TAM_PALABRA-2) = '1' then
                    PLANTA_EXTERNA <= data_reg(TAM_PALABRA-5 downto 0);
                  elsif data_reg(TAM_PALABRA-3) = '1' then
                    PLANTA_ACTUAL <= data_reg(TAM_PALABRA-5 downto 0);
                  end if; 
                end if;
            end if;
        end if;
    end process;
end Behavioral;