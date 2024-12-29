library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_textio.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values


-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity GestorPrioridades is
    Generic(
           NUMERO_PLANTAS: INTEGER := 4
    );
    
    Port ( 
           CLK : in STD_LOGIC;  -- Señal de reloj
           RESET : in STD_LOGIC;    -- Señal de RESET para EMERGENCIA
           PLANTA_PULSADA: in STD_LOGIC_VECTOR (NUMERO_PLANTAS-1 downto 0); -- Vector que indica el botón seleccionado en la cabina
           PLANTA_LLAMADA: in STD_LOGIC_VECTOR (NUMERO_PLANTAS-1 downto 0); -- Vector que indica botones de planta externos
           PLANTAACTUAL : in std_logic_vector(NUMERO_PLANTAS-1 downto 0); -- Vector que indica la planta actual.
           LLENO : in STD_LOGIC_VECTOR (NUMERO_PLANTAS-1 downto 0); -- Vector que almacena el estado de las plantas del parking (plantas 0,1,2,3) 0 siempre estará a 0
           ESTADO_ACTUAL : in std_logic_vector(3 downto 0); -- Vector con estado del ascensor
           DESTINO_FINAL: out STD_LOGIC_VECTOR (NUMERO_PLANTAS-1 downto 0) -- Indica planta a la que ir
           );
end GestorPrioridades;

architecture Behavioral of GestorPrioridades is
    type vector_unsigned is array (NUMERO_PLANTAS-1 downto 0) of UNSIGNED(3 downto 0);  
begin
    Gestor: process (RESET, CLK)
    variable dest_fin: STD_LOGIC_VECTOR (NUMERO_PLANTAS-1 downto 0):= (others => '0'); -- Variable intermedia que asignar a DESTINO_FINAL
    variable PRIORIDADES : vector_unsigned := (others => (others => '0')); -- Vector de unsigned que almacena llamadas pendientes
    variable pendiente: boolean := false; -- Flag usada para saber si ya hay petición de llamada en botón
    
    variable mensaje : string(1 to 100); -- Mensaje temporal
    variable valor   : string(1 to 20);  -- Para cada unsigned
 
    begin
        if RESET = '1' then 
            dest_fin := (others => '0'); 
            PRIORIDADES := (others => (others => '0')); 
            pendiente := false;
            --report "Se resetean señales y variables";
        elsif rising_edge(CLK) then
            for i in NUMERO_PLANTAS-1 downto 0 loop
                --valor := to_string(std_logic_vector(PRIORIDADES(i))); -- Convertir cada unsigned
                --mensaje := mensaje & "Elemento(" & integer'image(i) & ")=" & valor & " ";
            end loop;
            --report mensaje;
            if ESTADO_ACTUAL = "0000" then -- Gestión cuando el ascensor está parado 
            dest_fin := "0000";
                for i in NUMERO_PLANTAS-1 downto 0 loop --Prioridad interna (panel de cabina)
                    if PLANTA_PULSADA(i) = '1' then -- Se detecta el primer 1
                        if LLENO(i) = '0' then -- Se evalúa si no está llena la planta. Planta 0 siempre está a 0 
                            dest_fin := (others => '0');
                            dest_fin(i) := '1'; -- Se asigna dest_fin como la llamada realizada
                            --report "Destino según PLANTA_PULSADA con motor parado:" ;
                            exit;
                        end if;
                    end if;
                end loop;
                if dest_fin = "0000" then   -- Si no hay prioridad interna, atender llamadas guardadas y si no hay, comprobar si en dicho instante se llama externamento
                    dest_fin := std_logic_vector(PRIORIDADES(PRIORIDADES'LEFT));
                    -- La prioridad almacenada se cumple cuando ya se
                    -- ha llegado al destino, ya que al hacerlo solamente con 
                    -- flancos de reloj sería todo 0.
                    if PLANTAACTUAL = dest_fin then
                        PRIORIDADES := PRIORIDADES(NUMERO_PLANTAS-2 downto 0) & "0000"; -- Se elimina la llamada ya atendida
                    end if;
                end if;
                    --report "Destino según PRIORIDAD con motor movimiento:" dest_fin;
                    if dest_fin = "0000" then
                        for i in NUMERO_PLANTAS-1 downto 0 loop --Prioridad externa (panel de planta)
                            if PLANTA_LLAMADA(i) = '1' then -- Se detecta el primer 1 
                                dest_fin := (others => '0');
                                dest_fin(i) := '1'; -- Se asigna dest_fin como la llamada realizada
                                --report "Destino según PLANTA_LLAMADA con motor movimiento:" dest_fin;
                                exit;
                            end if;
                        end loop;
                end if;
            end if;

            if ESTADO_ACTUAL /= "0000" then    -- Gestión en movimiento
                -- Se añaden llamadas externas al vector de prioridades
                for j in NUMERO_PLANTAS-1 downto 0 loop
                    if PRIORIDADES(j) = unsigned(PLANTA_LLAMADA) then   -- Se evalúa si ya está en pendientes
                    pendiente := true;
                    if pendiente then
                        --report "Pendiente, no se almacena";
                    end if;
                    exit;
                    end if;
                end loop;
                if not pendiente then   -- Si no se tiene dentro de la memoria de pendientes, se añade en primera posición libre
                for i in NUMERO_PLANTAS-1 downto 0 loop
                    if PRIORIDADES(i) = "0000" then
                        PRIORIDADES(i) := unsigned(PLANTA_LLAMADA);
                        exit;
                    end if;
                end loop;
                end if;
                --report "Vector de PRIORIDADES:";
                pendiente:=  false; -- Resetea el flag
            end if;
        end if;
        DESTINO_FINAL <= dest_fin;
        --report "Destino final es:" dest_fin;
    end process;
end Behavioral;
