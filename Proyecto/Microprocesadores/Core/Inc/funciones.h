#include <stdint.h>
#define P0_ab 1
#define P0_ar 8 // P1_ab
#define P1_ar 15 //P2_ab
#define P2_ar 22 //P3_ab
#define P3_ar 30

void representaPlanta(char *key);

uint8_t calculaPosicion (uint16_t distancia);

uint8_t calculaDestino (char key);

float getTemperature (uint32_t val);

