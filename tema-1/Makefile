CC = gcc
CFLAGS = -Wall -g

TARGET = main
TEST = analyse_1
VFLAGS = -s --track-origins=yes --leak-check=full --show-leak-kinds=all

.PHONY: build run clean pack diff

build: $(TARGET)

run: build
	./$(TARGET)

$(TARGET): $(patsubst %.c,%.o,$(wildcard *.c))
	$(CC) -o $@ $^ 

clean:
	rm -f *.o $(TARGET) $(TARGET).zip vgcore.*

pack:
	zip -FSr $(TARGET).zip *.{c,h} Makefile README.md

.ONESHELL:
diff: build
	OUTPUT='$(shell mktemp)'
	valgrind $(VFLAGS) ./$(TARGET) input/sensors_$(TEST).dat < input/commands_$(TEST).in > $$OUTPUT
	code --diff $$OUTPUT #output/$(TEST).ref
