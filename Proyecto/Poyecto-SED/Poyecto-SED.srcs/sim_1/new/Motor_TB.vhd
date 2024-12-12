library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Motor_tb is
end Motor_tb;

architecture Behavioral of Motor_tb is

    component Motor is
        generic (
            speed : integer := 30_000  -- Velocidad del motor
        );
        port (
            CLK : in std_logic;           
            ORDEN_MOTOR : in std_logic_vector(1 downto 0);
            PWM1, PWM2 : out std_logic
        );
    end component;

    signal CLK : std_logic := '0';
    signal ORDEN_MOTOR : std_logic_vector(1 downto 0) := (others => '0');
    signal PWM1, PWM2 : std_logic;

    constant CLK_PERIOD : time := 20 ns; -- Periodo del reloj

begin

    -- Unit Under Test
    uut: Motor
        generic map (
            speed => 30_000  -- Velocidad del motor
        )
        port map (
            CLK => CLK,
            ORDEN_MOTOR => ORDEN_MOTOR,
            PWM1 => PWM1,
            PWM2 => PWM2
        );

    -- Generación del reloj
    CLK <= not CLK after CLK_PERIOD/2;

    -- Generación de señales
    stim : process
    begin
        -- Motor quieto
        ORDEN_MOTOR <= "00";
        wait for 100 ns;

        -- Motor sube
        ORDEN_MOTOR <= "10";
        wait for 100 ns;

        -- Motor baja
        ORDEN_MOTOR <= "01";
        wait for 100 ns;

        -- Motor quieto
        ORDEN_MOTOR <= "00";
        wait for 100 ns;

        assert false
        report "[PASSED]: simulation finished."
        severity failure;
    end process;
end Behavioral;
