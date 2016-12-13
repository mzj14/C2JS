OBJS = tokens.o parser.o graph.o 

LLVMCONFIG = llvm-config
CPPFLAGS = `$(LLVMCONFIG) --cppflags` -std=c++11
LDFLAGS = `$(LLVMCONFIG) --ldflags` -lpthread -ldl -lz -rdynamic
LIBS = `$(LLVMCONFIG) --libs`
CC = g++

all: parser

parser: $(OBJS) 
	$(CC) -o $@ $(OBJS) $(LIBS) $(LDFLAGS)

tokens.c: tokens.l parser.h
	flex -o $@ $^

parser.c: parser.y
	bison -d -o $@ $^

parser.h: parser.c

%.o: %.cpp
	$(CC) -c $(CPPFLAGS) -o $@ $<

test: parser
	./parser test/level_0.c test/graph_0.txt test/level_0.ll

clean:
	rm -rf parser.c parser.h parser tokens.c $(OBJS)


