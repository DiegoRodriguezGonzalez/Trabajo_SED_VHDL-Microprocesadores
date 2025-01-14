#include "funciones.h"
#include "main.h"


void representaPlanta(char key){
	if (key != '\0') {
			  //tiempo_tick = HAL_GetTick();
			  lcd_clear();
			  switch (key) {
			      case '0': for(int j = 0; j<350; j++)lcd_enviar("Planta 0", 0, 4); break;
				  case '1': for(int j = 0; j<350; j++)lcd_enviar("Planta 1", 0, 4); break;
				  case '2': for(int j = 0; j<350; j++)lcd_enviar("Planta 2", 0, 4); break;
				  case '3': for(int j = 0; j<350; j++)lcd_enviar("Planta 3", 0, 4); break;
				  case '4': for(int j = 0; j<350; j++)lcd_enviar("Planta 4", 0, 4); break;
				  case '5': for(int j = 0; j<350; j++)lcd_enviar("Planta 5", 0, 4); break;
				  case '6': for(int j = 0; j<350; j++)lcd_enviar("Planta 6", 0, 4); break;
				  case '7': for(int j = 0; j<350; j++)lcd_enviar("Planta 7", 0, 3); break;
				  case '8': for(int j = 0; j<350; j++)lcd_enviar("Planta 8", 0, 4); break;
				  case '9': for(int j = 0; j<350; j++)lcd_enviar("Planta 9", 0, 4); break;
				  case 'A': for(int j = 0; j<350; j++)lcd_enviar("Planta A", 0, 4); break;
				  case 'B': for(int j = 0; j<350; j++)lcd_enviar("Planta B", 0, 3); break;
				  case 'C': for(int j = 0; j<350; j++)lcd_enviar("Planta C", 0, 4); break;
				  case 'D': for(int j = 0; j<350; j++)lcd_enviar("Planta D", 0, 4); break;
				  case '#': for(int j = 0; j<350; j++)lcd_enviar("Planta #", 0, 4); break;
				  case '*': for(int j = 0; j<350; j++)lcd_enviar("Emergencia", 0, 3); break;
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
		  else lcd_enviar("Elegir planta", 0, 1);
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
			  case '4': return 0b00000000; break;
			  case '5': return 0b00000000; break;
			  case '6': return 0b00000000; break;
			  case '7': return 0b00000000; break;
			  case '8': return 0b00000000; break;
			  case '9': return 0b00000000; break;
			  case 'A': return 0b01000001; break;
			  case 'B': return 0b01000010; break;
			  case 'C': return 0b01000100; break;
			  case 'D': return 0b01001000; break;
			  case '#': return 0b00000000; break;
			  case '*': return 0b00000000; break;
			  default: break;
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
