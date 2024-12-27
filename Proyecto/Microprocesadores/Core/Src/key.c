/*#include "main.h"
#include "key.h"

#define TIME 50
#define NUM_ROWS 4
#define NUM_COLS 4

// Definición de las teclas
const char keys[NUM_ROWS][NUM_COLS] = {
    {'1', '2', '3', 'A'},
    {'4', '5', '6', 'B'},
    {'7', '8', '9', 'C'},
    {'*', '0', '#', 'D'}
};

// Definir las filas y columnas
GPIO_TypeDef* row_ports[NUM_ROWS] = {R1_GPIO_Port, R2_GPIO_Port, R3_GPIO_Port, R4_GPIO_Port};
uint16_t row_pins[NUM_ROWS] = {R1_Pin, R2_Pin, R3_Pin, R4_Pin};

GPIO_TypeDef* col_ports[NUM_COLS] = {C1_GPIO_Port, C2_GPIO_Port, C3_GPIO_Port, C4_GPIO_Port};
uint16_t col_pins[NUM_COLS] = {C1_Pin, C2_Pin, C3_Pin, C4_Pin};

// Función para leer la tecla
char Keypad_Get_Char(void)
{
    char val_key = '\0'; // Inicializar tecla como "ninguna"
    int timeout;
    pritnf(val_key);
    // Iterar por cada fila
    for (int row = 0; row < NUM_ROWS; row++)
    {
        // Activar la fila actual (bajar a nivel bajo)
        for (int r = 0; r < NUM_ROWS; r++) {
            HAL_GPIO_WritePin(row_ports[r], row_pins[r], (r == row) ? GPIO_PIN_RESET : GPIO_PIN_SET);
        }

        // Leer las columnas
        for (int col = 0; col < NUM_COLS; col++)
        {
            if (!(HAL_GPIO_ReadPin(col_ports[col], col_pins[col])))
            {
                timeout = TIME; // Establecer límite de tiempo para evitar bloqueo
                while (!(HAL_GPIO_ReadPin(col_ports[col], col_pins[col])) && --timeout > 0)
                {
                    // Breve retardo (puedes usar HAL_Delay para mayor consistencia)
                    for (volatile uint32_t i = 0; i < 500; i++);
                }

                if (timeout > 0) {
                    val_key = keys[row][col]; // Obtener la tecla correspondiente
                    pritnf(val_key);
                    break; // Salir del bucle de columnas
                }
            }
        }

        // Si ya se detectó una tecla, salir del bucle de filas
        if (val_key != '\0') {
        	pritnf("Detectó:");
        	pritnf(val_key);
            break;
        }
    }

    // Restaurar filas a nivel alto
    for (int r = 0; r < NUM_ROWS; r++) {
        HAL_GPIO_WritePin(row_ports[r], row_pins[r], GPIO_PIN_SET);
    }

    return val_key; // Retornar la tecla presionada
}
*/
