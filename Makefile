CC=g++-9
CFLAGS=-I -O3 -std=c++11

all: parser

parser.tab.c: parser.y
	bison -d parser.y

lex.yy.c: tokens.l
	flex tokens.l

parser: tokens.l parser.y parser.tab.c lex.yy.c main.cpp
	$(CC) $(CFLAGS) main.cpp parser.tab.c lex.yy.c -ll -o parser

clean:
	rm *yy.c *tab.c *tab.h *.o
