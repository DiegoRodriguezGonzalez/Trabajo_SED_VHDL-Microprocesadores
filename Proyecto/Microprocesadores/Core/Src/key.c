#include "main.h"
#include "key.h"
#include "tim.h"

volatile uint8_t active_column = 0;
volatile uint8_t flag_key = 0;
volatile uint32_t prueba;
const char keys[NUM_ROWS][NUM_COLS] = {
    {'1', '2', '3', 'A'},
    {'4', '5', '6', 'B'},
    {'7', '8', '9', 'C'},
    {'*', '0', '#', 'D'}
};

GPIO_TypeDef* row_ports[NUM_ROWS] = {R1_GPIO_Port, R2_GPIO_Port, R3_GPIO_Port, R4_GPIO_Port};
uint16_t row_pins[NUM_ROWS] = {R1_Pin, R2_Pin, R3_Pin, R4_Pin};

GPIO_TypeDef* col_ports[NUM_COLS] = {C1_GPIO_Port, C2_GPIO_Port, C3_GPIO_Port, C4_GPIO_Port};
uint16_t col_pins[NUM_COLS] = {C1_Pin, C2_Pin, C3_Pin, C4_Pin};


void interrupt (uint16_t GPIO_Pin)
{
	static uint32_t last_interrupt_time = 0; // Tiempo del último interrupt
			uint32_t current_time = HAL_GetTick();  // Tiempo actual en milisegundos

		// Evitar rebotes con un retardo de DEBOUNCE_TIME ms
		    if ((current_time - last_interrupt_time) < DEBOUNCE_TIME) {
		        return; // Ignorar la interrupción si ocurre demasiado rápido
		    }

		    last_interrupt_time = current_time; // Actualizar el tiempo del último interrupt

		    if (flag_key == 0) {

		    	 //__disable_irq();  // Desactivar interrupciones para evitar conflictos

		    	 // Encontrar la columna del interruptor activado
				for (int col = 0; col < NUM_COLS; col++) {
					if (GPIO_Pin == col_pins[col]) {
						//__disable_irq();
						active_column = col;  // Almacenar columna
						flag_key = 1;         // Activar flag
						//HAL_TIM_Base_Start_IT(&htim3);
						//__HAL_GPIO_EXTI_CLEAR_IT(GPIO_Pin);
						//__enable_irq();
						break;
					}
				}

				// Limpieza del flag de interrupción
				   // __HAL_GPIO_EXTI_CLEAR_IT(GPIO_Pin);
			   // __enable_irq();  // Reactivar interrupciones
		    }

		    /*if (GPIO_Pin == GPIO_PIN_0 )HAL_GPIO_TogglePin(GPIOD, GPIO_PIN_12);
		    else if (GPIO_Pin == GPIO_PIN_1 )HAL_GPIO_TogglePin(GPIOD, GPIO_PIN_13);
		    else if (GPIO_Pin == GPIO_PIN_2 )HAL_GPIO_TogglePin(GPIOD, GPIO_PIN_14);
		    else if (GPIO_Pin == GPIO_PIN_3 )HAL_GPIO_TogglePin(GPIOD, GPIO_PIN_15);*/

		    /*if (contador == 0 )HAL_GPIO_TogglePin(GPIOD, GPIO_PIN_12);
			else if (contador == 1 )HAL_GPIO_TogglePin(GPIOD, GPIO_PIN_13);
			else if (contador == 2 )HAL_GPIO_TogglePin(GPIOD, GPIO_PIN_14);
			else if (contador == 3 )HAL_GPIO_TogglePin(GPIOD, GPIO_PIN_15);

		    contador++;*/
}

void flagTecla(char *key)
{
	if (flag_key == 1) {
			//__disable_irq();  // Desactiva interrupciones durante el escaneo
			int detected_row = -1;

			for (int row = 0; row < NUM_ROWS; row++) {
				// Configurar filas
				for (int r = 0; r < NUM_ROWS; r++) {
					HAL_GPIO_WritePin(row_ports[r], row_pins[r], (r == row) ? GPIO_PIN_RESET : GPIO_PIN_SET);
				}

				// Detectar columna activa
				if (!HAL_GPIO_ReadPin(col_ports[active_column], col_pins[active_column])) {
					detected_row = row;
					break;
				}
			}

			// Resetear filas
			for (int r = 0; r < NUM_ROWS; r++) {
				HAL_GPIO_WritePin(row_ports[r], row_pins[r], GPIO_PIN_RESET);
			}

			// Registrar tecla detectada
			if (detected_row != -1) {
				*key = keys[detected_row][active_column]; //Cambio del contenido del puntero key. Sin * se cambia la dirección
			}

			//HAL_GPIO_WritePin(GPIOD, GPIO_PIN_12,1);
			prueba = HAL_GetTick();
			flag_key = 0;  // Resetear el flag
			//active_column = 7;

			//__enable_irq();
	}

	//if(HAL_GetTick()-prueba >= 2000)  HAL_GPIO_WritePin(GPIOD, GPIO_PIN_12,0);


}
