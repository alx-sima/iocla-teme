#ifndef __IO_H
#define __IO_H

#include <stddef.h>

#include "structs.h"

/*
 * Citeste comenzi de la tastatura pana la intalnirea comenzii `exit` si le
 * aplica pe vectorul de sensori `*sensors` de lungime `*nr_sensors`.
 */
void read_commands(sensor ***sensors, int *nr_sensors, void **operations);

/*
 * Citeste senzorii din fisierul `filename` si ii returneaza.
 * Numarul de senzori cititi este salvat in `nr_sensors`.
 */
sensor **read_file(char const *filename, int *nr_sensors);

#endif // __IO_H