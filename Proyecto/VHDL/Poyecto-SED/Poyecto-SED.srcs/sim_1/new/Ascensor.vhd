----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.12.2024 17:53:53
-- Design Name: 
-- Module Name: Ascensor - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Ascensor is
    Port ( CLK : in STD_LOGIC;
           RESET : in STD_LOGIC;
           ACCION : in STD_LOGIC_VECTOR (1 downto 0);
           MOTOR : out STD_LOGIC_VECTOR (1 downto 0));
end Ascensor;

architecture Behavioral of Ascensor is

begin


end Behavioral;
