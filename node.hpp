#pragma once
#include <fstream>
#include <iostream>
#include <vector>
#include <string>
using namespace std;


/* node types */
typedef enum { typeTyp, typeInt, typeChr, typeStr, typeId, typeOpr, typeSta, typeLis, typeFun } nodeEnum;

/* data types */
typedef enum { charType, intType } typeEnum;

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
    int value;                  /* value of integer */
};

/* chars */
class chrNodeType : public nodeType
{
public:
    char value;                  /* value of char */
};

/* strings */
class strNodeType : public nodeType
{
public:
    int i;                  /* index to str array */
};

/* identifiers */
class idNodeType : public nodeType
{
public:
    int i;                      /* index to sym array */
};

/* operators */
class oprNodeType : public nodeType
{
public:
    int oper;                   /* operator */
    int nops;                   /* number of operands */
    vector<nodeType*> op;    /* operands, extended at runtime */
};

/* statements */
class staNodeType : public nodeType
{
public:
    int mark;                   /* show the statement type */
    int npts;                   /* number of parts */
    vector<nodeType*> pt;    /* parts, extended at runtime */
};

/* lists */
class lisNodeType : public nodeType {
public:
    int nsts;
    vector<nodeType*> st;    /* statements, extended at runtime */
};

/* functions */
class funNodeType : public nodeType {
public:
    int npts;                    /* number of parts */
    vector<nodeType*> pt;    /* parts, extended at runtime */
};

// vector for identifier
extern vector<string> sym;

// vector for string
extern vector<string> str;

extern FILE *out_graph;
extern FILE *generated_code;
extern FILE *yyin;