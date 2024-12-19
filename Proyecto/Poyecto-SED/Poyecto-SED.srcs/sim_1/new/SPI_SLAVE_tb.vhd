library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SPI_SLAVE_tb is
end entity;

architecture Behavioral of SPI_SLAVE_tb is

    -- Component declaration
    component SPI_SLAVE
        generic (
            TAM_PALABRA : natural := 8 -- Tamaño de la palabra
        );
        port (
            RST_N    : in  std_logic;
            SCLK     : in  std_logic;
            CS_N     : in  std_logic;
            MOSI     : in  std_logic;
            DOUT     : out std_logic
        );
    end component;

    -- Signals
    signal RST_N   : std_logic := '0';
    signal SCLK    : std_logic := '0';
    signal CS_N    : std_logic := '1';
    signal MOSI    : std_logic := '0';
    signal DOUT    : std_logic;

    constant SCLK_PERIOD : time := 80 ns; -- 12.5 MHz SPI clock

    -- Test data
    type data_array is array (0 to 4) of std_logic;
    signal test_data : data_array := ('0', '1', '0', '1', '0'); -- Test sequence
    signal bit_index : integer := 0;

begin

    -- Instantiate the SPI_SLAVE
    uut: SPI_SLAVE
        generic map (
            TAM_PALABRA => 8
        )
        port map (
            RST_N => RST_N,
            SCLK  => SCLK,
            CS_N  => CS_N,
            MOSI  => MOSI,
            DOUT  => DOUT
        );

    -- SCLK generation
    process
    begin
        while true loop
            SCLK <= '1';
            wait for SCLK_PERIOD / 2;
            SCLK <= '0';
            wait for SCLK_PERIOD / 2;
        end loop;
    end process;

    -- Test process
    process
    begin
        -- Reset the system
        RST_N <= '0';
        wait for 100 ns;
        RST_N <= '1';

        -- Begin SPI transmission
        CS_N <= '0';
        for i in 0 to 4 loop
            MOSI <= test_data(i);
            wait for SCLK_PERIOD; -- Wait for one SPI clock cycle
        end loop;
       
        wait for 200 ns;

        -- Observe DOUT
        report "DOUT value: " & std_logic'image(DOUT);

        -- Finish simulation
        wait;
    end process;

end Behavioral;
