library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity agrupador is
  generic (
      Nplantas : positive := 4  -- Número de plantas del ascensor
  );
  port (
      PLANTA0 : in std_logic;
      PLANTA1 : in std_logic;
      PLANTA2 : in std_logic;
      PLANTA3 : in std_logic;
      SALIDA : out std_logic_vector(NPlantas-1 downto 0)
  );
end agrupador;

architecture Behavioral of agrupador is
begin

  SALIDA <= PLANTA3 & PLANTA2 & PLANTA1 & PLANTA0;
 
end Behavioral;
