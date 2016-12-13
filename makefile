OBJS = tokens.o parser.o graph.o 

LLVMCONFIG = llvm-config
CPPFLAGS = `$(LLVMCONFIG) --cppflags` -std=c11
LDFLAGS = `$(LLVMCONFIG) --ldflags` -lpthread -ldl -lz -rdynamic
LIBS = `$(LLVMCONFIG) --libs`

all: parser

parser: $(OBJS) 
	cc -o $@ $(OBJS) $(LIBS) $(LDFLAGS)

tokens.c: tokens.l parser.h
	flex -o $@ $^

parser.c: parser.y
	bison -d -o $@ $^

parser.h: parser.c

%.o: %.cpp
	g++ -c $(CPPFLAGS) -o $@ $<

clean:
	rm -rf parser.c parser.h parser tokens.c $(OBJS)


