#pragma once

#include <fstream>
#include <iostream>
#include <vector>
#include <string>

using namespace std;

/* node types */
typedef enum { typeTyp, typeInt, typeDbl, typeChr, typeStr, typeId, typeOpr, typeEps,
                typeSta, typeLis, typeFun, typePar, typePrs, typePro } nodeEnum;

/* data types */
typedef enum { charType, intType, doubleType } typeEnum;

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

/* doubles */
class dblNodeType : public nodeType
{
public:
    double value;                      /* value of double */
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

/* program */
class proNodeType : public nodeType {
public:
    int nfns;                       /* number of functions */
    vector<nodeType*> fn;           /* functions, extended at runtime */
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
    int npas;                       /* number of params */
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