CC = gcc
CFLAGS = -fdiagnostics-color=always -Iinclude
LDFLAGS = -Llib -lSDL2

SRC = a.c
TARGET = a.exe

all: clean $(TARGET)

$(TARGET) : $(SRC)
	$(CC) $(CFLAGS) $(SRC) $(LDFLAGS) -o $(TARGET)


clean:
	rm -f $(TARGET)