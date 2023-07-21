include ../Makefile.common

CHECKFILE = check-timegate
ASMFILE = bonus_timegate
DEPS = $(CHECKFILE).o $(ASMFILE).o

TARGET=iocla_rezolvari_examen_gratis_no_clickbait

all: checker $(TARGET)

build: checker $(TARGET)

$(CHECKFILE).o: $(CHECKFILE).c

$(ASMFILE).o: $(ASMFILE).asm

checker: $(DEPS)
	$(CC) $(LDFLAGS) $^ -o $@

$(TARGET): $(TARGET).o $(ASMFILE).o
	$(CC) $(LDFLAGS) $^ -o $@
	strip $@


clean:
	rm *.o checker
