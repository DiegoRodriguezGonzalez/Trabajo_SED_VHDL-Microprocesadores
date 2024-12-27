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
//#include "key.h"
#include "hc_sr04.h"
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */
#define NUM_ROWS 4
#define NUM_COLS 4
/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/

/* USER CODE BEGIN PV */
volatile char key = '\0';
volatile uint8_t flag_key = 0;
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

volatile uint8_t active_column = 0;
/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */
#define CS_LOW()  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_4, GPIO_PIN_RESET)
#define CS_HIGH() HAL_GPIO_WritePin(GPIOA, GPIO_PIN_4, GPIO_PIN_SET)
#define tres_s 500
uint16_t distancia = 0;
char buf_lcd[18];
volatile uint32_t temp;
//volatile uint8_t flag;

void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin)
{
		static uint32_t last_interrupt_time = 0;
	    uint32_t current_time = HAL_GetTick();

	// Evitar rebotes con un retardo de 50 ms
	    if (current_time - last_interrupt_time < 100) {
	        return;
	    }
	    last_interrupt_time = current_time;

	    if (flag_key == 1) {
	            return; // Ya hay un evento en cola, descarta esta interrupción
	        }

	// Encontrar la columna del interruptor activado
	    for (int col = 0; col < NUM_COLS; col++) {
	        if (GPIO_Pin == col_pins[col]) {
	            active_column = col;  // Almacenar columna
	            flag_key = 1;         // Activar flag
	            temp = HAL_GetTick();
	            break;
	        }
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
	  if (flag_key == 1) {

		  int local_column = active_column; // Copiar datos a variables locales

		  // Escanear la tecla presionada
		  for (int row = 0; row < NUM_ROWS; row++) {
			  for (int r = 0; r < NUM_ROWS; r++) {
				  HAL_GPIO_WritePin(row_ports[r], row_pins[r], (r == row) ? GPIO_PIN_RESET : GPIO_PIN_SET);
			  }

			  if (!(HAL_GPIO_ReadPin(col_ports[local_column], col_pins[local_column]))) {
				  key = keys[row][local_column]; // Almacenar tecla localmente
				  break;
			  }

		  }

		  // Restaurar estado de las filas
			  for (int r = 0; r < NUM_ROWS; r++) {
				  HAL_GPIO_WritePin(row_ports[r], row_pins[r], GPIO_PIN_SET);
			  }

		  flag_key = 0;  // Reset flag
	  }


	  // Display the key pressed
	  if (key != '\0') {
		  lcd_clear();
		  switch (key) {
			  case '1': lcd_enviar("Planta 1", 0, 4); HAL_Delay(2000); break;
			  case '2': lcd_enviar("Planta 2", 0, 4); break;
			  case '3': lcd_enviar("Planta 3", 0, 4); break;
			  case '*': lcd_enviar("Emergencia", 0, 3); break;
			  default: break;
		  }
		  //if tiempo pasado (temporizador)
		  key = '\0';  // Resetear tecla
	  }
	  else lcd_enviar("Elegir planta", 0, 1);

	//  else if(HAL_GetTick - temp >= 2000)
		  //for (volatile uint32_t i = 0; i < 300; i++)lcd_enviar("Elegir planta", 0, 1);



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

	  //CS_LOW(); // Activar esclavo
	  //HAL_SPI_TransmitReceive(&hspi1, txData, rxData, sizeof(txData), HAL_MAX_DELAY);
	  //CS_HIGH(); // Desactivar esclavo

	  //HAL_Delay(1000); // Esperar 1 segundo
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
