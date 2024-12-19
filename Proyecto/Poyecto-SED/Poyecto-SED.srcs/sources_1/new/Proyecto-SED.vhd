----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.11.2024 18:01:51
-- Design Name: 
-- Module Name: Top - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Top is
    generic ( 
      Nplantas : positive := 4;  -- Número de plantas del ascensor
      Plantas_Bin: positive := 2  --Numero de bits que tiene la planta convertida en binario
    );
    Port ( 
    clk : in std_logic;
    RESET_N_top_to_counter: in std_logic; --Reseteo general de contadores de parking
    C_I1_top_to_counter: in std_logic; --señal de entrada de coche en piso 1
    C_I2_top_to_counter: in std_logic; --señal de entrada de coche en piso 2
    C_I3_top_to_counter: in std_logic; --señal de entrada de coche en piso 3
    C_O1_top_to_counter: in std_logic; --señal de salida de coche en piso 1
    C_O2_top_to_counter: in std_logic; --señal de salida de coche en piso 2
    C_O3_top_to_counter: in std_logic; --señal de salida de coche en piso 3
    BEXT_P0_top_to_agrupador: in std_logic; --Boton planta 0 que solicita el ascensor
    BEXT_P1_top_to_agrupador: in std_logic; --Boton planta 1 que solicita el ascensor
    BEXT_P2_top_to_agrupador: in std_logic; --Boton planta 2 que solicita el ascensor
    BEXT_P3_top_to_agrupador: in std_logic; --Boton planta 3 que solicita el ascensor
    BINT_P0_top_to_agrupador: in std_logic; --Boton del interior de la cabina que solicita ir a la planta 0
    BINT_P1_top_to_agrupador: in std_logic; --Boton del interior de la cabina que solicita ir a la planta 1
    BINT_P2_top_to_agrupador: in std_logic; --Boton del interior de la cabina que solicita ir a la planta 2
    BINT_P3_top_to_agrupador: in std_logic; --Boton del interior de la cabina que solicita ir a la planta 3
    Emergencia_top: in std_logic; --Emergencia del ascensor
    EMER_FMS_to_top : out std_logic;
    ASCENSOR_SUBE_motor_to_top: out std_logic;
    ASCENSOR_BAJA_motor_to_top: out std_logic;
    PUERTA_ABRE_motor_to_top: out std_logic;
    PUERTA_CIERRA_motor_to_top: out std_logic;
    LEDS : out std_logic_vector(6 downto 0)
    );
end Top;

architecture Behavioral of Top is
    Component COUNTER
    Generic (                                                   
           WIDTH : positive := 4
    );
    Port ( 
           RESET_N : in STD_LOGIC;                              -- Reset asíncrono activo a nivel bajo. Máxima prioridad
           CE : in STD_LOGIC;                                   -- CHIP ENABLE síncrono
           CLK : in STD_LOGIC;                                  -- Señal de reloj
           CAR_IN : in STD_LOGIC;                               -- Coche entra al parking. Señal síncrona
           CAR_OUT : in STD_LOGIC;                              -- Coche sale del parking. Señal síncrona
           FULL : out STD_LOGIC;                                -- Salida booleana - planta llena
           COUNT : out UNSIGNED (WIDTH-1 downto 0)
     );
     end component; 
     
     Component agrupador
     generic (
        Nplantas : positive := 4  -- Número de plantas del ascensor
     );
     port (
            PLANTA0 : in std_logic;  --Señal de la planta 0
            PLANTA1 : in std_logic;  --Señal de la planta 1
            PLANTA2 : in std_logic;  --Señal de la planta 2
            PLANTA3 : in std_logic;  --Señal de la planta 3
            SALIDA : out std_logic_vector(NPlantas-1 downto 0) --Vector agrupado
    );
      end component;
      
    Component GestorPrioridades is
      Generic(
           NUMERO_PLANTAS: INTEGER := 4
      );
    
      Port ( 
           CLK : in STD_LOGIC;  -- Señal de reloj
           RESET : in STD_LOGIC;    -- Señal de RESET para EMERGENCIA
           PLANTA_PULSADA: in STD_LOGIC_VECTOR (NUMERO_PLANTAS-1 downto 0); -- Vector que indica el botón seleccionado en la cabina
           PLANTA_LLAMADA: in STD_LOGIC_VECTOR (NUMERO_PLANTAS-1 downto 0); -- Vector que indica botones de planta externos
           LLENO : in STD_LOGIC_VECTOR (NUMERO_PLANTAS-1 downto 0); -- Vector que almacena el estado de las plantas del parking (plantas 0,1,2,3) 0 siempre estará a 0
           ACCION_MOTOR: in STD_LOGIC_VECTOR (1 downto 0); -- Vector con estado del motor
           DESTINO_FINAL: out STD_LOGIC_VECTOR (NUMERO_PLANTAS-1 downto 0) -- Indica planta a la que ir
           );
     end component;
  
    Component FSM is
      generic (
        Nplantas : positive := 4;  -- Número de plantas del ascensor
      	constant TIEMPO_ABRIR : integer := 3;
      	constant TIEMPO_CERRAR : integer := 3;
      	constant TIEMPO_ABIERTO : integer := 3;
      	constant TIEMPO_ESPERA : integer := 3
      );
      port (
      	DESTINO : in std_logic_vector(Nplantas-1 downto 0); -- Petición para ir a una nueva planta
        EMERGENCIA : in std_logic;  -- Aviso de emergencia activo a nivel alto
      	PLANTAACTUAL : in std_logic_vector(Nplantas-1 downto 0); -- Planta actual del ascensor recogido por el sensor
      	CLK : in std_logic;
        MOVIMIENTOMOTOR : out std_logic_vector(1 downto 0); -- Orden de movimiento del motor
        MOVIMIENTOPUERTA : out std_logic_vector(1 downto 0); -- Orden de movimiento de la puerta
        SALIDAEMERGENCIA : out std_logic;  -- Indicador de emergencia
        ESTADO_ACTUAL : out std_logic_vector(3 downto 0) --Indicador de en que estado se encuentra el sistema
      );
      end component;
      
     component Motor
      generic(
        constant speed: integer :=30_000    -- Velocidad del motor
      );
      port(
        CLK : in std_logic; -- Reloj
        ORDEN_MOTOR : in std_logic_vector(1 downto 0); -- Orden de subir, bajar o quieto
        PWM1, PWM2 : out std_logic -- Salidas PWM para el motor
      );
    end component;
    
    component Codificador_Panel_Decoder
       generic (
          Nplantas : positive := 4;  -- Número de plantas del ascensor
          Plantas_Bin: positive := 2 --Número de bits+1 que tiene el valor bimario de la planta
       );
       port (
          IN_PLANTA : in std_logic_vector(Nplantas-1 downto 0); --Planta que llega del panel o los sensores (?)
          OUT_PLANTA : out std_logic_vector(Plantas_BIN downto 0); -- Conversión del valor de la planta a binario
          CLK : in std_logic --Señal síncrona de reloj
    );
    end component;
    
    component decoder_indicador
       generic (                                                   
          NPLANTAS : positive := 2                             -- Parámetro genérico para mayor flexibilidad (si se aumenta nº plantas)
       );
       Port (
          PLANTA : in std_logic_vector (NPLANTAS downto 0);     -- Indica la planta. En total 4
          EMER  : in std_logic;
          MOTOR_ASCENSOR : in std_logic_vector(1 downto 0);  -- Motor indica subiendo o bajando
          LED_PANTALLA  : out std_logic_vector(6 downto 0)   -- Se muestra por los segmentos el número o letra
       );
    end component;
   
     signal FULL1_Counter_to_agrupador: std_logic; --Señal primer parking lleno
     signal FULL2_Counter_to_agrupador: std_logic; --Señal segundo parking lleno
     signal FULL3_Counter_to_agrupador: std_logic; --Señal tercer parking lleno
     signal VECTORLLENO_agrupador_toPrioridad: std_logic_vector(Nplantas-1 downto 0); --Vector palntas llenas
     signal VECTOREXT_agrupador_to_Prioridad: std_logic_vector(Nplantas-1 downto 0); --Vector solicitudes externas
     signal VECTORINT_agrupador_to_Prioridad: std_logic_vector(Nplantas-1 downto 0);  --Vector solicitudes internas
     signal MOTOR_PUERTA: std_logic_vector(1 downto 0); -- Señal motor de puerta
     signal MOTOR_ASCENSOR: std_logic_vector(1 downto 0);  --Señal motor de ascensor
     signal DESTINO_Prioridad_to_FMS: std_logic_vector(Nplantas-1 downto 0); --Vector con planta a la que moverse
     signal PLANTAACTUAL_Top_to_FMS: std_logic_vector(Nplantas-1 downto 0); --PENDIENTE DE DETERMINAR COMO SE CONFORMA Vector que indica en que planta se encuentra el sistema en cada momento 
     signal PLANTAACTUAL_BIN_Codificador_to_Decoder: std_logic_vector(Plantas_BIN downto 0);
     signal EMER_FMS_to_señal: std_logic;
     
     
     begin
     
Inst_Counter1: COUNTER Port map ( --Contador de parking planta 1
    RESET_N => RESET_N_top_to_counter,
    CLK => clk,
    CE => '1',
    CAR_IN => C_I1_top_to_counter,
    CAR_OUT => C_O1_top_to_counter,
    FULL => FULL1_Counter_to_agrupador
);

Inst_Counter2: COUNTER Port map ( --Contador de parking planta 2
    RESET_N => RESET_N_top_to_counter,
    CLK => clk,
    CE => '1',
    CAR_IN => C_I2_top_to_counter,
    CAR_OUT => C_O2_top_to_counter,
    FULL => FULL2_Counter_to_agrupador
);

Inst_Counter3: COUNTER Port map (  --Contador de parking planta 3
    RESET_N => RESET_N_top_to_counter,
    CLK => clk,
    CE => '1',
    CAR_IN => C_I3_top_to_counter,
    CAR_OUT => C_O3_top_to_counter,
    FULL => FULL3_Counter_to_agrupador
);

Inst_agrupador_lleno: agrupador Port map (
            PLANTA0 => '0',
            PLANTA1 => FULL1_Counter_to_agrupador,
            PLANTA2 => FULL2_Counter_to_agrupador,
            PLANTA3 => FULL3_Counter_to_agrupador,
            SALIDA => VECTORLLENO_agrupador_toPrioridad
);

Inst_agrupador_ext: agrupador Port map (
            PLANTA0 =>  BEXT_P0_top_to_agrupador,
            PLANTA1 =>  BEXT_P1_top_to_agrupador,
            PLANTA2 =>  BEXT_P2_top_to_agrupador,
            PLANTA3 =>  BEXT_P3_top_to_agrupador,
            SALIDA => VECTOREXT_agrupador_to_Prioridad
);

Inst_agrupador_int: agrupador Port map (
            PLANTA0 =>  BINT_P0_top_to_agrupador,
            PLANTA1 =>  BINT_P1_top_to_agrupador,
            PLANTA2 =>  BINT_P2_top_to_agrupador,
            PLANTA3 =>  BINT_P3_top_to_agrupador,
            SALIDA => VECTORINT_agrupador_to_Prioridad
);

Inst_GestorPrioridades: GestorPrioridades Port map( 
           CLK  => clk, 
           RESET => Emergencia_top,
           PLANTA_PULSADA => VECTORINT_agrupador_to_Prioridad, 
           PLANTA_LLAMADA => VECTOREXT_agrupador_to_Prioridad, 
           LLENO=> VECTORLLENO_agrupador_toPrioridad, 
           ACCION_MOTOR => MOTOR_ASCENSOR, 
           DESTINO_FINAL => DESTINO_Prioridad_to_FMS
);

Inst_FMS: FSM Port map (
      	DESTINO => DESTINO_Prioridad_to_FMS, 
        EMERGENCIA => Emergencia_top,  
      	PLANTAACTUAL => PLANTAACTUAL_Top_to_FMS,
      	CLK => clk,
        MOVIMIENTOMOTOR => MOTOR_ASCENSOR,
        MOVIMIENTOPUERTA => MOTOR_PUERTA, 
        SALIDAEMERGENCIA => EMER_FMS_to_señal  
);

Inst_Motor_Puerta: Motor Port map(
        CLK => clk,
        ORDEN_MOTOR => MOTOR_PUERTA, 
        PWM1 => PUERTA_ABRE_motor_to_top,
        PWM2  => PUERTA_CIERRA_motor_to_top
); 

Inst_Motor_Ascensor: Motor Port map(
        CLK => clk,
        ORDEN_MOTOR => MOTOR_ASCENSOR, 
        PWM1 => ASCENSOR_SUBE_motor_to_top, 
        PWM2  => ASCENSOR_BAJA_motor_to_top
); 

Inst_codificador: Codificador_Panel_Decoder Port map(
        IN_PLANTA => PLANTAACTUAL_Top_to_FMS,
        OUT_PLANTA => PLANTAACTUAL_BIN_Codificador_to_Decoder,
        CLK => clk
);

Inst_decoder_indicador: decoder_indicador Port map(
          PLANTA => PLANTAACTUAL_Top_to_FMS,     -- Indica la planta. En total 4
          EMER  => EMER_FMS_to_señal,
          MOTOR_ASCENSOR => MOTOR_ASCENSOR,  -- Motor indica subiendo o bajando
          LED_PANTALLA => LEDS    -- Se muestra por los segmentos el número o letra
       );
        
end Behavioral;
