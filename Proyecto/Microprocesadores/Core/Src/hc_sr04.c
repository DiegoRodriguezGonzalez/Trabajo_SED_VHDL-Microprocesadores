#include "tim.h"
#include "hc_sr04.h"

uint16_t dist = 0;

void HAL_TIM_IC_CaptureCallback(TIM_HandleTypeDef *htim)
{
    if(htim->Channel == HAL_TIM_ACTIVE_CHANNEL_1)
    {
        static uint32_t t_ini = 0;
        static uint32_t t_end = 0;
        static uint8_t flag_captured = 0;

        if(flag_captured == 0)
        {
            // Primer borde detectado (RISING)
            t_ini = HAL_TIM_ReadCapturedValue(htim, TIM_CHANNEL_1);
            flag_captured = 1;

            // Cambiar polaridad a FALLING para capturar el siguiente borde
            __HAL_TIM_SET_CAPTUREPOLARITY(htim, TIM_CHANNEL_1, TIM_INPUTCHANNELPOLARITY_FALLING);
        }
        else if(flag_captured == 1)
        {
            // Segundo borde detectado (FALLING)
            t_end = HAL_TIM_ReadCapturedValue(htim, TIM_CHANNEL_1);

            uint32_t t_time = 0;
            if(t_end > t_ini) {
                t_time = t_end - t_ini;
            } else {
                t_time = (0xFFFF - t_ini) + t_end;
            }

            // Calcular distancia (usando factor predefinido para mayor precisión)
            #define SCALE_FACTOR 0.017 // (0.034 / 2)
            dist = (uint16_t)(t_time * SCALE_FACTOR * 10);

            // Preparar para la próxima medición
            flag_captured = 0;
            __HAL_TIM_SET_CAPTUREPOLARITY(htim, TIM_CHANNEL_1, TIM_INPUTCHANNELPOLARITY_RISING);
        }
    }
}


void HCSR04_Init(void)
{
	HAL_GPIO_WritePin(Trigger_GPIO_Port, Trigger_Pin, GPIO_PIN_RESET);
	HAL_TIM_IC_Start_IT(&htim1, TIM_CHANNEL_1);
}

uint16_t HCSR04_Get_Distance(void)
{
	HAL_GPIO_WritePin(Trigger_GPIO_Port, Trigger_Pin, GPIO_PIN_SET);
	__HAL_TIM_SetCounter(&htim1, 0);
	while (__HAL_TIM_GetCounter(&htim1) < 10);
	HAL_GPIO_WritePin(Trigger_GPIO_Port, Trigger_Pin, GPIO_PIN_RESET);
	__HAL_TIM_ENABLE_IT(&htim1, TIM_IT_CC1);
	return dist;
}
