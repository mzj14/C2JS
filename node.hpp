#pragma once

#include <fstream>
#include <iostream>
#include <vector>
#include <string>

using namespace std;

//TODO: remove unnecessary header file
//TODO: add constructor function for node classes
//TODO: rename the opr(operation) to exp(expression) to make code more semantic
//TODO: remove i to index to make code more semantic
//TODO: rename lis(lists) to blk(block) to make code more semantic

/* node types */
typedef enum { typeTyp, typeInt, typeChr, typeStr, typeId, typeOpr, typeEps, typeSta, typeLis, typeFun, typePar, typePrs } nodeEnum;

/* variable types */
typedef enum { charType, intType } typeEnum;

/* super class for all nodes */
class nodeType
{
public:
    nodeEnum type;
};

/* types */
class typNodeType : public nodeType
{
public:
    typeEnum value;                  /* type category */
};

/* integers */
class intNodeType : public nodeType
{
public:
    int value;                      /* value of integer */
};

/* chars */
class chrNodeType : public nodeType
{
public:
    int i;                           /* index to global chr vector */
};

/* strings */
class strNodeType : public nodeType
{
public:
    int i;                          /* index to global str vector */
};

/* identifiers */
class idNodeType : public nodeType
{
public:
    int i;                          /* index to global sym vector */
};

/* expressions */
class oprNodeType : public nodeType
{
public:
    int oper;                       /* operator */
    int nops;                       /* number of operands */
    vector<nodeType*> op;           /* operands, extended at runtime */
};

/* expression list */
class epsNodeType : public nodeType
{
public:
    int neps;                       /* number of expressions */
    vector<nodeType*> ep;           /* expressions, extended at runtime */
};

/* statements */
class staNodeType : public nodeType
{
public:
    int mark;                       /* show the statement type */
    int npts;                       /* number of parts */
    vector<nodeType*> pt;           /* parts, extended at runtime */
};

/* statement lists */
class lisNodeType : public nodeType {
public:
    int nsts;                       /* number of statements */
    vector<nodeType*> st;           /* statements, extended at runtime */
};

/* functions */
class funNodeType : public nodeType {
public:
    int npts;                       /* number of parts, usually be 4 */
    vector<nodeType*> pt;           /* parts, extended at runtime */
};

/* params */
class parNodeType : public nodeType {
public:
    int npts;                       /* number of parts, usually be 2 */
    vector<nodeType*> pt;           /* parts, extended at runtime */
};

/* params list */
class prsNodeType : public nodeType {
public:
    int npas;                       /* number of params 2 */
    vector<nodeType*> pa;           /* params, extended at runtime */
};

// vector for identifier
extern vector<string> sym;

// vector for string
extern vector<string> str;

// vector for char
extern vector<string> chr;

// output file for AST visualization
extern FILE *out_graph;

// output file for generated JS code
extern FILE *generated_code;

// input file of origin C code
extern FILE *yyin;