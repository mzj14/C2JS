OBJS = tokens.o parser.o graph.o codeGen.o
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

test: parser
	./parser test/level_0.c test/graph_0.txt

clean:
	rm -rf parser.cpp parser.hpp parser tokens.cpp $(OBJS)


