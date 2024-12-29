#ifndef INC_HC_SR04_H_
#define INC_HC_SR04_H_

void procesadoTemporizador(TIM_HandleTypeDef *htim);
void HCSR04_Init(void);
uint16_t HCSR04_Get_Distance(void);

#endif
