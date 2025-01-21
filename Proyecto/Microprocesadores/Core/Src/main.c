/* USER CODE BEGIN Header */

/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "adc.h"
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
#include "funciones.h"
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/

/* USER CODE BEGIN PV */

volatile char key = '\0'; // Char que guarda el valor de la tecla pulsada
volatile uint8_t posicion; // Entero sin signo que recoge la posición de la cabina de ascensor (para la planta)
volatile uint8_t destino;  // Entero son signo que recoge el destino de la cabina
volatile uint8_t flag_tiempoTrans = 0; // Flag usado para borrar la tecla tras un tiempo de transmisión
uint8_t distancia = 0; // Entero sin signo que recoge la distancia a la que se encuentra la cabina de ascensor
volatile uint8_t cicloEnvio = 0; // Contador que cambia entre 0 y 1 para enviar los datos alternativamente a la FPGA
uint8_t envioDatos; // Datos que se transmiten a través del SPI
uint32_t ADC_val; // Valor recogido del conversor analógico/digital empleado para obtener la temperatura del sensor de la placa
float temperature; // Float que recoge el valor de la función que devuelve la temperatura correspondiente con el valor obtenido del ADC

extern TIM_HandleTypeDef htim3;

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
/* USER CODE BEGIN PFP */
void actualizaInfoSPI (void); // Función que gestiona la lógica de envío de datos a la FPGA
void enviaSPI (void); // Función encargada del envío de los datos gestionados con actualizaInfoSPI
void gestorTemperatura (void); // Función que calcula el valor de la temperatura correspondiente con el valor recogido por el conversor ADC

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */

void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin)
{
		interrupt(GPIO_Pin, &htim3); // Llamada a la función interrupt, encargada de gestionar la interrupción. Externalizada por limpieza visual
}

void HAL_TIM_IC_CaptureCallback(TIM_HandleTypeDef *htim)
{
	procesadoTemporizador(htim); // Llamada a procesadoTemporizador, gestiona y externalizada.
}

void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)
{
	if (htim->Instance == TIM3)
	{
		flag_tiempoTrans = 1; //Pasados los 3 segundos tras llamar a la planta, se deja de enviar
		HAL_TIM_Base_Stop_IT(&htim3); // Para la cuenta
	}
}


void HAL_ADC_ConvCpltCallback(ADC_HandleTypeDef* hadc){
		if(hadc-> Instance == ADC1 )
		{
			ADC_val = HAL_ADC_GetValue(&hadc1); // Obtiene el valor del conversor
			temperature = getTemperature(ADC_val); // Hace la conversión a un valor real
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
  MX_I2C1_Init();
  MX_TIM1_Init();
  MX_SPI3_Init();
  MX_ADC1_Init();
  MX_TIM3_Init();
  /* USER CODE BEGIN 2 */
  HAL_TIM_IC_Start_IT(&htim1, TIM_CHANNEL_1);
  lcd_init();

  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */

  while (1)
  {
	  //Gestión sensor temperatura
	  gestorTemperatura();

	  //Gestión de la interrupción. Obtención de tecla pulsada
	  flagTecla(&key);

	  //Obtención posición del ascensor con ultrasonidos
	  HCSR04_Read();
	  HAL_Delay(100);
	  distancia = getDistance();

	  //Codificación de planta para envío
	  posicion = calculaPosicion(distancia);

	  //Codificación de tecla pulsada para envío
	  destino = calculaDestino(&key, &flag_tiempoTrans);

	  //Almacenamiento de la información a transmitir
	  actualizaInfoSPI();

	  //Envío de datos a través del SPI
	  enviaSPI();

	  // Mostrar en el panel LCD la tecla pulsada durante 2s
	  representaPlanta(key,temperature);//Comprobar que para 2s ha sucedido la transmisión y no hay una sobreescritura indeseada de key

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

void actualizaInfoSPI (void)
{
	if (cicloEnvio == 0)
		  {
			  envioDatos = posicion; //Ciclo primero envía el dato de la planta en la que se encuentra el ascensor
			  cicloEnvio++;
		  }
		  else
		  {
			  envioDatos = destino; //Ciclo segundo envía el dato del destino seleccionado
			  cicloEnvio = 0;
		  }
}

void enviaSPI (void)
{
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_4, GPIO_PIN_RESET); // Se activa la transmisión master-slave

	HAL_SPI_Transmit(&hspi3, &envioDatos, 1, HAL_MAX_DELAY);

	HAL_GPIO_WritePin(GPIOA,GPIO_PIN_4,GPIO_PIN_SET); // Se desactiva la transmisión M-S
}

void gestorTemperatura (void)
{
		  //Activación del ADC
		  HAL_ADC_Start(&hadc1);

		  //Obtener temperatura
		  if (HAL_ADC_PollForConversion(&hadc1, HAL_MAX_DELAY) == HAL_OK)
		  {
			  ADC_val = HAL_ADC_GetValue(&hadc1);
			  temperature = getTemperature(ADC_val);
		  }

		  //Desactivación del ADC
		  HAL_ADC_Stop(&hadc1);
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
