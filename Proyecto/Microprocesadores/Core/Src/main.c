/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2024 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "i2c.h"
#include "spi.h"
#include "tim.h"
#include "gpio.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include <stdio.h>
#include "i2c-lcd.h"
#include "key.h"
#include "hc_sr04.h"
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

#define tres_s 500

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/

/* USER CODE BEGIN PV */
volatile char key = '\0';

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
/* USER CODE BEGIN PFP */
void representaPlanta(void);
/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */

uint16_t distancia = 0;
char buf_lcd[18];

volatile uint8_t contador = 0;

void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin)
{
		interrupt(GPIO_Pin);
}

void HAL_TIM_IC_CaptureCallback(TIM_HandleTypeDef *htim)
{
    if(htim->Channel == HAL_TIM_ACTIVE_CHANNEL_1)
    {
    	procesadoTemporizador(htim);
    }
}


/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{

  /* USER CODE BEGIN 1 */

  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_SPI1_Init();
  MX_I2C1_Init();
  MX_TIM1_Init();
  /* USER CODE BEGIN 2 */
  HCSR04_Init();
  lcd_init();

  for (volatile uint32_t i = 0; i < tres_s; i++)lcd_enviar("Selecciona:",0,1); // Retardo para evitar HAL_Delay()
  lcd_clear();
  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
	  //Gestión de la interrupción
	  flagTecla(&key);

	  // Mostrar la tecla pulsada
	  representaPlanta();

	  /*distancia = HCSR04_Get_Distance();
	  sprintf(buf_lcd, "%lu", distancia);
	  lcd_clear();
	  lcd_enviar(buf_lcd, 0, 0); //(ms,row,colum-> mueve a la derecha) Centrado
	  lcd_send_string("     cm");
	  HAL_Delay(400);*/
	  //lcd_barrido("Planta 2");
	  /*lcd_enviar("Planta 2", 0, 4); //(ms,row,colum-> mueve a la derecha) Centrado
	  HAL_Delay(5000);
	  lcd_clear();*/

    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
}
  /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Configure the main internal regulator output voltage
  */
  __HAL_RCC_PWR_CLK_ENABLE();
  __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE1);

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
  RCC_OscInitStruct.HSEState = RCC_HSE_ON;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
  RCC_OscInitStruct.PLL.PLLM = 4;
  RCC_OscInitStruct.PLL.PLLN = 50;
  RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
  RCC_OscInitStruct.PLL.PLLQ = 7;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV4;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV16;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_1) != HAL_OK)
  {
    Error_Handler();
  }
}

/* USER CODE BEGIN 4 */
int __io_putchar(int ch) {
 ITM_SendChar(ch);
 return ch;
 }


void representaPlanta(void){
	if (key != '\0') {
			  lcd_clear();
			  switch (key) {
				  case '1': lcd_enviar("Planta 1", 0, 4); HAL_Delay(2000); break;
				  case '2': lcd_enviar("Planta 2", 0, 4); HAL_Delay(2000);break;
				  case '3': lcd_enviar("Planta 3", 0, 4); HAL_Delay(2000);break;
				  case '4': lcd_enviar("Planta 4", 0, 4); HAL_Delay(2000); break;
				  case '5': lcd_enviar("Planta 5", 0, 4); HAL_Delay(2000);break;
				  case '6': lcd_enviar("Planta 6", 0, 4); HAL_Delay(2000);break;
				  case '7': lcd_enviar("Planta 7", 0, 3); HAL_Delay(2000);break;
				  case '8': lcd_enviar("Planta 8", 0, 4); HAL_Delay(2000); break;
				  case '9': lcd_enviar("Planta 9", 0, 4); HAL_Delay(2000);break;
				  case 'A': lcd_enviar("Planta A", 0, 4); HAL_Delay(2000);break;
				  case 'B': lcd_enviar("Planta B", 0, 3); HAL_Delay(2000);break;
				  case 'C': lcd_enviar("Planta C", 0, 4); HAL_Delay(2000); break;
				  case 'D': lcd_enviar("Planta D", 0, 4); HAL_Delay(2000);break;
				  case '#': lcd_enviar("Planta #", 0, 4); HAL_Delay(2000);break;
				  case '*': lcd_enviar("Emergencia", 0, 3); HAL_Delay(2000);break;
				  default: break;
			  }
			  //if tiempo pasado (temporizador)
			  key = '\0';  // Resetear tecla

		  }
		  else lcd_enviar("Elegir planta", 0, 1);
}


/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  __disable_irq();
  while (1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}

#ifdef  USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
