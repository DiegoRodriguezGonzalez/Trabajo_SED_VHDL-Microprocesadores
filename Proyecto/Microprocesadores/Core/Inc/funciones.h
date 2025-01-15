#include <stdint.h>
#define P0_ab 0
#define P0_ar 4 // P1_ab
#define P1_ar 12 //P2_ab
#define P2_ar 17 //P3_ab
#define P3_ar 22 //Por ejemplo

void representaPlanta(char key);

uint8_t calculaPosicion (uint16_t distancia);

uint8_t calculaDestino (char *key, uint8_t *flag_t);

float getTemperature (uint32_t val);

