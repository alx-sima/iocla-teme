#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "io.h"
#include "structs.h"
#include "utils.h"

/*
 * Aloca spatiu si citeste un sensor din fisierul `in`.
 */
static sensor *read_sensor(FILE *in);

/*
 * Citeste o linie de la tastatura si o salveaza in bufferul `*str`, de lungime
 * `size` (pe care il redimensioneaza daca depaseste lungimea).
 */
static size_t read_line(char **str, size_t *size);

/*
 * Afiseaza informatii despre tire_sensor.
 */
static void print_tire_sensor(tire_sensor *sensor);

/*
 * Afiseaza informatii despre power_management_unit.
 */
static void print_pmu_sensor(power_management_unit *sensor);

sensor **read_file(char const *filename, int *nr_sensors)
{
	FILE *in = fopen(filename, "rb");
	if (!in) {
		fprintf(stderr, "Unable to open file %s\n", filename);
		return NULL;
	}

	fread(nr_sensors, sizeof(int), 1, in);
	sensor **sensors = malloc(sizeof(sensor *) * *nr_sensors);
	if (!sensors) {
		fputs("Unable to malloc sensor array", stderr);
		fclose(in);
		return NULL;
	}

	int nr_pmus = 0;
	int nr_tires = 0;
	for (int i = 0; i < *nr_sensors; ++i) {
		sensor *s = read_sensor(in);
		if (!s) {
			fprintf(stderr, "Unable to read sensor %d\n", i);
			free_all_sensors(sensors, nr_pmus);
			free_all_sensors(sensors + nr_pmus, nr_tires);
			free(sensors);
			fclose(in);
			return NULL;
		}

		if (s->sensor_type == PMU)
			sensors[nr_pmus++] = s;
		else
			sensors[*nr_sensors - 1 - nr_tires++] = s;
	}

	mirror_vector(sensors + nr_pmus, nr_tires);

	fclose(in);
	return sensors;
}

void read_commands(sensor ***sensors, int *nr_sensors, void **operations)
{
	char *line = NULL;
	size_t line_len = 0;
	while (read_line(&line, &line_len)) {
		// Primul cuvant din linie reprezinta comanda.
		char *cmd = strtok(line, "\n ");

		if (!strcmp(cmd, "print")) {
			char *arg = strtok(NULL, "\n");
			int index = strtol(arg, &arg, 0);

			if (index < 0 || index >= *nr_sensors) {
				puts("Index not in range!");
				continue;
			}

			if ((*sensors)[index]->sensor_type == TIRE)
				print_tire_sensor((*sensors)[index]->sensor_data);
			else
				print_pmu_sensor((*sensors)[index]->sensor_data);

		} else if (!strcmp(cmd, "analyze")) {
			char *arg = strtok(NULL, "\n");
			int index = strtol(arg, &arg, 0);
			sensor *s = (*sensors)[index];

			for (int i = 0; i < s->nr_operations; ++i) {
				void (*operation)(void *) = operations[s->operations_idxs[i]];
				operation(s->sensor_data);
			}

		} else if (!strcmp(cmd, "clear")) {
			int nr_valid_sensors = 0;
			for (int i = 0; i < *nr_sensors; ++i) {
				if (valid_sensor((*sensors)[i]))
					(*sensors)[nr_valid_sensors++] = (*sensors)[i];
				else
					free_sensor((*sensors)[i]);
			}
			*nr_sensors = nr_valid_sensors;
			sensor **tmp = realloc(*sensors, sizeof(sensor *) * *nr_sensors);
			if (!tmp) {
				free_all_sensors((*sensors), *nr_sensors);
				free(sensors);
				free(line);
				fputs("Unable to realloc sensor array", stderr);
				exit(EXIT_FAILURE);
			}
			*sensors = tmp;
		} else if (!strcmp(cmd, "exit")) {
			break;
		}
	}
	free(line);
}

static sensor *read_sensor(FILE *in)
{
	sensor *s = malloc(sizeof(sensor));
	if (!s)
		return NULL;

	fread(&s->sensor_type, sizeof(enum sensor_type), 1, in);
	size_t data_size = (s->sensor_type == TIRE ? sizeof(tire_sensor)
											   : sizeof(power_management_unit));
	s->sensor_data = malloc(data_size);
	if (!s->sensor_data) {
		free(s);
		return NULL;
	}
	fread(s->sensor_data, data_size, 1, in);

	fread(&s->nr_operations, sizeof(int), 1, in);
	s->operations_idxs = malloc(sizeof(int) * s->nr_operations);
	if (!s->operations_idxs) {
		free(s->sensor_data);
		free(s);
		return NULL;
	}
	fread(s->operations_idxs, sizeof(int), s->nr_operations, in);

	return s;
}

static size_t read_line(char **str, size_t *size)
{
	char buffer[BUFSIZ];

	size_t line_len = 0;
	while (fgets(buffer, BUFSIZ, stdin)) {
		size_t buffer_siz = strlen(buffer) + 1;

		// Nu este suficient spatiu in buffer,
		// asa ca se realoca.
		if (line_len + buffer_siz > *size) {
			char *tmp = realloc(*str, sizeof(char) * (line_len + buffer_siz));
			if (!tmp)
				return 0;
			*size = line_len + buffer_siz;
			*str = tmp;
		}

		strncpy(*str + line_len, buffer, buffer_siz);
		line_len += buffer_siz - 1;
		// S-a citit o linie completa, asa ca se iese din functie.
		if ((*str)[line_len - 1] == '\n')
			return line_len;
	}
	return 0;
}

static void print_tire_sensor(tire_sensor *sensor)
{
	puts("Tire Sensor");
	printf("Pressure: %.2f\n", sensor->pressure);
	printf("Temperature: %.2f\n", sensor->temperature);
	printf("Wear Level: %d%%\n", sensor->wear_level);
	if (sensor->performace_score)
		printf("Performance Score: %d\n", sensor->performace_score);
	else
		puts("Performance Score: Not Calculated");
}

static void print_pmu_sensor(power_management_unit *sensor)
{
	puts("Power Management Unit");
	printf("Voltage: %.2f\n", sensor->voltage);
	printf("Current: %.2f\n", sensor->current);
	printf("Power Consumption: %.2f\n", sensor->power_consumption);
	printf("Energy Regen: %d%%\n", sensor->energy_regen);
	printf("Energy Storage: %d%%\n", sensor->energy_storage);
}
