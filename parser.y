%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

#include "calc3.h"

/* prototypes */
nodeType *lis(int mark, int nlis, ...);
nodeType *sta(int mark, int npts, ...);
nodeType *opr(int oper, int nops, ...);
nodeType *id(int i);
nodeType *conTyp(int value);
nodeType *conInt(int value);
nodeType *conChr(char value);
nodeType *conStr(int i);

int getStateNum(nodeType* p);
void freeNode(nodeType *p);
int ex(nodeType *p);
int yylex(void);

void yyerror(char *s);
char* sym[100];                    /* identifier table */
char* str[100];                    /* string table */
FILE *yyin;

// #define YYDEBUG 1
%}

/* set yylval as the following union type */
%union {
    int iType;                  /* type category */
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
%token DECLARE
%token WHILE IF PRINTF BREAK RETURN MAIN GETS STRLEN

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
        function                { ex($1); freeNode($1); exit(0); }
        ;

function:
        type_name MAIN '(' ')' statement         { $$ = opr(MAIN, 2, $1, $5); }  // function main
        ;

type_name:
          INT              { $$ = conTyp($1); }
        | CHAR             { $$ = conTyp($1); }
        ;

statement_list:
          statement                       { $$ = lis(';', 1, $1); }
        | statement statement_list        { $$ = lis(';', 1 + getStateNum($2), $1, $2); }
        ;

statement:
          BREAK ';'                                     { $$ = sta(BREAK, 0); }
        | RETURN expr ';'                               { $$ = sta(RETURN, 1, $2); }
        | PRINTF '(' STRING ')' ';'                     { $$ = sta(PRINTF, 1, conStr($3)); }
        | PRINTF '(' STRING ',' expr ')' ';'            { $$ = sta(PRINTF, 2, conStr($3), $5); }
        | GETS '(' IDENTIFIER ')' ';'                   { $$ = sta(GETS, 1, id($3)); }
        | IDENTIFIER '=' expr ';'                       { $$ = sta('=', 2, id($1), $3); }
        | IDENTIFIER '[' expr ']' '=' expr ';'          { $$ = sta('=', 3, id($1), $3, $6); }
        | type_name IDENTIFIER '[' INTEGER ']' ';'      { $$ = sta(DECLARE, 3, $1, id($2), conInt($4)); }
        | type_name IDENTIFIER '=' expr ';'             { $$ = sta(DECLARE, 3, $1, id($2), $4); }
        | WHILE '(' expr ')' statement                  { $$ = sta(WHILE, 2, $3, $5); }
        | IF '(' expr ')' statement %prec IFX           { $$ = sta(IF, 2, $3, $5); }
        | IF '(' expr ')' statement ELSE statement      { $$ = sta(IF, 3, $3, $5, $7); }  // IF-ELSE is prior to the IF statement
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

nodeType *conTyp(int value) {
    nodeType *p;

    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    /* copy information */
    /* set the new node to constant node */
    p->type = typeTyp;
    /* set constant node value */
    p->conTyp.value = value;

    return p;
}

nodeType *conInt(int value) {
    nodeType *p;

    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    /* copy information */
    /* set the new node to constant node */
    p->type = typeInt;
    /* set constant node value */
    p->conInt.value = value;

    return p;
}

nodeType *conChr(char value) {
    nodeType *p;

    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    /* copy information */
    /* set the new node to constant node */
    p->type = typeChr;
    /* set constant node value */
    p->conChr.value = value;

    return p;
}

nodeType *conStr(int i) {
    nodeType *p;

    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    /* copy information */
    /* set the new node to constant node */
    p->type = typeStr;
    /* set constant node value */
    p->conStr.i = i;

    return p;
}

nodeType *id(int i) {
    nodeType *p;

    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    /* copy information */
    /* set the new node to identifier node */
    p->type = typeId;
    /* set the identifier index in sym */
    p->id.i = i;

    return p;
}

nodeType *opr(int oper, int nops, ...) {
    va_list ap;
    nodeType *p;
    int i;

    /* allocate node, extending op array */
    if ((p = malloc(sizeof(nodeType) + (nops-1) * sizeof(nodeType *))) == NULL)
        yyerror("out of memory");

    /* copy information */
    /* set the new node to identifier node */
    p->type = typeOpr;
    /* set oper */
    p->opr.oper = oper;
    /* set nops */
    p->opr.nops = nops;
    /* make ap be the pointer for the argument behind nops */
    va_start(ap, nops);
    /* add operand pointer(s) */
    for (i = 0; i < nops; i++)
        p->opr.op[i] = va_arg(ap, nodeType*);
    /* make ap to null */
    va_end(ap);
    return p;
}

nodeType *sta(int mark, int npts, ...) {
    va_list ap;
    nodeType *p;
    int i;

    /* allocate node, extending op array */
    if ((p = malloc(sizeof(nodeType) + (npts-1) * sizeof(nodeType *))) == NULL)
        yyerror("out of memory");

    /* copy information */
    /* set the new node to statement node */
    p->type = typeSta;
    /* set mark */
    p->sta.mark = mark;
    /* set npts */
    p->sta.npts = npts;
    /* make ap be the pointer for the argument behind nops */
    va_start(ap, npts);
    /* add operand pointer(s) */
    for (i = 0; i < npts; i++)
        p->sta.pt[i] = va_arg(ap, nodeType*);
    /* make ap to null */
    va_end(ap);
    return p;
}

int getStateNum(nodeType* list) {
    return list->lis.nsts;
}

nodeType *lis(int mark, int nsts, ...) {
    va_list ap;
    nodeType *p;
    int i;

    /* allocate node, extending op array */
    if ((p = malloc(sizeof(nodeType) + (nsts-1) * sizeof(nodeType *))) == NULL)
        yyerror("out of memory");

    /* copy information */
    /* set the new node to identifier node */
    p->type = typeLis;

    /* set nsts */
    p->lis.nsts = nsts;

    /* make ap be the pointer for the argument behind nops */
    va_start(ap, nsts);

    p->lis.st[0] = va_arg(ap, nodeType*);

    if (nsts > 1) {
        nodeType* statement_list = va_arg(ap, nodeType*);
        for (i = 1; i < nsts; i++)
            p->lis.st[i] = statement_list->lis.st[i - 1];
    }

    va_end(ap);
    return p;
}

void freeNode(nodeType *p) {
    int i;

    if (!p) return;
    if (p->type == typeOpr) {
        for (i = 0; i < p->opr.nops; i++)
            freeNode(p->opr.op[i]);
    }
    free (p);
}

void yyerror(char *s) {
    fprintf(stdout, "%s\n", s);
}

int main(int argc, char *argv[]) {
    // #if YYDEBUG
        // yydebug = 1;
    // #endif
    yyin = fopen(argv[1], "r");
    // printf("begin parse");
    yyparse();
    fclose(yyin);
    return 0;
}
