%{
//TODO: remove unnecessary header file
//TODO: Find a way to reduce the shift/reduce conflict, maybe with %nonassoc and %left
//TODO: rename opr function to exp function
//TODO: refactor the yyerror function to avoid compiler warning
//TODO: rename the ex function to make code more semantic
//TODO: modify the command line option to support visualizing AST and generating code
//TODO: the code constructor function are much alike, reduce the redundances

#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string>

#include "node.hpp"
#include "graph.hpp"
#include "codegen.hpp"

using namespace std;

/* prototypes */

// construct a function type node, return the pointer
nodeType *fun(int npts, ...);

// construct a block type node, return the pointer
nodeType *lis(int nlis, ...);

// construct a param list type node, return the pointer
nodeType *prs(int npas, ...);

// construct a param type node, return the pointer
nodeType *par(int npts, ...);

// construct a statement type node, return the pointer
nodeType *sta(int mark, int npts, ...);

// construct a expression type node, return the pointer
nodeType *opr(int oper, int nops, ...);

// construct a identifier type node, return the pointer
nodeType *id(int i);

// construct a type type node, return the pointer
nodeType *conTyp(typeEnum value);

// construct a int type node, return the pointer
nodeType *conInt(int value);

// construct a char type node, return the pointer
nodeType *conChr(char value);

// construct a string type node, return the pointer
nodeType *conStr(int i);

// show content of sym vector, used for debug
void showSym(vector<string>& sym);

// get param num of a param list
int getParamNum(nodeType* params);

// get statement num of a block type
int getStateNum(nodeType* p);

// free the node of AST
void freeNode(nodeType *p);

void yyerror(char* s);

int ex(nodeType *p);

void codeGenFun(funNodeType *p);

// used by yacc itself
int yylex(void);

// #define YYDEBUG 1
%}

/* set yylval as the following union type */
%union {
    typeEnum iType;                  /* type category */
    int iValue;                     /* integer value */
    char iChar;                     /* char value */
    int sIndex;                     /* sym and str table index */
    nodeType *nPtr;                 /* node pointer */
};

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

/* left associativity */
%left EQ_OP NE_OP '>' '<'
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

%type <nPtr> function type_name statement_list statement expr param_list param

%%
program:
        function                                        { /* showSym(sym); */ /* ex($1); */ codeGenFun($1); freeNode($1); exit(0); }
        ;

function:
        type_name IDENTIFIER '(' param_list ')' '{' statement_list '}'         { $$ = fun(4, $1, id($2), $4, $7); }
        | type_name IDENTIFIER '(' ')' '{' statement_list '}'                  { $$ = fun(3, $1, id($2), $6); }
        ;

param_list:
          param                                                                { $$ = prs(1, $1); }
        | param ',' param_list                                                 { $$ = prs(1 + getParamNum($3), $1, $3); }
        ;

param:
        type_name IDENTIFIER                                                   { $$ = par(2, $1, id($2)); }
        | type_name IDENTIFIER '[' ']'                                         { $$ = par(2, $1, id($2)); }
        ;

type_name:
          INT                                           { $$ = conTyp($1); }
        | CHAR                                          { $$ = conTyp($1); }
        ;

statement_list:
          statement                                     { $$ = lis(1, $1); }
        | statement statement_list                      { $$ = lis(1 + getStateNum($2), $1, $2); }
        ;

statement:
          BREAK ';'                                                               { $$ = sta(BREAK, 0); }
        | RETURN expr ';'                                                         { $$ = sta(RETURN, 1, $2); }
        | PRINTF '(' STRING ')' ';'                                               { $$ = sta(PRINTF, 1, conStr($3)); }
        | PRINTF '(' STRING ',' expr ')' ';'                                      { $$ = sta(PRINTF, 2, conStr($3), $5); }
        | GETS '(' IDENTIFIER ')' ';'                                             { $$ = sta(GETS, 1, id($3)); }
        | IDENTIFIER '=' expr ';'                                                 { $$ = sta('=', 2, id($1), $3); }
        | IDENTIFIER '[' expr ']' '=' expr ';'                                    { $$ = sta('=', 3, id($1), $3, $6); }
        | type_name IDENTIFIER '[' INTEGER ']' ';'                                { $$ = sta(DECLARE_ARRAY, 3, $1, id($2), conInt($4)); }
        | type_name IDENTIFIER '=' expr ';'                                       { $$ = sta(DECLARE, 3, $1, id($2), $4); }
        | WHILE '(' expr ')' '{' statement_list '}'                               { $$ = sta(WHILE, 2, $3, $6); }
        | IF '(' expr ')' '{' statement_list '}' %prec IFX                        { $$ = sta(IF, 2, $3, $6); }
        | IF '(' expr ')' '{' statement_list '}' ELSE '{' statement_list '}'      { $$ = sta(ELSE, 3, $3, $6, $10); }  // IF-ELSE is prior to the IF statement
        ;

expr:
          INTEGER                                       { $$ = conInt($1); }
        | CHAR                                          { $$ = conChr($1); }
        | STRING                                        { $$ = conStr($1); }
        | IDENTIFIER                                    { $$ = id($1); }
        | '-' expr %prec UMINUS                         { $$ = opr(UMINUS, 1, $2); }
        | STRLEN '(' IDENTIFIER ')'                     { $$ = opr(STRLEN, 1, id($3)); }
        | IDENTIFIER '[' INTEGER ']'                    { $$ = opr('[', 2, id($1), conInt($3)); }
        | IDENTIFIER '[' IDENTIFIER ']'                 { $$ = opr('[', 2, id($1), id($3)); }
        | expr '+' expr                                 { $$ = opr('+', 2, $1, $3); }
        | expr '-' expr                                 { $$ = opr('-', 2, $1, $3); }
        | expr '*' expr                                 { $$ = opr('*', 2, $1, $3); }
        | expr '/' expr                                 { $$ = opr('/', 2, $1, $3); }
        | expr '<' expr                                 { $$ = opr('<', 2, $1, $3); }
        | expr '>' expr                                 { $$ = opr('>', 2, $1, $3); }
        | expr NE_OP expr                               { $$ = opr(NE_OP, 2, $1, $3); }
        | expr EQ_OP expr                               { $$ = opr(EQ_OP, 2, $1, $3); }
        | expr AND_OP expr                              { $$ = opr(AND_OP, 2, $1, $3); }
        | expr OR_OP expr                               { $$ = opr(OR_OP, 2, $1, $3); }
        | '(' expr ')'                                  { $$ = opr('(', 1, $2); }
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

nodeType *par(int npts, ...) {
    va_list ap;
    parNodeType *p;
    int i;

    p = new parNodeType();

    /* copy information */
    /* set the new node to statement node */
    p->type = typePar;

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

int getParamNum(nodeType* params) {
    return ((prsNodeType*)params)->npas;
}

nodeType *prs(int npas, ...) {
    va_list ap;
    prsNodeType *p;
    int i;

    p = new prsNodeType();

    /* copy information */
    /* set the new node to identifier node */
    p->type = typePrs;

    /* set nsts */
    p->npas = npas;

    /* make ap be the pointer for the argument behind nops */
    va_start(ap, npas);

    p->pa.push_back(va_arg(ap, nodeType*));

    if (npas > 1) {
        prsNodeType* param_list = va_arg(ap, prsNodeType*);
        for (i = 1; i < npas; i++)
            p->pa.push_back(param_list->pa[i - 1]);
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
    switch (p->type) {
        case typeOpr:
            oprNodeType* p_opr = (oprNodeType*)p;
            for (i = 0; i < p_opr->nops; i++)
                freeNode(p_opr->op[i]);
            break;
        case typeSta:
            staNodeType* p_sta = (staNodeType*)p;
            for (i = 0; i < p_sta->npts; i++)
               freeNode(p_sta->pt[i]);
            break;
        case typeLis:
            lisNodeType* p_lis = (lisNodeType*)p;
            for (i = 0; i < p_lis->nsts; i++)
               freeNode(p_lis->st[i]);
            break;
        case typeFun:
            funNodeType* p_fun = (funNodeType*)p;
            for (i = 0; i < p_fun->npts; i++)
               freeNode(p_fun->pt[i]);
            break;
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
    // fclose(out_graph);
    fclose(generated_code);
    return 0;
}
