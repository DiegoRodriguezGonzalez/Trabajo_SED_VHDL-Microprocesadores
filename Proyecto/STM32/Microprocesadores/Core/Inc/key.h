#ifndef INC_KEYPAD_4X4_H_
#define INC_KEYPAD_4X4_H_

#define NUM_ROWS 4
#define NUM_COLS 4
#define DEBOUNCE_TIME 50   // Tiempo entre verificaciones (ms)

void interrupt (uint16_t GPIO_Pin, TIM_HandleTypeDef *htim);
void flagTecla(char *key);

#endif

