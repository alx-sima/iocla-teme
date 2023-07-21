#ifndef __UTILS_H
#define __UTILS_H

#include <stddef.h>

#include "structs.h"

/*
 * Elibereaza memoria alocata pentru un sensor.
 */
void free_sensor(sensor *s);

/*
 * Elibereaza memoria alocata pentru toti senzorii din
 * vectorul `sensors` (nu si vectorul in sine).
 */
void free_all_sensors(sensor **sensors, int nr_sensors);

/*
 * Aranjeaza vectorul de senzori `sensors` in ordine inversa.
 */
void mirror_vector(sensor **sensors, size_t len);

/*
 * Returneaza 1 daca sensorul `s` este valid, 0 altfel.
 */
int valid_sensor(sensor *s);

#endif // __UTILS_H
