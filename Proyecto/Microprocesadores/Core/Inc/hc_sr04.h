#ifndef INC_HC_SR04_H_
#define INC_HC_SR04_H_

uint8_t getDistance();
void delay (uint16_t time);
void procesadoTemporizador(TIM_HandleTypeDef *htim);

#endif
