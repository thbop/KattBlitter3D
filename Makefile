CC = gcc
ASM = nasm
CFLAGS = -c -g -nostdlib -m64 -fdiagnostics-color=always -Iinclude
ASMFLAGS = -f win64
LDFLAGS = -Llib -lSDL2

NAME = a
SRC = $(NAME).c
TARGET = $(NAME).exe

all: clean rasterizer.o $(TARGET) clean2

rasterizer.o : include/Rasterizer.asm
	$(ASM) $(ASMFLAGS) include/Rasterizer.asm -o rasterizer.o

$(TARGET) : $(SRC)
	$(CC) $(CFLAGS) $(SRC) -o $(NAME).o
	$(CC) rasterizer.o $(NAME).o -o $(TARGET) $(LDFLAGS)

clean2:
	rm -f $(NAME).o
	rm -f rasterizer.o

clean:
	rm -f $(TARGET)