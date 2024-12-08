library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

-- LA FPGA FUNCIONA EN SPI SLAVE MODE 0 (CPOL=0, CPHA=0)

entity SPI_SLAVE is
    generic (
        TAM_PALABRA : natural := 8 -- Recibe hasta 8 bits
    );
    port (
        CLK      : in  std_logic; -- Reloj FPGA
        RST      : in  std_logic; -- Reset FPGA
        -- INTERFAZ SPI SLAVE 
        SCLK     : in  std_logic; -- Reloj SPI (del micro)
        CS_N     : in  std_logic; -- Chip select SPI chip, activo en nivel bajo
        MOSI     : in  std_logic; -- SPI serial data from master to slave
        MISO     : out std_logic; -- SPI serial data from slave to master
        -- INTERFAZ USUARIO (OPCIONALES)
        DIN      : in  std_logic_vector(TAM_PALABRA-1 downto 0); -- Transmisión de datos a SPI master
        DIN_VLD  : in  std_logic; -- Cuando DIN_VLD = 1, los datos para la transmisión son válidos
        DIN_RDY  : out std_logic; -- Cuando DIN_RDY = 1, la FPGA SPI slave acepta datos válidos
        DOUT     : out std_logic_vector(TAM_PALABRA-1 downto 0); -- Datos recibidos del SPI master
        DOUT_VLD : out std_logic  -- Cuando DOUT_VLD = 1, los datos recibidos son válidos
    );
end entity;

architecture Behavioral of SPI_SLAVE is

    constant BIT_CNT_WIDTH : natural := natural(ceil(log2(real(TAM_PALABRA))));

    signal sclk_meta          : std_logic;
    signal cs_n_meta          : std_logic;
    signal mosi_meta          : std_logic;
    signal sclk_reg           : std_logic;
    signal cs_n_reg           : std_logic;
    signal mosi_reg           : std_logic;
    signal spi_clk_reg        : std_logic;
    signal spi_clk_redge_en   : std_logic;
    signal spi_clk_fedge_en   : std_logic;
    signal bit_cnt            : unsigned(BIT_CNT_WIDTH-1 downto 0);
    signal bit_cnt_max        : std_logic;
    signal last_bit_en        : std_logic;
    signal load_data_en       : std_logic;
    signal data_shreg         : std_logic_vector(TAM_PALABRA-1 downto 0);
    signal slave_ready        : std_logic;
    signal shreg_busy         : std_logic;
    signal rx_data_vld        : std_logic;

begin

    -- Sincronización para eliminar posible metaestabilidad. No es necesario
    sync_ffs_p : process (CLK)
    begin
        if (rising_edge(CLK)) then
            sclk_meta <= SCLK;
            cs_n_meta <= CS_N;
            mosi_meta <= MOSI;
            sclk_reg  <= sclk_meta;
            cs_n_reg  <= cs_n_meta;
            mosi_reg  <= mosi_meta;
        end if;
    end process;

    -- Detección del reloj SPI. Se no se presiona reset, se registra el reloj SCLK en spi_clk_reg
    spi_clk_reg_p : process (CLK)
    begin
        if (rising_edge(CLK)) then
            if (RST = '1') then
                spi_clk_reg <= '0';
            else
                spi_clk_reg <= sclk_reg;
            end if;
        end if;
    end process;

    -- Se detecta un flanco de bajada del reloj SPI cuando sclk_reg=0 y spi_clk_reg=1 (Se compara con el estado anterior).
    spi_clk_fedge_en <= not sclk_reg and spi_clk_reg;
    -- Se detecta un flanco de subida cuando sclk_reg=1 y spi_clk_reg=0.
    spi_clk_redge_en <= sclk_reg and not spi_clk_reg;

    -- Contador de los bits recibidos por el master, activado cuando hay un
    -- flanco de bajada del reloj SPI y cs_n_reg está activado (nivel bajo).
    bit_cnt_p : process (CLK)
    begin
        if (rising_edge(CLK)) then
            if (RST = '1') then
                bit_cnt <= (others => '0');
            elsif (spi_clk_fedge_en = '1' and cs_n_reg = '0') then
                if (bit_cnt_max = '1') then
                    bit_cnt <= (others => '0');
                else
                    bit_cnt <= bit_cnt + 1;
                end if;
            end if;
        end if;
    end process;

    -- Se alcanza el máximo cuando recibe 8 bits.
    bit_cnt_max <= '1' when (bit_cnt = TAM_PALABRA-1) else '0';

    -- Flag del último bit recibido cuando se alcanza el máximo
    last_bit_en_p : process (CLK)
    begin
        if (rising_edge(CLK)) then
            if (RST = '1') then
                last_bit_en <= '0';
            else
                last_bit_en <= bit_cnt_max;
            end if;
        end if;
    end process;

    --Datos recibidos del maestro válidos cuando se detecta flanco negativo
    -- del reloj del SPI y se detecta que ha recibido el último bit.
    rx_data_vld <= spi_clk_fedge_en and last_bit_en;

    --El registro de datos está ocupado hasta que envía todos los bits recibidos al SPI master
    shreg_busy_p : process (CLK)
    begin
        if (rising_edge(CLK)) then
            if (RST = '1') then
                shreg_busy <= '0';
            else
                if (DIN_VLD = '1' and (cs_n_reg = '1' or rx_data_vld = '1')) then
                    shreg_busy <= '1';
                elsif (rx_data_vld = '1') then
                    shreg_busy <= '0';
                else
                    shreg_busy <= shreg_busy;
                end if;
            end if;
        end if;
    end process;

    --SPI slave puede aceptar nuevos datos cuandi cs_n_reg=1 y no está ocupado 
    --o cuando los datos son válidos
    slave_ready <= (cs_n_reg and not shreg_busy) or rx_data_vld;
    
    --Los datos recibidos son cargados en el registro cuando el SPI slave está listo
    --y los datos son válidos.
    load_data_en <= slave_ready and DIN_VLD;

    -- El registro de desplazamiento almacena los datos recibidos en el flanco 
    -- de subida del reloj SPI y cs_n_reg=0.
    data_shreg_p : process (CLK)
    begin
        if (rising_edge(CLK)) then
            if (load_data_en = '1') then
                data_shreg <= DIN;
            elsif (spi_clk_redge_en = '1' and cs_n_reg = '0') then
                data_shreg <= data_shreg(TAM_PALABRA-2 downto 0) & mosi_reg;
            end if;
        end if;
    end process;

    --Registro MISO para transmitir los bits a master cuando cs_n_reg=0 y 
    --se detecta un flanco negativo en el reloj SPI.
    miso_p : process (CLK)
    begin
        if (rising_edge(CLK)) then
            if (load_data_en = '1') then
                MISO <= DIN(TAM_PALABRA-1);
            elsif (spi_clk_fedge_en = '1' and cs_n_reg = '0') then
                MISO <= data_shreg(TAM_PALABRA-1);
            end if;
        end if;
    end process;

    --Se asignan a las salidas las señales correspondientes.
    DIN_RDY  <= slave_ready;
    DOUT     <= data_shreg;
    DOUT_VLD <= rx_data_vld;

end architecture Behavioral;