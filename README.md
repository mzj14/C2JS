# C2JS
Compiling C into JavaScript

## Project structure

### Lexical analyzer
`tokens.l`

### Syntax analyzer
`parser.y`

### AST definition
`node.hpp`

### Code generator
`codeGen.cpp`

### Testcases
`level_*.c`, accompanied by `level_*.js` as reference.

## Usage

## Prerequisites

    apt-get install flex bison

To run the compiled code, you need `nodejs` with ES6 support, and several `npm` packages:

    npm install -g printf readline-sync

## Usage

    make
    
    ./parser test/level_1.c test/level_1.js
    node test/level_1.js
