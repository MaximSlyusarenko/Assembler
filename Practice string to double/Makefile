OBJS=test.o str2double.o

OS:=$(shell uname)

ifeq ($(OS), Darwin)
YASM_FLAGS=-f macho64
OBJS+=osx-wrapper.o
else
YASM_FLAGS=-f elf64 -g dwarf2
endif

all: test
test: $(OBJS)
	g++ $(CXXFLAGS) -o $@ $^

%.o: %.asm
	yasm $(YASM_FLAGS) -o $@ $<

clean:
	rm -f test
	rm -f test.o
	rm -f str2double.o	
