# C2LLVM
A front end part of a compiler to translate C to LLVM

----

## Project structure

### Lexical Analyzer
The lexical analyzer is located in parser.l

### Syntax Analyzer
The syntax analyzer is located in parser.y

### AST Structure
The AST structure is located in calc3.h

### AST Presentation
The AST presentation is located in graph.c

### Test Case
Two test case are located in level_1.c, level_2.c, accompanied by level_1.ll and level_2.ll as LLVM IR reference.

---

## How to use

### Install Flex and Bison

```
sudo apt-get install flex bison
```

### To visualize AST

```
lex parser.l
yacc -d parser.y
cc lex.yy.c y.tab.c graph.c -o parser
./parser test/level_1.c test/graph_1.txt
```

These commands will generate AST in test/graph_1.txt for test/level_1.c

### To generate LLVM IR

We need to implement the `ex` function in parser.y !!!