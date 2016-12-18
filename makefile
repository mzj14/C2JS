OBJS = tokens.o parser.o codeGen.o
CC = g++
FLAGS = -w
all: parser

parser: $(OBJS) 
	$(CC) -o $@ $(OBJS) $(FLAGS)

tokens.cpp: tokens.l parser.hpp
	lex -o $@ $^

parser.cpp: parser.y
	yacc -d -o $@ $^ 

parser.hpp: parser.cpp

%.o: %.cpp
	$(CC) -c -o $@ $< $(FLAGS)

clean:
	rm -rf parser.cpp parser.hpp parser tokens.cpp $(OBJS)


