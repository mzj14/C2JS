%{
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string>
using namespace std;

#include "node.hpp"
#include "graph.hpp"
#include "codegen.hpp"

/* prototypes */
nodeType *lis(int nlis, ...);
nodeType *fun(int npts, ...);
nodeType *sta(int mark, int npts, ...);
nodeType *opr(int oper, int nops, ...);
nodeType *id(int i);
nodeType *conTyp(typeEnum value);
nodeType *conInt(int value);
nodeType *conChr(char value);
nodeType *conStr(int i);

void showSym(vector<string> sym);
int getStateNum(nodeType* p);
void freeNode(nodeType *p);
void yyerror(char* s);
int ex(nodeType *p);
string codeGenFun(funNodeType *p);
int yylex(void);

// FILE *generated_code;

// #define YYDEBUG 1
%}

/* set yylval as the following union type */
%union {
    typeEnum iType;                  /* type category */
    int iValue;                 /* integer value */
    char iChar;                  /* char value */
    int sIndex;                /* symbol table index */
    nodeType *nPtr;             /* node pointer */
};

// need to generate right code
%token <iValue> INTEGER
%token <iType> INT CHAR
%token <iChar> CHARACTER
%token <sIndex> STRING
%token <sIndex> IDENTIFIER
%token AND_OP OR_OP
%token DECLARE DECLARE_ARRAY
%token WHILE IF PRINTF BREAK RETURN GETS STRLEN

/* no associativity */
%nonassoc IFX
%nonassoc ELSE

%left EQ_OP NE_OP '>' '<'
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

%type <nPtr> function type_name statement_list statement expr

%%
program:
        function                { /* showSym(sym); */ /* ex($1); */ cout << codeGenFun($1) << endl; freeNode($1); exit(0); }
        ;

function:
        type_name IDENTIFIER '(' ')' statement         { $$ = fun(3, $1, id($2), $5); }  // function
        ;

type_name:
          INT              { $$ = conTyp($1); }
        | CHAR             { $$ = conTyp($1); }
        ;

statement_list:
          statement                       { $$ = lis(1, $1); }
        | statement statement_list        { $$ = lis(1 + getStateNum($2), $1, $2); }
        ;

statement:
          BREAK ';'                                     { $$ = sta(BREAK, 0); }
        | RETURN expr ';'                               { $$ = sta(RETURN, 1, $2); }
        | PRINTF '(' STRING ')' ';'                     { $$ = sta(PRINTF, 1, conStr($3)); }
        | PRINTF '(' STRING ',' expr ')' ';'            { $$ = sta(PRINTF, 2, conStr($3), $5); }
        | GETS '(' IDENTIFIER ')' ';'                   { $$ = sta(GETS, 1, id($3)); }
        | IDENTIFIER '=' expr ';'                       { $$ = sta('=', 2, id($1), $3); }
        | IDENTIFIER '[' expr ']' '=' expr ';'          { $$ = sta('=', 3, id($1), $3, $6); }
        | type_name IDENTIFIER '[' INTEGER ']' ';'      { $$ = sta(DECLARE_ARRAY, 3, $1, id($2), conInt($4)); }
        | type_name IDENTIFIER '=' expr ';'             { $$ = sta(DECLARE, 3, $1, id($2), $4); }
        | WHILE '(' expr ')' statement                  { $$ = sta(WHILE, 2, $3, $5); }
        | IF '(' expr ')' statement %prec IFX           { $$ = sta(IF, 2, $3, $5); }
        | IF '(' expr ')' statement ELSE statement      { $$ = sta(ELSE, 3, $3, $5, $7); }  // IF-ELSE is prior to the IF statement
        | '{' statement_list '}'                        { $$ = $2; }
        ;

expr:
          INTEGER                     { $$ = conInt($1); }
        | CHAR                        { $$ = conChr($1); }
        | STRING                      { $$ = conStr($1); }
        | IDENTIFIER                  { $$ = id($1); }
        | '-' expr %prec UMINUS       { $$ = opr(UMINUS, 1, $2); }
        | STRLEN '(' IDENTIFIER ')'     { $$ = opr(STRLEN, 1, id($3)); }
        | IDENTIFIER '[' INTEGER ']'    { $$ = opr('[', 2, id($1), conInt($3)); }
        | IDENTIFIER '[' IDENTIFIER ']' { $$ = opr('[', 2, id($1), id($3)); }
        | expr '+' expr               { $$ = opr('+', 2, $1, $3); }
        | expr '-' expr               { $$ = opr('-', 2, $1, $3); }
        | expr '*' expr               { $$ = opr('*', 2, $1, $3); }
        | expr '/' expr               { $$ = opr('/', 2, $1, $3); }
        | expr '<' expr               { $$ = opr('<', 2, $1, $3); }
        | expr '>' expr               { $$ = opr('>', 2, $1, $3); }
        | expr NE_OP expr                { $$ = opr(NE_OP, 2, $1, $3); }
        | expr EQ_OP expr                { $$ = opr(EQ_OP, 2, $1, $3); }
        | expr AND_OP expr                { $$ = opr(AND_OP, 2, $1, $3); }
        | expr OR_OP expr                { $$ = opr(OR_OP, 2, $1, $3); }
        | '(' expr ')'                { $$ = $2; }
        ;
%%

nodeType *conTyp(typeEnum value) {
    typNodeType *p;

    p = new typNodeType();

    /* copy information */
    /* set the new node to constant node */
    p->type = typeTyp;

    /* set constant node value */
    p->value = value;

    return p;
}

nodeType *conInt(int value) {
    intNodeType *p;

    p = new intNodeType();

    /* copy information */
    /* set the new node to constant node */
    p->type = typeInt;

    /* set constant node value */
    p->value = value;

    return p;
}

nodeType *conChr(char value) {
    chrNodeType *p;

    p = new chrNodeType();

    /* copy information */
    /* set the new node to constant node */
    p->type = typeChr;
    /* set constant node value */
    p->value = value;

    return p;
}

nodeType *conStr(int i) {
    strNodeType *p;

    p = new strNodeType();

    /* copy information */
    /* set the new node to constant node */
    p->type = typeStr;

    /* set constant node value */
    p->i = i;

    return p;
}

nodeType *id(int i) {
    idNodeType *p;

    p = new idNodeType();

    /* copy information */
    /* set the new node to identifier node */
    p->type = typeId;
    /* set the identifier index in sym */
    p->i = i;

    return p;
}

nodeType *opr(int oper, int nops, ...) {
    va_list ap;
    oprNodeType *p;
    int i;

    p = new oprNodeType();

    /* copy information */
    /* set the new node to identifier node */
    p->type = typeOpr;

    /* set oper */
    p->oper = oper;

    /* set nops */
    p->nops = nops;

    /* make ap be the pointer for the argument behind nops */
    va_start(ap, nops);

    /* add operand pointer(s) */
    for (i = 0; i < nops; i++)
        p->op.push_back(va_arg(ap, nodeType*));

    /* make ap to null */
    va_end(ap);
    return p;
}

nodeType *sta(int mark, int npts, ...) {
    va_list ap;
    staNodeType *p;
    int i;

    p = new staNodeType();

    /* copy information */
    /* set the new node to statement node */
    p->type = typeSta;

    /* set mark */
    p->mark = mark;

    /* set npts */
    p->npts = npts;
    /* make ap be the pointer for the argument behind nops */
    va_start(ap, npts);

    /* add operand pointer(s) */
    for (i = 0; i < npts; i++)
        p->pt.push_back(va_arg(ap, nodeType*));

    /* make ap to null */
    va_end(ap);
    return p;
}

int getStateNum(nodeType* list) {
    return ((lisNodeType*)list)->nsts;
}

nodeType *lis(int nsts, ...) {
    va_list ap;
    lisNodeType *p;
    int i;

    p = new lisNodeType();

    /* copy information */
    /* set the new node to identifier node */
    p->type = typeLis;

    /* set nsts */
    p->nsts = nsts;

    /* make ap be the pointer for the argument behind nops */
    va_start(ap, nsts);

    p->st.push_back(va_arg(ap, nodeType*));

    if (nsts > 1) {
        lisNodeType* statement_list = va_arg(ap, lisNodeType*);
        for (i = 1; i < nsts; i++)
            p->st.push_back(statement_list->st[i - 1]);
    }

    va_end(ap);
    return p;
}

nodeType *fun(int npts, ...) {
    va_list ap;
    funNodeType *p;
    int i;

    p = new funNodeType();

    /* copy information */
    /* set the new node to identifier node */
    p->type = typeFun;

    /* set npts */
    p->npts = npts;

    /* make ap be the pointer for the argument behind nops */
    va_start(ap, npts);

    /* add operand pointer(s) */
    for (i = 0; i < npts; i++)
        p->pt.push_back(va_arg(ap, nodeType*));

    va_end(ap);
    return p;
}

void freeNode(nodeType *p) {
    int i;

    if (!p) return;
    if (p->type == typeOpr) {
        oprNodeType* pt = (oprNodeType*)p;
        for (i = 0; i < pt->nops; i++)
            freeNode(pt->op[i]);
    }
    if (p->type == typeSta) {
        staNodeType* pt = (staNodeType*)p;
        for (i = 0; i < pt->npts; i++)
            freeNode(pt->pt[i]);
    }
    if (p->type == typeLis) {
        lisNodeType* pt = (lisNodeType*)p;
        for (i = 0; i < pt->nsts; i++)
            freeNode(pt->st[i]);
    }

    if (p->type == typeFun) {
        funNodeType* pt = (funNodeType*)p;
        for (i = 0; i < pt->npts; i++)
            freeNode(pt->pt[i]);
    }

    delete p;
}

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

void showSym(vector<string> sym) {
    cout << sym.size() << endl;
    for (int i = 0; i < sym.size(); i++) {
       cout << sym[i] << endl;
    }
    return;
}

int main(int argc, char *argv[]) {
    // #if YYDEBUG
       // yydebug = 1;
    // #endif
    yyin = fopen(argv[1], "r");
    // out_graph = fopen(argv[2], "w");
    generated_code = fopen(argv[2], "w");
    yyparse();
    fclose(yyin);
    fclose(out_graph);
    return 0;
}
