CC=g++
CFLAGS=-O3 -std=c++11
LDFLAGS=-lfl
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
