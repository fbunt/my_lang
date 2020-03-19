CC:=$(shell ./get_compiler.sh)
CFLAGS=-O3 -std=c++11
FLEXLIB:=$(shell ./get_flex_lib.sh)
LDFLAGS=-l$(FLEXLIB)
OBJS=parser.o tokens.o

all: parser

parser.cpp: parser.y
	bison -d -o $@ $^

tokens.cpp: tokens.l
	flex -o $@ $^

%.o: %.cpp
	$(CC) -c $(CFLAGS) -o $@ $<

parser: $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) $(LDFLAGS) -o $@

clean:
	rm -rf parser.cpp parser.hpp parser tokens.cpp *.o
