library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SINCRONIZADOR_MICRO_A_FPGA_TB is
end entity SINCRONIZADOR_MICRO_A_FPGA_TB;

architecture Behavioral of SINCRONIZADOR_MICRO_A_FPGA_TB is

    -- Component declaration of the unit under test (UUT)
    component SINCRONIZADOR_MICRO_A_FPGA
        generic (
            TAM_PALABRA : natural := 8 -- Tamaño de la palabra
        );
        port (
            CLK             : in  std_logic;  -- Reloj FPGA
            RST_N           : in  std_logic;  -- Reset FPGA
            PLANTA_PANEL_IN : in  std_logic_vector(TAM_PALABRA-5 downto 0);  
            PLANTA_EXTERNA_IN : in  std_logic_vector(TAM_PALABRA-5 downto 0); 
            PLANTA_ACTUAL_IN : in  std_logic_vector(TAM_PALABRA-5 downto 0);  
            PLANTA_PANEL_SYNC : out std_logic_vector(TAM_PALABRA-5 downto 0);  -- Salida PLANTA_PANEL sincronizada
            PLANTA_EXTERNA_SYNC : out std_logic_vector(TAM_PALABRA-5 downto 0);  -- Salida PLANTA_EXTERNA sincronizada
            PLANTA_ACTUAL_SYNC : out std_logic_vector(TAM_PALABRA-5 downto 0)   -- Salida PLANTA_ACTUAL sincronizada
        );
    end component;

    constant TAM_PALABRA : natural := 8;
    
    signal CLK             : std_logic := '0';
    signal RST_N           : std_logic := '1';
    signal PLANTA_PANEL_IN : std_logic_vector(TAM_PALABRA-5 downto 0) := (others => '0');
    signal PLANTA_EXTERNA_IN : std_logic_vector(TAM_PALABRA-5 downto 0) := (others => '0');
    signal PLANTA_ACTUAL_IN : std_logic_vector(TAM_PALABRA-5 downto 0) := (others => '0');
    signal PLANTA_PANEL_SYNC : std_logic_vector(TAM_PALABRA-5 downto 0);
    signal PLANTA_EXTERNA_SYNC : std_logic_vector(TAM_PALABRA-5 downto 0);
    signal PLANTA_ACTUAL_SYNC : std_logic_vector(TAM_PALABRA-5 downto 0);

    -- Periodo del reloj
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Unit under test
    UUT: SINCRONIZADOR_MICRO_A_FPGA
        port map (
            CLK => CLK,
            RST_N => RST_N,
            PLANTA_PANEL_IN => PLANTA_PANEL_IN,
            PLANTA_EXTERNA_IN => PLANTA_EXTERNA_IN,
            PLANTA_ACTUAL_IN => PLANTA_ACTUAL_IN,
            PLANTA_PANEL_SYNC => PLANTA_PANEL_SYNC,
            PLANTA_EXTERNA_SYNC => PLANTA_EXTERNA_SYNC,
            PLANTA_ACTUAL_SYNC => PLANTA_ACTUAL_SYNC
        );

    -- Generación del reloj
    CLK <= not CLK after CLK_PERIOD/2;

    -- Estímulos
    stim_proc: process
    begin        

        RST_N <= '0';
        wait for 20 ns;
        RST_N <= '1';
        wait for 20 ns;

        PLANTA_PANEL_IN <= "1000";  
        PLANTA_EXTERNA_IN <= "0100";  
        PLANTA_ACTUAL_IN <= "0010";
        wait for 20 ns;

        PLANTA_PANEL_IN <= "0001";  
        PLANTA_EXTERNA_IN <= "1000";  
        PLANTA_ACTUAL_IN <= "0100"; 
        wait for 20 ns;

        PLANTA_PANEL_IN <= "0010";
        PLANTA_EXTERNA_IN <= "0001";
        PLANTA_ACTUAL_IN <= "1000";
        
        wait for 20 ns;
        assert false
         report "Simulación completada." 
         severity failure;
    end process;
end architecture;

