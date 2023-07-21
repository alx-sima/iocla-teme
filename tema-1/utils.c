#include <stdlib.h>

#include "structs.h"
#include "utils.h"

/*
 * Interschimba pointerii `*a` si `*b`.
 */
static void swap_ptrs(sensor **a, sensor **b);

/*
 * Verifica daca tire_sensor-ul primit ca parametru este valid.
 */
static inline int valid_tire_sensor(tire_sensor *);

/*
 * Verifica daca power_management_unit-ul primit ca parametru este valid.
 */
static inline int valid_pmu_sensor(power_management_unit *);

void free_sensor(sensor *s)
{
	free(s->operations_idxs);
	free(s->sensor_data);
	free(s);
}

void free_all_sensors(sensor **sensors, int nr_sensors)
{
	for (int i = 0; i < nr_sensors; ++i)
		free_sensor(sensors[i]);
}

void mirror_vector(sensor **sensors, size_t len)
{
	for (int i = 0; i < len / 2; ++i)
		swap_ptrs(&sensors[i], &sensors[len - i - 1]);
}

int valid_sensor(sensor *s)
{
	if (s->sensor_type == TIRE)
		return valid_tire_sensor(s->sensor_data);
	return valid_pmu_sensor(s->sensor_data);
}

static void swap_ptrs(sensor **a, sensor **b)
{
	sensor *aux = *a;
	*a = *b;
	*b = aux;
}

static inline int valid_tire_sensor(tire_sensor *t)
{
	return t->pressure >= 19 && t->pressure <= 28 && t->temperature >= 0 &&
		   t->temperature <= 120 && t->wear_level >= 0 && t->wear_level <= 100;
}

static inline int valid_pmu_sensor(power_management_unit *p)
{
	return p->voltage >= 10 && p->voltage <= 20 && p->current >= -100 &&
		   p->current <= 100 && p->power_consumption >= 0 &&
		   p->power_consumption <= 1000 && p->energy_regen >= 0 &&
		   p->energy_regen <= 100 && p->energy_storage >= 0 &&
		   p->energy_storage <= 100;
}
