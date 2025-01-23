#include <stdint.h>
#include <stdlib.h>

#define P0_ab 2
#define P0_ar 6 // P1_ab
#define P1_ar 11 //P2_ab
#define P2_ar 16 //P3_ab
#define P3_ar 22 //Por ejemplo

void representaPlanta(char key, float temperature);

uint8_t calculaPosicion (uint16_t distancia);

uint8_t calculaDestino (char *key, uint8_t *flag_t);

float getTemperature (uint32_t val);

