#include "tim.h"
#include "hc_sr04.h"
#include "stdbool.h"

uint16_t dist = 0;	// Distancia auxiliar
static uint16_t dist_fin = 0;	// Distancia final
bool flag = false;	//Se emplea para que la primera medida se haga y no se enclave en caso de que el ascensor no haya quedado en la planta baja

#define MIN_DISTANCE 0         // Distancia mínima válida (en cm)
#define MAX_DISTANCE 100        // Distancia máxima válida (en cm)
#define TOLERANCIA 4 // Tolerancia permitida en cm

void procesadoTemporizador(TIM_HandleTypeDef *htim)
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
			#define FACTOR_ESCALA 0.017 // (0.034 / 2)
			dist = (uint16_t)(t_time * FACTOR_ESCALA * 10);

			if (!flag || (dist >= MIN_DISTANCE && dist <= MAX_DISTANCE)) //Filtrado de señales atípicas
			{
				//Hacer que la distancia no pueda variar más de TOLERANCIA cm
				if (!flag ||(dist >= dist_fin - TOLERANCIA && dist <= dist_fin + TOLERANCIA))
					dist_fin = dist; // Si dentro de rango, memoria almacena el valor
				//Si no, se usa el valor anterior
				flag = true;
			}
			// Preparar para la próxima medición
			flag_captured = 0;
			__HAL_TIM_SET_CAPTUREPOLARITY(htim, TIM_CHANNEL_1, TIM_INPUTCHANNELPOLARITY_RISING);
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
	return dist_fin;
}
