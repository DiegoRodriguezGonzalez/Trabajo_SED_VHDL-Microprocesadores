library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SINCRONIZADOR_MICRO_A_FPGA is
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
end entity;

architecture Behavioral of SINCRONIZADOR_MICRO_A_FPGA is
    -- Señales intermedias para la sincronización
    signal planta_panel_sync_1, planta_panel_sync_2 : std_logic_vector(TAM_PALABRA-5 downto 0);
    signal planta_externa_sync_1, planta_externa_sync_2 : std_logic_vector(TAM_PALABRA-5 downto 0);
    signal planta_actual_sync_1, planta_actual_sync_2 : std_logic_vector(TAM_PALABRA-5 downto 0);
begin
    -- Sincronización de la salida PLANTA_PANEL
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RST_N = '0' then     -- Si se presiona reset, las salidas se ponen a 0
                planta_panel_sync_1 <= (others => '0'); 
                planta_panel_sync_2 <= (others => '0'); 
            else
                planta_panel_sync_1 <= PLANTA_PANEL_IN;         -- Primera asignación a señal intermedia. Se actualiza en un flanco.
                planta_panel_sync_2 <= planta_panel_sync_1;     -- Segunda asignación a señal intermedia. Se actualiza en el siguiente flanco.
            end if;
        end if;
    end process;

    -- Sincronización de la salida PLANTA_EXTERNA. Misma explicación que el proceso anterior.
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RST_N = '0' then
                planta_externa_sync_1 <= (others => '0');
                planta_externa_sync_2 <= (others => '0');
            else
                planta_externa_sync_1 <= PLANTA_EXTERNA_IN;
                planta_externa_sync_2 <= planta_externa_sync_1;
            end if;
        end if;
    end process;

    -- Sincronización de la salida PLANTA_ACTUAL. Misma explicación que el proceso anterior.
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RST_N = '0' then
                planta_actual_sync_1 <= (others => '0');
                planta_actual_sync_2 <= (others => '0');
            else
                planta_actual_sync_1 <= PLANTA_ACTUAL_IN;
                planta_actual_sync_2 <= planta_actual_sync_1;
            end if;
        end if;
    end process;

    -- Asignaciones de salidas sincronizadas.
    PLANTA_PANEL_SYNC <= planta_panel_sync_2;
    PLANTA_EXTERNA_SYNC <= planta_externa_sync_2;
    PLANTA_ACTUAL_SYNC <= planta_actual_sync_2;

end architecture;

