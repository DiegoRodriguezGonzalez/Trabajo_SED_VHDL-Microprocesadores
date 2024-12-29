#include "funciones.h"
#include "main.h"


void representaPlanta(char *key){
	if (*key != '\0') {
			  lcd_clear();
			  switch (*key) {
			      case '0': lcd_enviar("Planta 0", 0, 4); HAL_Delay(2000); break;
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
			  *key = '\0';  // Resetear tecla

		  }
		  else lcd_enviar("Elegir planta", 0, 1);
}

char* calculaPosicion (uint16_t distancia)
{

	if (distancia >= P0_ab)
	{
		if (distancia <= P0_ar) return "00100001";
		if (distancia <= P1_ar) return "00100010";
		if (distancia <= P2_ar) return "00100100";
		if (distancia <= P3_ar) return "00101000";
	}
	else return "00000000"; //Si se devuelve 0000'0000 se ignora la transmisión

}

char* calculaDestino (char key)
{

	if (key != '\0'){
		  switch (key) {
			  case '0': return "10000001"; break;
			  case '1': return "10000010"; break;
			  case '2': return "10000100"; break;
			  case '3': return "10001000"; break;
			  case '4': return "otro0000"; break;
			  case '5': return "otro0000"; break;
			  case '6': return "otro0000"; break;
			  case '7': return "otro0000"; break;
			  case '8': return "otro0000"; break;
			  case '9': return "otro0000"; break;
			  case 'A': return "otro0000"; break;
			  case 'B': return "otro0000"; break;
			  case 'C': return "otro0000"; break;
			  case 'D': return "otro0000"; break;
			  case '#': return "otro0000"; break;
			  case '*': return "otro0000"; break;
			  default: break;
		  }

	  }
	 else return "00000000"; //Si se devuelve 0000'0000 se ignora la transmisión

}
