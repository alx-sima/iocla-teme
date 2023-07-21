#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "io.h"
#include "structs.h"
#include "utils.h"

#define NR_OPERATIONS 8

extern void get_operations(void **data);

int main(int argc, char const *argv[])
{
	if (argc < 2) {
		fprintf(stderr, "Usage: %s <file>\n", argv[0]);
		exit(EXIT_FAILURE);
	}

	int nr_sensors;
	sensor **sensors = read_file(argv[1], &nr_sensors);
	if (!sensors)
		exit(EXIT_FAILURE);

	void **operations = malloc(sizeof(void (*)(void *)) * NR_OPERATIONS);
	if (!operations) {
		fputs("Unable to malloc operations array", stderr);
		free_all_sensors(sensors, nr_sensors);
		free(sensors);
		exit(EXIT_FAILURE);
	}

	get_operations(operations);

	read_commands(&sensors, &nr_sensors, operations);

	free_all_sensors(sensors, nr_sensors);
	free(sensors);
	free(operations);
	return 0;
}
