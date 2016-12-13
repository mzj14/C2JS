OBJS = tokens.o parser.o graph.o 

LLVMCONFIG = llvm-config
CPPFLAGS = `$(LLVMCONFIG) --cppflags` -std=c++11 -fpermissive
LDFLAGS = `$(LLVMCONFIG) --ldflags` -lpthread -ldl -lz -rdynamic
LIBS = `$(LLVMCONFIG) --libs`
CC = g++

all: parser

parser: $(OBJS) 
	$(CC) -o $@ $(OBJS) $(LIBS) $(LDFLAGS)

tokens.cpp: tokens.l parser.hpp
	lex -o $@ $^

parser.cpp: parser.y
	yacc -d -o $@ $^

parser.hpp: parser.cpp

%.o: %.cpp
	$(CC) -c $(CPPFLAGS) -o $@ $<

test: parser
	./parser test/level_0.c test/graph_0.txt test/level_0.ll

clean:
	rm -rf parser.cpp parser.hpp parser tokens.cpp $(OBJS)


