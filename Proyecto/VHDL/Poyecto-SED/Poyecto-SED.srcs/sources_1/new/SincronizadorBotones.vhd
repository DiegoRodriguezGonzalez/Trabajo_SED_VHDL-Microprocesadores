----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.01.2025 20:36:43
-- Design Name: 
-- Module Name: SincronizadorBotones - Behavioral
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

entity SincronizadorBotones is
     port (
     CLK : in std_logic;
     ASYNC_IN : in std_logic;
     SYNC_OUT : out std_logic
     );
end SincronizadorBotones;
architecture BEHAVIORAL of SincronizadorBotones is
     signal sreg : std_logic_vector(1 downto 0);
    begin
     process (CLK)
         begin
         if rising_edge(CLK) then
             sync_out <= sreg(1);
             sreg <= sreg(0) & async_in;
         end if;
     end process;
end BEHAVIORAL;