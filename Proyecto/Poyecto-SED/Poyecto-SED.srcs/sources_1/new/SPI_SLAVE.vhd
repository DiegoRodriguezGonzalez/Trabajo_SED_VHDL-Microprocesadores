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
       -- REG : out std_logic_vector(TAM_PALABRA-1 downto 0);
       -- DOUT_VLD : out std_logic  -- Datos válidos recibidos
    );
end entity;

architecture Behavioral of SPI_SLAVE is
    constant MAX : natural := 3; --Contador que crece cuando recibe los datos.
    signal contador : unsigned(MAX-1 downto 0) := (others => '0');
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
    -- Se declara variable para que se actualice en el mismo ciclo.
    variable data_reg : std_logic_vector(TAM_PALABRA-1 downto 0) := (others => '0');
    begin
        if rising_edge(SCLK) then
            if RST_N = '0' or CS_N = '1' then
                contador <= (others => '0');
            else
                contador <= contador + 1;
                data_reg := data_reg(TAM_PALABRA-2 downto 0) & MOSI; 
                if contador = "111" then
                  --valido <= '1';
                  if data_reg(TAM_PALABRA-1) = '1' then
                    PLANTA_PANEL <= data_reg(TAM_PALABRA-5 downto 0);
                  elsif data_reg(TAM_PALABRA-2) = '1' then
                    PLANTA_EXTERNA <= data_reg(TAM_PALABRA-5 downto 0);
                  elsif data_reg(TAM_PALABRA-3) = '1' then
                    PLANTA_ACTUAL <= data_reg(TAM_PALABRA-5 downto 0);
                  end if; 
             -- else
             --     valido <= '0';
                end if;
            end if;
        end if;
        --REG <= data_reg;
    end process;

    -- Se realiza otro registro de desplazamiento para MISO (a STM32).
    -- Se puede eliminar si no se utiliza.
   -- process (SCLK)
   --begin
   --     if rising_edge(SCLK) then
    --        if RST_N = '0' or CS_N = '1' then
     --           miso_shift_reg <= (others => '0');  
      --      else
      --          miso_shift_reg <= data_reg(TAM_PALABRA-2 downto 0) & '0';  -- Desplazamiento del contenido
      --         miso_data <= miso_shift_reg(TAM_PALABRA-1);  -- Se envía el MSB por MISO
      --      end if;
      --  end if;
    --end process;

    --MISO <= miso_data;  -- El MSB 
    --DOUT_VLD <= valido;
end Behavioral;