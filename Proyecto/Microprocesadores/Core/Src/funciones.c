#include "funciones.h"
#include "main.h"


void representaPlanta(char key, float temperature){
	if (key != '\0') {
			  //tiempo_tick = HAL_GetTick();
			  lcd_clear();
			  lcd_put_cur(0,4);
			  switch (key) {
			      case '0': lcd_send_string("Planta 0"); break;
				  case '1': lcd_send_string("Planta 1"); break;
				  case '2': lcd_send_string("Planta 2"); break;
				  case '3': lcd_send_string("Planta 3"); break;
				  case '4': lcd_put_cur(0,2); lcd_send_string("No existe P4"); break;
				  case '5': lcd_put_cur(0,2); lcd_send_string("No existe P5"); break;
				  case '6': lcd_put_cur(0,2); lcd_send_string("No existe P6"); break;
				  case '7': lcd_put_cur(0,2); lcd_send_string("No existe P7"); break;
				  case '8': lcd_put_cur(0,2); lcd_send_string("No existe P8"); break;
				  case '9': lcd_put_cur(0,2); lcd_send_string("No existe P9"); break;
				  case 'A': lcd_send_string("Planta 0"); break;
				  case 'B': lcd_send_string("Planta 1"); break;
				  case 'C': lcd_send_string("Planta 2"); break;
				  case 'D': lcd_send_string("Planta 3"); break;
				  case '#': lcd_put_cur(0,2); lcd_send_string("No existe P#"); break;
				  case '*': lcd_put_cur(0,2); lcd_send_string("No existe P*"); break;
				  default: break;
			  }

			  //*key = '\0';  // Resetear tecla
/*
			  //if(*flag_t == 1
			  if(HAL_GetTick()- tiempo_tick >=1000)
			  {
				  *key = '\0';  // Resetear tecla
				  //*flag_t = 0;
				  HAL_GPIO_TogglePin(GPIOD, GPIO_PIN_14);
			  }
			  */

		  }
		  else {
			  lcd_clear();
			  lcd_put_cur(0,2);
			  lcd_send_string("Temperatura: ");
			  char str[4];
			  snprintf(str, sizeof(str), "%.0f", (float)temperature);
			  lcd_put_cur(1,7);
			  lcd_send_string(str);

			  //sprintf(str, "%lu", temperature);
			  //lcd_put_cur(1,4);
			  //lcd_send_string(str);

		  }
}

uint8_t calculaPosicion (uint16_t distancia)
{

	if (distancia >= P0_ab)
	{
		if (distancia < P0_ar) return 0b00100001; //P0
		if (distancia < P1_ar) return 0b00100010; //P1
		if (distancia < P2_ar) return 0b00100100; //P2
		if (distancia < P3_ar) return 0b00101000; //P3
	}
	else return 0b00000000; //Si se devuelve 0000'0000 se ignora la transmisión

}

uint8_t calculaDestino (char *key, uint8_t *flag_t)
{

	if (*key != '\0'){

		/*if(HAL_GetTick()- tiempo_tick >=3000)
		  {
			  *key = '\0';  // Resetear tecla
			  //*flag_t = 0;
			  HAL_GPIO_TogglePin(GPIOD, GPIO_PIN_14);
		  }*/
		if(*flag_t){
			*key = '\0';
			*flag_t = 0;
		}
		  switch (*key) {
			  case '0': return 0b10000001; break;
			  case '1': return 0b10000010; break;
			  case '2': return 0b10000100; break;
			  case '3': return 0b10001000; break;
//			  case '4': return 0b00000000; break;
//			  case '5': return 0b00000000; break;
//			  case '6': return 0b00000000; break;
//			  case '7': return 0b00000000; break;
//			  case '8': return 0b00000000; break;
//			  case '9': return 0b00000000; break;
			  case 'A': return 0b01000001; break;
			  case 'B': return 0b01000010; break;
			  case 'C': return 0b01000100; break;
			  case 'D': return 0b01001000; break;
//			  case '#': return 0b00000000; break;
//			  case '*': return 0b00000000; break;
			  default: return 0b00000000; break;
		  }

	  }
	 else return 0b00000000; //Si se devuelve 0000'0000 se ponen a 0000 planta_llamada y planta_pulsada

}

float getTemperature (uint32_t val){
	float voltage;
	float scale_factor = 18.0/56.2;
	voltage = (val+1) * 3.3/256.0;
	return ((voltage-0.76)/0.0025+25)*(scale_factor);	//Se observa que a 18 ºC le corresponde un retorno de 56,2 --> Se corrige para que dé algo coherente
}
