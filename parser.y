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
#include "codegen.hpp"

using namespace std;

/******************************* node construction function ********************************************/
// construct a program type node, return the pointer
nodeType *pro(int nfns, ...);

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

// construct a expression list node, return the pointer
nodeType *eps(int neps, ...);

// construct a identifier type node, return the pointer
nodeType *id(int i);

// construct a type type node, return the pointer
nodeType *conTyp(typeEnum value);

// construct a int type node, return the pointer
nodeType *conInt(int value);

// construct a int type node, return the pointer
nodeType *conDbl(double value);

// construct a char type node, return the pointer
nodeType *conChr(int i);

// construct a string type node, return the pointer
nodeType *conStr(int i);
/********************************************************************************************************/

/******************************** get node children num function ****************************************/
// get param num of a param list
int getParamNum(nodeType* params);

// get statement num of a block type
int getStateNum(nodeType* p);

// get expression num of a expression list
int getExpNum(nodeType* p);

// get function num of a program
int getFuncNum(nodeType* p);
/*********************************************************************************************************/

// free the node of AST
void freeNode(nodeType *p);

void yyerror(char* s);

// used by yacc itself
int yylex(void);

// #define YYDEBUG 1
%}

/* set yylval as the following union type */
%union {
    typeEnum iType;                  /* type category */
    int iValue;                      /* integer value */
    int sIndex;                      /* sym, str, chr vector index */
    double dValue;                   /* double value */
    nodeType *nPtr;                  /* node pointer */
};

%token <iValue> INTEGER
%token <iType> INT CHAR DOUBLE
%token <dValue> DOUBLE_NUM
%token <sIndex> CHARACTER
%token <sIndex> STRING COMMENT
%token <sIndex> IDENTIFIER

%token INC_OP DEC_OP INC_OP_LEFT INC_OP_RIGHT DEC_OP_LEFT DEC_OP_RIGHT LE_OP GE_OP NOT_OP
%token AND_OP OR_OP
%token DECLARE DECLARE_ARRAY
%token WHILE IF PRINTF BREAK RETURN GETS STRLEN CONTINUE FOR ISDIGIT STRCMP

/* no associativity */
%nonassoc IFX
%nonassoc ELSE

/* left associativity */
%left EQ_OP NE_OP '>' '<'
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

%type <nPtr> function function_list type_name statement statement_list expr expr_list param param_list
%expect 180
%%
program:
        function_list                                                          { codeGenPro($1); freeNode($1); exit(0); }
        ;

function_list:
          function                                                             { $$ = pro(1, $1); }
        | function function_list                                               { $$ = pro(1 + getFuncNum($2), $1, $2); }
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
          INT                                                                  { $$ = conTyp($1); }
        | CHAR                                                                 { $$ = conTyp($1); }
        | DOUBLE                                                               { $$ = conTyp($1); }
        ;

statement_list:
          statement                                                            { $$ = lis(1, $1); }
        | statement statement_list                                             { $$ = lis(1 + getStateNum($2), $1, $2); }
        ;

statement:
          BREAK ';'                                                            { $$ = sta(BREAK, 0); }
        | CONTINUE ';'                                                         { $$ = sta(CONTINUE, 0); }
        | RETURN expr ';'                                                      { $$ = sta(RETURN, 1, $2); }
        | PRINTF '(' expr_list ')' ';'                                         { $$ = sta(PRINTF, 1, $3); }
        | IDENTIFIER '(' expr_list ')' ';'                                     { $$ = sta(IDENTIFIER, 2, id($1), $3); }
        | GETS '(' IDENTIFIER ')' ';'                                          { $$ = sta(GETS, 1, id($3)); }
        | IDENTIFIER '=' expr ';'                                              { $$ = sta('=', 2, id($1), $3); }
        | IDENTIFIER '[' expr ']' '=' expr ';'                                 { $$ = sta('=', 3, id($1), $3, $6); }
        | type_name IDENTIFIER '[' INTEGER ']' ';'                             { $$ = sta(DECLARE_ARRAY, 3, $1, id($2), conInt($4)); }
        | type_name IDENTIFIER '=' expr ';'                                    { $$ = sta(DECLARE, 3, $1, id($2), $4); }
        | type_name IDENTIFIER ';'                                             { $$ = sta(DECLARE, 2, $1, id($2)); }
        | WHILE '(' expr ')' '{' statement_list '}'                            { $$ = sta(WHILE, 2, $3, $6); }
        | IF '(' expr ')' '{' statement_list '}' %prec IFX                     { $$ = sta(IF, 2, $3, $6); }
        | IF '(' expr ')' '{' statement_list '}' ELSE '{' statement_list '}'   { $$ = sta(ELSE, 3, $3, $6, $10); }  // IF-ELSE is prior to the IF statement
        | FOR '(' statement expr ';' expr ')' '{' statement_list '}'           { $$ = sta(FOR, 4, $3, $4, $6, $9); }
        | INC_OP expr ';'                                                      { $$ = sta(INC_OP_LEFT, 1, $2);  }
        | DEC_OP expr ';'                                                      { $$ = sta(DEC_OP_LEFT, 1, $2);  }
        | expr INC_OP ';'                                                      { $$ = sta(INC_OP_RIGHT, 1, $1);  }
        | expr DEC_OP ';'                                                      { $$ = sta(DEC_OP_RIGHT, 1, $1);  }
        | COMMENT                                                              { $$ = sta(COMMENT, 1, conStr($1)); }
        ;

expr_list:
          expr                                                                 { $$ = eps(1, $1); }
        | expr ',' expr_list                                                   { $$ = eps(1 + getExpNum($3), $1, $3); }
        ;

expr:
          INTEGER                                                              { $$ = conInt($1); }
        | DOUBLE_NUM                                                           { $$ = conDbl($1); }
        | CHARACTER                                                            { $$ = conChr($1); }
        | STRING                                                               { $$ = conStr($1); }
        | IDENTIFIER                                                           { $$ = id($1); }
        | '-' expr %prec UMINUS                                                { $$ = opr(UMINUS, 1, $2); }
        | STRLEN '(' IDENTIFIER ')'                                            { $$ = opr(STRLEN, 1, id($3)); }
        | STRCMP '(' expr ',' expr ')'                                         { $$ = opr(STRCMP, 2, $3, $5); }
        | ISDIGIT '(' expr ')'                                                 { $$ = opr(ISDIGIT, 1, $3); }
        | IDENTIFIER '(' expr_list ')'                                         { $$ = opr(IDENTIFIER, 2, id($1), $3); }
        | IDENTIFIER '[' expr ']'                                              { $$ = opr('[', 2, id($1), $3); }
        | expr '+' expr                                                        { $$ = opr('+', 2, $1, $3); }
        | expr '-' expr                                                        { $$ = opr('-', 2, $1, $3); }
        | expr '*' expr                                                        { $$ = opr('*', 2, $1, $3); }
        | expr '/' expr                                                        { $$ = opr('/', 2, $1, $3); }
        | expr '<' expr                                                        { $$ = opr('<', 2, $1, $3); }
        | expr '>' expr                                                        { $$ = opr('>', 2, $1, $3); }
        | INC_OP expr                                                          { $$ = opr(INC_OP_LEFT, 1, $2);  }
        | DEC_OP expr                                                          { $$ = opr(DEC_OP_LEFT, 1, $2);  }
        | expr INC_OP                                                          { $$ = opr(INC_OP_RIGHT, 1, $1);  }
        | expr DEC_OP                                                          { $$ = opr(DEC_OP_RIGHT, 1, $1);  }
        | expr NE_OP expr                                                      { $$ = opr(NE_OP, 2, $1, $3); }
        | expr EQ_OP expr                                                      { $$ = opr(EQ_OP, 2, $1, $3); }
        | expr OR_OP expr                                                      { $$ = opr(OR_OP, 2, $1, $3); }
        | expr AND_OP expr                                                     { $$ = opr(AND_OP, 2, $1, $3); }
        | '!' expr                                                             { $$ = opr('!', 1, $2); }
        | expr LE_OP expr                                                      { $$ = opr(LE_OP, 2, $1, $3); }
        | expr GE_OP expr                                                      { $$ = opr(GE_OP, 2, $1, $3); }
        | '(' expr ')'                                                         { $$ = opr('(', 1, $2); }
        ;
%%

nodeType *conTyp(typeEnum value) {
    typNodeType *p;

    p = new typNodeType();

    /* copy information */
    /* set the new node to type node */
    p->type = typeTyp;

    /* set type node value */
    p->value = value;

    return p;
}

nodeType *conInt(int value) {
    intNodeType *p;

    p = new intNodeType();

    /* copy information */
    /* set the new node to integer node */
    p->type = typeInt;

    /* set integer node value */
    p->value = value;

    return p;
}

nodeType *conDbl(double value) {
    dblNodeType *p;

    p = new dblNodeType();

    /* copy information */
    /* set the new node to double node */
    p->type = typeDbl;

    /* set double node value */
    p->value = value;

    return p;
}

nodeType *conChr(int i) {
    chrNodeType *p;

    p = new chrNodeType();

    /* copy information */
    /* set the new node to character node */
    p->type = typeChr;

    /* set character node index in chr vector */
    p->i = i;

    return p;
}

nodeType *conStr(int i) {
    strNodeType *p;

    p = new strNodeType();

    /* copy information */
    /* set the new node to string node */
    p->type = typeStr;

    /* set string node index in str vector */
    p->i = i;

    return p;
}

nodeType *id(int i) {
    idNodeType *p;

    p = new idNodeType();

    /* copy information */
    /* set the new node to identifier node */
    p->type = typeId;
    /* set identifier index in sym vector */
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

int getExpNum(nodeType* exps) {
    return ((epsNodeType*)exps)->neps;
}

nodeType *eps(int neps, ...) {
    va_list ap;
    epsNodeType *p;
    int i;

    p = new epsNodeType();

    /* copy information */
    /* set the new node to identifier node */
    p->type = typeEps;

    /* set neps */
    p->neps = neps;

    /* make ap be the pointer for the argument behind nops */
    va_start(ap, neps);

    p->ep.push_back(va_arg(ap, nodeType*));

    if (neps > 1) {
        epsNodeType* expression_list = va_arg(ap, epsNodeType*);
        for (i = 1; i < neps; i++)
            p->ep.push_back(expression_list->ep[i - 1]);
        delete expression_list;
    }

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
        delete statement_list;
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
        delete param_list;
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

int getFuncNum(nodeType* prog) {
    return ((proNodeType*)prog)->nfns;
}

nodeType *pro(int nfns, ...) {
    va_list ap;
    proNodeType *p;
    int i;

    p = new proNodeType();

    /* copy information */
    /* set the new node to identifier node */
    p->type = typePro;

    /* set nsts */
    p->nfns = nfns;

    /* make ap be the pointer for the argument behind nops */
    va_start(ap, nfns);

    p->fn.push_back(va_arg(ap, nodeType*));

    if (nfns > 1) {
        proNodeType* func_list = va_arg(ap, proNodeType*);
        for (i = 1; i < nfns; i++)
            p->fn.push_back(func_list->fn[i - 1]);
        delete func_list;
    }

    va_end(ap);
    return p;
}

void freeNode(nodeType *p) {
    int i;

    if (!p) return;
    switch (p->type) {
        case typeOpr:
            {
                oprNodeType* p_opr = (oprNodeType*)p;
                for (i = 0; i < p_opr->nops; i++)
                    freeNode(p_opr->op[i]);
            }
            break;
        case typeEps:
            {
                epsNodeType* p_eps = (epsNodeType*)p;
                for (i = 0; i < p_eps->neps; i++)
                    freeNode(p_eps->ep[i]);
            }
            break;
        case typeSta:
            {
                staNodeType* p_sta = (staNodeType*)p;
                for (i = 0; i < p_sta->npts; i++)
                   freeNode(p_sta->pt[i]);
            }
            break;
        case typeLis:
            {
                lisNodeType* p_lis = (lisNodeType*)p;
                for (i = 0; i < p_lis->nsts; i++)
                   freeNode(p_lis->st[i]);
            }
            break;
        case typeFun:
            {
                funNodeType* p_fun = (funNodeType*)p;
                for (i = 0; i < p_fun->npts; i++)
                   freeNode(p_fun->pt[i]);
            }
            break;
        case typePar:
            {
                parNodeType* p_par = (parNodeType*)p;
                for (i = 0; i < p_par->npts; i++)
                   freeNode(p_par->pt[i]);
            }
            break;
        case typePrs:
            {
                prsNodeType* p_prs = (prsNodeType*)p;
                for (i = 0; i < p_prs->npas; i++)
                   freeNode(p_prs->pa[i]);
            }
            break;
        case typePro:
            {
                proNodeType* p_pro = (proNodeType*)p;
                for (i = 0; i < p_pro->nfns; i++)
                   freeNode(p_pro->fn[i]);
            }
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
    generated_code = fopen(argv[2], "w");
    yyparse();
    fclose(yyin);
    fclose(generated_code);
    return 0;
}
