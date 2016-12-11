%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

#include "calc3.h"

/* prototypes */
nodeType *opr(int oper, int order, int nops, ...);
nodeType *id(int i);
nodeType *con(int value);
void freeNode(nodeType *p);
int ex(nodeType *p);
int yylex(void);

void yyerror(char *s);
char* sym[100];                    /* symbol table, for single character variable */
FILE *yyin;
%}

/* set yylval as the following union type */
%union {
    int iValue;                 /* integer value */
    char sIndex;                /* symbol table index */
    nodeType *nPtr;             /* node pointer */
};

%token <iValue> IDENTIFIER
%token <sIndex> CONSTANT
%token SIZEOF
%token PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token XOR_ASSIGN OR_ASSIGN TYPE

%token TYPEDEF EXTERN STATIC AUTO REGISTER
%token CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOLATILE VOID
%token STRUCT UNION ENUM ELLIPSIS

%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%token PRIMARY_EXPRESSION POSTFIX_EXPRESSION ARGUMENT_EXPRESSION_LIST UNARY_EXPRESSION
%token UNARY_OPERATOR CAST_EXPRESSION MULTIPLICATIVE_EXPRESSION ADDITIVE_EXPRESSION
%token SHIFT_EXPRESSION RELATIONAL_EXPRESSION EQUALITY_EXPRESSION AND_EXPRESSION
%token EXCLUSIVE_OR_EXPRESSION INCLUSIVE_OR_EXPRESSION LOGICAL_AND_EXPRESSION LOGICAL_OR_EXPRESSION
%token CONDITIONAL_EXPRESSION ASSIGNMENT_EXPRESSION ASSIGNMENT_OPERATOR EXPRESSION
%token CONSTANT_EXPRESSION DECLARATION DECLARATION_SPECIFIERS INIT_DECLARATOR_LIST
%token INIT_DECLARATOR STORAGE_CLASS_SPECIFIER TYPE_SPECIFIER STRUCT_OR_UNION_SPECIFIER
%token STRUCT_OR_UNION STRUCT_DECLARATION_LIST STRUCT_DECLARATION SPECIFIER_QUALIFIER_LIST
%token STRUCT_DECLARATOR_LIST STRUCT_DECLARATOR ENUM_SPECIFIER ENUMERATOR_LIST
%token ENUMERATOR TYPE_QUALIFIER DECLARATOR DIRECT_DECLARATOR
%token POINTER TYPE_QUALIFIER_LIST PARAMETER_TYPE_LIST PARAMETER_LIST
%token PARAMETER_DECLARATION IDENTIFIER_LIST TYPE_NAME ABSTRACT_DECLARATOR
%token DIRECT_ABSTRACT_DECLARATOR INITIALIZER INITIALIZER_LIST STATEMENT
%token LABELED_STATEMENT COMPOUND_STATEMENT DECLARATION_LIST STATEMENT_LIST
%token EXPRESSION_STATEMENT SELECTION_STATEMENT ITERATION_STATEMENT JUMP_STATEMENT
%token TRANSLATION_UNIT EXTERNAL_DECLARATION FUNCTION_DEFINITION

%start start_here

// Totaly we have 63 non-terminals !!
%type <nPtr> primary_expression postfix_expression argument_expression_list unary_expression
%type <nPtr> unary_operator cast_expression multiplicative_expression additive_expression
%type <nPtr> shift_expression relational_expression equality_expression and_expression
%type <nPtr> exclusive_or_expression inclusive_or_expression logical_and_expression logical_or_expression
%type <nPtr> conditional_expression assignment_expression assignment_operator expression
%type <nPtr> constant_expression declaration declaration_specifiers init_declarator_list
%type <nPtr> init_declarator storage_class_specifier type_specifier struct_or_union_specifier
%type <nPtr> struct_or_union struct_declaration_list struct_declaration specifier_qualifier_list
%type <nPtr> struct_declarator_list struct_declarator enum_specifier enumerator_list
%type <nPtr> enumerator type_qualifier declarator direct_declarator
%type <nPtr> pointer type_qualifier_list parameter_type_list parameter_list
%type <nPtr> parameter_declaration identifier_list type_name abstract_declarator
%type <nPtr> direct_abstract_declarator initializer initializer_list statement
%type <nPtr> labeled_statement compound_statement declaration_list statement_list
%type <nPtr> expression_statement selection_statement iteration_statement jump_statement
%type <nPtr> translation_unit external_declaration function_definition
%%

/* this expression has been simplified */
primary_expression
	: IDENTIFIER                                               { $$ = id($1); }
	| CONSTANT                                                 { $$ = con($1); }
	| '(' expression ')'                                       { $$ = opr(PRIMARY_EXPRESSION, 3, 1, $2); }
	;

postfix_expression
	: primary_expression                                       { $$ = opr(POSTFIX_EXPRESSION, 1, 1, $1); }
	| postfix_expression '[' expression ']'                    { $$ = opr(POSTFIX_EXPRESSION, 2, 2, $1, $3); }
	| postfix_expression '(' ')'                               { $$ = opr(POSTFIX_EXPRESSION, 3, 1, $1); }
	| postfix_expression '(' argument_expression_list ')'      { $$ = opr(POSTFIX_EXPRESSION, 4, 2, $1, $3); }
	| postfix_expression '.' IDENTIFIER                        { $$ = opr(POSTFIX_EXPRESSION, 5, 2, $1, id($3)); }
	| postfix_expression PTR_OP IDENTIFIER                     { $$ = opr(POSTFIX_EXPRESSION, 6, 2, $1, id($3)); }
	| postfix_expression INC_OP                                { $$ = opr(POSTFIX_EXPRESSION, 7, 1, $1); }
	| postfix_expression DEC_OP                                { $$ = opr(POSTFIX_EXPRESSION, 8, 1, $1); }
	;

argument_expression_list
	: assignment_expression                                    { $$ = opr(ARGUMENT_EXPRESSION_LIST, 1, 1, $1); }
	| argument_expression_list ',' assignment_expression       { $$ = opr(ARGUMENT_EXPRESSION_LIST, 2, 2, $1, $3); }
	;

unary_expression
	: postfix_expression                                       { $$ = opr(UNARY_EXPRESSION, 1, 1, $1); }
	| INC_OP unary_expression                                  { $$ = opr(UNARY_EXPRESSION, 2, 1, $2); }
	| DEC_OP unary_expression                                  { $$ = opr(UNARY_EXPRESSION, 3, 1, $2); }
	| unary_operator cast_expression                           { $$ = opr(UNARY_EXPRESSION, 4, 2, $1, $2); }
	| SIZEOF unary_expression                                  { $$ = opr(UNARY_EXPRESSION, 5, 1, $2); }
	| SIZEOF '(' type_name ')'                                 { $$ = opr(UNARY_EXPRESSION, 6, 1, $3); }
	;

unary_operator
	: '&'                                                      { $$ = opr(UNARY_OPERATOR, 1, 0); }
	| '*'                                                      { $$ = opr(UNARY_OPERATOR, 2, 0); }
	| '+'                                                      { $$ = opr(UNARY_OPERATOR, 3, 0); }
	| '-'                                                      { $$ = opr(UNARY_OPERATOR, 4, 0); }
	| '~'                                                      { $$ = opr(UNARY_OPERATOR, 5, 0); }
	| '!'                                                      { $$ = opr(UNARY_OPERATOR, 6, 0); }
	;

cast_expression
	: unary_expression                                         { $$ = opr(CAST_EXPRESSION, 1, 1, $1); }
	| '(' type_name ')' cast_expression                        { $$ = opr(CAST_EXPRESSION, 2, 2, $2, $4); }
	;

multiplicative_expression
	: cast_expression                                          { $$ = opr(MULTIPLICATIVE_EXPRESSION, 1, 1, $1); }
	| multiplicative_expression '*' cast_expression            { $$ = opr(MULTIPLICATIVE_EXPRESSION, 2, 2, $1, $3); }
	| multiplicative_expression '/' cast_expression            { $$ = opr(MULTIPLICATIVE_EXPRESSION, 3, 2, $1, $3); }
	| multiplicative_expression '%' cast_expression            { $$ = opr(MULTIPLICATIVE_EXPRESSION, 4, 2, $1, $3); }
	;

additive_expression
	: multiplicative_expression                                { $$ = opr(ADDITIVE_EXPRESSION, 1, 1, $1); }
	| additive_expression '+' multiplicative_expression        { $$ = opr(ADDITIVE_EXPRESSION, 2, 2, $1, $3); }
	| additive_expression '-' multiplicative_expression        { $$ = opr(ADDITIVE_EXPRESSION, 3, 2, $1, $3); }
	;

shift_expression
	: additive_expression                                      { $$ = opr(SHIFT_EXPRESSION, 1, 1, $1); }
	| shift_expression LEFT_OP additive_expression             { $$ = opr(SHIFT_EXPRESSION, 2, 2, $1, $3); }
	| shift_expression RIGHT_OP additive_expression            { $$ = opr(SHIFT_EXPRESSION, 3, 2, $1, $3); }
	;

relational_expression
	: shift_expression                                         { $$ = opr(RELATIONAL_EXPRESSION, 1, 1, $1); }
	| relational_expression '<' shift_expression               { $$ = opr(RELATIONAL_EXPRESSION, 2, 2, $1, $3); }
	| relational_expression '>' shift_expression               { $$ = opr(RELATIONAL_EXPRESSION, 3, 2, $1, $3); }
	| relational_expression LE_OP shift_expression             { $$ = opr(RELATIONAL_EXPRESSION, 4, 2, $1, $3); }
	| relational_expression GE_OP shift_expression             { $$ = opr(RELATIONAL_EXPRESSION, 5, 2, $1, $3); }
	;

equality_expression
	: relational_expression                                    { $$ = opr(EQUALITY_EXPRESSION, 1, 1, $1); }
	| equality_expression EQ_OP relational_expression          { $$ = opr(EQUALITY_EXPRESSION, 2, 2, $1, $3); }
	| equality_expression NE_OP relational_expression          { $$ = opr(EQUALITY_EXPRESSION, 3, 2, $1, $3); }
	;

and_expression
	: equality_expression                                      { $$ = opr(AND_EXPRESSION, 1, 1, $1); }
	| and_expression '&' equality_expression                   { $$ = opr(AND_EXPRESSION, 2, 2, $1, $3); }
	;

exclusive_or_expression
	: and_expression                                           { $$ = opr(EXCLUSIVE_OR_EXPRESSION, 1, 1, $1); }
	| exclusive_or_expression '^' and_expression               { $$ = opr(EXCLUSIVE_OR_EXPRESSION, 2, 2, $1, $3); }
	;

inclusive_or_expression
	: exclusive_or_expression                                  { $$ = opr(INCLUSIVE_OR_EXPRESSION, 1, 1, $1); }
	| inclusive_or_expression '|' exclusive_or_expression      { $$ = opr(INCLUSIVE_OR_EXPRESSION, 2, 2, $1, $3); }
	;

logical_and_expression
	: inclusive_or_expression                                  { $$ = opr(LOGICAL_AND_EXPRESSION, 1, 1, $1); }
	| logical_and_expression AND_OP inclusive_or_expression    { $$ = opr(LOGICAL_AND_EXPRESSION, 2, 2, $1, $3); }
	;

logical_or_expression
	: logical_and_expression                                   { $$ = opr(LOGICAL_OR_EXPRESSION, 1, 1, $1); }
	| logical_or_expression OR_OP logical_and_expression       { $$ = opr(LOGICAL_OR_EXPRESSION, 2, 2, $1, $3); }
	;

conditional_expression
	: logical_or_expression                                    { $$ = opr(CONDITIONAL_EXPRESSION, 1, 1, $1); }
	| logical_or_expression '?' expression ':' conditional_expression { $$ = opr(CONDITIONAL_EXPRESSION, 2, 3, $1, $3, $5); }
	;

assignment_expression
	: conditional_expression                                   { $$ = opr(ASSIGNMENT_EXPRESSION, 1, 1, $1); }
	| unary_expression assignment_operator assignment_expression { $$ = opr(ASSIGNMENT_EXPRESSION, 2, 3, $1, $2, $3); }
	;

assignment_operator
  : '='                                                      { $$ = opr(ASSIGNMENT_OPERATOR, 1, 0); }
  | MUL_ASSIGN                                               { $$ = opr(ASSIGNMENT_OPERATOR, 2, 0); }
  | DIV_ASSIGN                                               { $$ = opr(ASSIGNMENT_OPERATOR, 3, 0); }
  | MOD_ASSIGN                                               { $$ = opr(ASSIGNMENT_OPERATOR, 4, 0); }
  | ADD_ASSIGN                                               { $$ = opr(ASSIGNMENT_OPERATOR, 5, 0); }
  | SUB_ASSIGN                                               { $$ = opr(ASSIGNMENT_OPERATOR, 6, 0); }
  | LEFT_ASSIGN                                              { $$ = opr(ASSIGNMENT_OPERATOR, 7, 0); }
  | RIGHT_ASSIGN                                             { $$ = opr(ASSIGNMENT_OPERATOR, 8, 0); }
  | AND_ASSIGN                                               { $$ = opr(ASSIGNMENT_OPERATOR, 9, 0); }
  | XOR_ASSIGN                                               { $$ = opr(ASSIGNMENT_OPERATOR, 10, 0); }
  | OR_ASSIGN                                                { $$ = opr(ASSIGNMENT_OPERATOR, 11, 0); }
	;

expression
  : assignment_expression                                    { $$ = opr(EXPRESSION, 1, 1, $1); }
  | expression ',' assignment_expression                     { $$ = opr(EXPRESSION, 2, 2, $1, $3); }
	;

constant_expression
  : conditional_expression                                   { $$ = opr(CONSTANT_EXPRESSION, 1, 1, $1); }
	;

declaration
	: declaration_specifiers ';'                               { $$ = opr(DECLARATION, 1, 1, $1); }
	| declaration_specifiers init_declarator_list ';'          { $$ = opr(DECLARATION, 2, 2, $1, $2); }
  ;

declaration_specifiers
	: storage_class_specifier                                  { $$ = opr(DECLARATION_SPECIFIERS, 1, 1, $1); }
	| storage_class_specifier declaration_specifiers           { $$ = opr(DECLARATION_SPECIFIERS, 2, 2, $1, $2); }
	| type_specifier                                           { $$ = opr(DECLARATION_SPECIFIERS, 3, 1, $1); }
	| type_specifier declaration_specifiers                    { $$ = opr(DECLARATION_SPECIFIERS, 4, 2, $1, $2); }
	| type_qualifier                                           { $$ = opr(DECLARATION_SPECIFIERS, 5, 1, $1); }
	| type_qualifier declaration_specifiers                    { $$ = opr(DECLARATION_SPECIFIERS, 6, 2, $1, $2); }
  ;

init_declarator_list
	: init_declarator                                          { $$ = opr(INIT_DECLARATOR_LIST, 1, 1, $1); }
	| init_declarator_list ',' init_declarator                 { $$ = opr(INIT_DECLARATOR_LIST, 2, 2, $1, $3); }
  ;

init_declarator
	: declarator                                               { $$ = opr(INIT_DECLARATOR, 1, 1, $1); }
	| declarator '=' initializer                               { $$ = opr(INIT_DECLARATOR, 2, 2, $1, $3); }
  ;

storage_class_specifier
	: TYPEDEF                                                  { $$ = opr(STORAGE_CLASS_SPECIFIER, 1, 0); }
	| EXTERN                                                   { $$ = opr(STORAGE_CLASS_SPECIFIER, 2, 0); }
	| STATIC                                                   { $$ = opr(STORAGE_CLASS_SPECIFIER, 3, 0); }
	| AUTO                                                     { $$ = opr(STORAGE_CLASS_SPECIFIER, 4, 0); }
	| REGISTER                                                 { $$ = opr(STORAGE_CLASS_SPECIFIER, 5, 0); }
  ;

type_specifier
	: VOID                                                     { $$ = opr(TYPE_SPECIFIER, 1, 0); }
	| CHAR                                                     { $$ = opr(TYPE_SPECIFIER, 2, 0); }
	| SHORT                                                    { $$ = opr(TYPE_SPECIFIER, 3, 0); }
	| INT                                                      { $$ = opr(TYPE_SPECIFIER, 4, 0); }
	| LONG                                                     { $$ = opr(TYPE_SPECIFIER, 5, 0); }
	| FLOAT                                                    { $$ = opr(TYPE_SPECIFIER, 6, 0); }
	| DOUBLE                                                   { $$ = opr(TYPE_SPECIFIER, 7, 0); }
	| SIGNED                                                   { $$ = opr(TYPE_SPECIFIER, 8, 0); }
	| UNSIGNED                                                 { $$ = opr(TYPE_SPECIFIER, 9, 0); }
	| struct_or_union_specifier                                { $$ = opr(TYPE_SPECIFIER, 10, 1, $1); }
	| enum_specifier                                           { $$ = opr(TYPE_SPECIFIER, 11, 1, $1); }
	| TYPE                                                     { $$ = opr(TYPE_SPECIFIER, 12, 0); }
  ;

struct_or_union_specifier
	: struct_or_union IDENTIFIER '{' struct_declaration_list '}'{ $$ = opr(STRUCT_OR_UNION_SPECIFIER, 1, 3, $1, id($2), $4); }
	| struct_or_union '{' struct_declaration_list '}'          { $$ = opr(STRUCT_OR_UNION_SPECIFIER, 2, 2, $1, $3); }
	| struct_or_union IDENTIFIER                               { $$ = opr(STRUCT_OR_UNION_SPECIFIER, 3, 2, $1, id($2)); }
  ;

struct_or_union
	: STRUCT                                                   { $$ = opr(STRUCT_OR_UNION, 1, 0); }
	| UNION                                                    { $$ = opr(STRUCT_OR_UNION, 2, 0); }
  ;

struct_declaration_list
	: struct_declaration                                       { $$ = opr(STRUCT_DECLARATION_LIST, 1, 1, $1); }
	| struct_declaration_list struct_declaration               { $$ = opr(STRUCT_DECLARATION_LIST, 2, 2, $1, $2); }
  ;

struct_declaration
	: specifier_qualifier_list struct_declarator_list ';'      { $$ = opr(STRUCT_DECLARATION, 1, 2, $1, $2); }
  ;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list                  { $$ = opr(SPECIFIER_QUALIFIER_LIST, 1, 2, $1, $2); }
	| type_specifier                                           { $$ = opr(SPECIFIER_QUALIFIER_LIST, 2, 1, $1); }
	| type_qualifier specifier_qualifier_list                  { $$ = opr(SPECIFIER_QUALIFIER_LIST, 3, 2, $1, $2); }
	| type_qualifier                                           { $$ = opr(SPECIFIER_QUALIFIER_LIST, 4, 1, $1); }
  ;

struct_declarator_list
	: struct_declarator                                        { $$ = opr(STRUCT_DECLARATOR_LIST, 1, 1, $1); }
	| struct_declarator_list ',' struct_declarator             { $$ = opr(STRUCT_DECLARATOR_LIST, 2, 2, $1, $3); }
  ;

struct_declarator
	: declarator                                               { $$ = opr(STRUCT_DECLARATOR, 1, 1, $1); }
	| ':' constant_expression                                  { $$ = opr(STRUCT_DECLARATOR, 2, 1, $2); }
	| declarator ':' constant_expression                       { $$ = opr(STRUCT_DECLARATOR, 3, 2, $1, $3); }
  ;

enum_specifier
	: ENUM '{' enumerator_list '}'                             { $$ = opr(ENUM_SPECIFIER, 1, 1, $3); }
	| ENUM IDENTIFIER '{' enumerator_list '}'                  { $$ = opr(ENUM_SPECIFIER, 2, 2, id($2), $4); }
	| ENUM IDENTIFIER                                          { $$ = opr(ENUM_SPECIFIER, 3, 1, id($2)); }
  ;

enumerator_list
	: enumerator                                               { $$ = opr(ENUMERATOR_LIST, 1, 1, $1); }
	| enumerator_list ',' enumerator                           { $$ = opr(ENUMERATOR_LIST, 2, 2, $1, $3); }
  ;

enumerator
	: IDENTIFIER                                               { $$ = opr(ENUMERATOR, 1, 1, id($1)); }
	| IDENTIFIER '=' constant_expression                       { $$ = opr(ENUMERATOR, 2, 2, id($1), $3); }
  ;

type_qualifier
	: CONST                                                    { $$ = opr(TYPE_QUALIFIER, 1, 0); }
	| VOLATILE                                                 { $$ = opr(TYPE_QUALIFIER, 2, 0); }
  ;

declarator
	: pointer direct_declarator                                { $$ = opr(DECLARATOR, 1, 2, $1, $2); }
	| direct_declarator                                        { $$ = opr(DECLARATOR, 2, 1, $1); }
  ;

direct_declarator
	: IDENTIFIER                                               { $$ = opr(DIRECT_DECLARATOR, 1, 1, id($1)); }
	| '(' declarator ')'                                       { $$ = opr(DIRECT_DECLARATOR, 2, 1, $2); }
	| direct_declarator '[' constant_expression ']'            { $$ = opr(DIRECT_DECLARATOR, 3, 2, $1, $3); }
	| direct_declarator '[' ']'                                { $$ = opr(DIRECT_DECLARATOR, 4, 1, $1); }
	| direct_declarator '(' parameter_type_list ')'            { $$ = opr(DIRECT_DECLARATOR, 5, 2, $1, $3); }
	| direct_declarator '(' identifier_list ')'                { $$ = opr(DIRECT_DECLARATOR, 6, 2, $1, $3); }
	| direct_declarator '(' ')'                                { $$ = opr(DIRECT_DECLARATOR, 7, 1, $1); }
  ;

pointer
	: '*'                                                      { $$ = opr(POINTER, 1, 0); }
	| '*' type_qualifier_list                                  { $$ = opr(POINTER, 2, 1, $2); }
	| '*' pointer                                              { $$ = opr(POINTER, 3, 1, $2); }
	| '*' type_qualifier_list pointer                          { $$ = opr(POINTER, 4, 2, $2, $3); }
  ;

type_qualifier_list
	: type_qualifier                                           { $$ = opr(TYPE_QUALIFIER_LIST, 1, 1, $1); }
	| type_qualifier_list type_qualifier                       { $$ = opr(TYPE_QUALIFIER_LIST, 2, 2, $1, $2); }
  ;


parameter_type_list
	: parameter_list                                           { $$ = opr(PARAMETER_TYPE_LIST, 1, 1, $1); }
	| parameter_list ',' ELLIPSIS                              { $$ = opr(PARAMETER_TYPE_LIST, 2, 1, $1); }
  ;

parameter_list
	: parameter_declaration                                    { $$ = opr(PARAMETER_LIST, 1, 1, $1); }
	| parameter_list ',' parameter_declaration                 { $$ = opr(PARAMETER_LIST, 2, 2, $1, $3); }
  ;

parameter_declaration
	: declaration_specifiers declarator                        { $$ = opr(PARAMETER_DECLARATION, 1, 2, $1, $2); }
	| declaration_specifiers abstract_declarator               { $$ = opr(PARAMETER_DECLARATION, 2, 2, $1, $2); }
	| declaration_specifiers                                   { $$ = opr(PARAMETER_DECLARATION, 3, 1, $1); }
  ;

identifier_list
	: IDENTIFIER                                               { $$ = opr(IDENTIFIER_LIST, 1, 1, id($1)); }
	| identifier_list ',' IDENTIFIER                           { $$ = opr(IDENTIFIER_LIST, 2, 2, $1, id($3)); }
  ;

type_name
	: specifier_qualifier_list                                 { $$ = opr(TYPE_NAME, 1, 1, $1); }
	| specifier_qualifier_list abstract_declarator             { $$ = opr(TYPE_NAME, 2, 2, $1, $2); }
  ;

abstract_declarator
	: pointer                                                  { $$ = opr(ABSTRACT_DECLARATOR, 1, 1, $1); }
	| direct_abstract_declarator                               { $$ = opr(ABSTRACT_DECLARATOR, 2, 1, $1); }
	| pointer direct_abstract_declarator                       { $$ = opr(ABSTRACT_DECLARATOR, 3, 2, $1, $2); }
  ;

direct_abstract_declarator
	: '(' abstract_declarator ')'                              { $$ = opr(DIRECT_ABSTRACT_DECLARATOR, 1, 1, $2); }
	| '[' ']'                                                  { $$ = opr(DIRECT_ABSTRACT_DECLARATOR, 2, 0); }
	| '[' constant_expression ']'                              { $$ = opr(DIRECT_ABSTRACT_DECLARATOR, 3, 1, $2); }
	| direct_abstract_declarator '[' ']'                       { $$ = opr(DIRECT_ABSTRACT_DECLARATOR, 4, 1, $1); }
	| direct_abstract_declarator '[' constant_expression ']'   { $$ = opr(DIRECT_ABSTRACT_DECLARATOR, 5, 2, $1, $3); }
	| '(' ')'                                                  { $$ = opr(DIRECT_ABSTRACT_DECLARATOR, 6, 0); }
	| '(' parameter_type_list ')'                              { $$ = opr(DIRECT_ABSTRACT_DECLARATOR, 7, 1, $2); }
	| direct_abstract_declarator '(' ')'                       { $$ = opr(DIRECT_ABSTRACT_DECLARATOR, 8, 1, $1); }
	| direct_abstract_declarator '(' parameter_type_list ')'   { $$ = opr(DIRECT_ABSTRACT_DECLARATOR, 9, 2, $1, $3); }
  ;

initializer
	: assignment_expression                                    { $$ = opr(INITIALIZER, 1, 1, $1); }
	| '{' initializer_list '}'                                 { $$ = opr(INITIALIZER, 2, 1, $2); }
	| '{' initializer_list ',' '}'                             { $$ = opr(INITIALIZER, 3, 1, $2); }
  ;

initializer_list
	: initializer                                              { $$ = opr(INITIALIZER_LIST, 1, 1, $1); }
	| initializer_list ',' initializer                         { $$ = opr(INITIALIZER_LIST, 2, 2, $1, $3); }
  ;

statement
	: labeled_statement                                        { $$ = opr(STATEMENT, 1, 1, $1); }
	| compound_statement                                       { $$ = opr(STATEMENT, 2, 1, $1); }
	| expression_statement                                     { $$ = opr(STATEMENT, 3, 1, $1); }
	| selection_statement                                      { $$ = opr(STATEMENT, 4, 1, $1); }
	| iteration_statement                                      { $$ = opr(STATEMENT, 5, 1, $1); }
	| jump_statement                                           { $$ = opr(STATEMENT, 6, 1, $1); }
  ;

labeled_statement
	: IDENTIFIER ':' statement                                 { $$ = opr(LABELED_STATEMENT, 1, 2, id($1), $3); }
	| CASE constant_expression ':' statement                   { $$ = opr(LABELED_STATEMENT, 2, 2, $2, $4); }
	| DEFAULT ':' statement                                    { $$ = opr(LABELED_STATEMENT, 3, 1, $3); }
  ;

compound_statement
	: '{' '}'                                                  { $$ = opr(COMPOUND_STATEMENT, 1, 0); }
	| '{' statement_list '}'                                   { $$ = opr(COMPOUND_STATEMENT, 2, 1, $2); }
	| '{' declaration_list '}'                                 { $$ = opr(COMPOUND_STATEMENT, 3, 1, $2); }
	| '{' declaration_list statement_list '}'                  { $$ = opr(COMPOUND_STATEMENT, 4, 2, $2, $3); }
  ;

declaration_list
	: declaration                                              { $$ = opr(DECLARATION_LIST, 1, 1, $1); }
	| declaration_list declaration                             { $$ = opr(DECLARATION_LIST, 2, 2, $1, $2); }
  ;

statement_list
	: statement                                                { $$ = opr(STATEMENT_LIST, 1, 1, $1); }
	| statement_list statement                                 { $$ = opr(STATEMENT_LIST, 2, 2, $1, $2); }
  ;

expression_statement
	: ';'                                                      { $$ = opr(EXPRESSION_STATEMENT, 1, 0); }
	| expression ';'                                           { $$ = opr(EXPRESSION_STATEMENT, 2, 1, $1); }
  ;

selection_statement
	: IF '(' expression ')' statement                          { $$ = opr(SELECTION_STATEMENT, 1, 2, $3, $5); }
	| IF '(' expression ')' statement ELSE statement           { $$ = opr(SELECTION_STATEMENT, 2, 3, $3, $5, $7); }
	| SWITCH '(' expression ')' statement                      { $$ = opr(SELECTION_STATEMENT, 3, 2, $3, $5); }
  ;

iteration_statement
	: WHILE '(' expression ')' statement                       { $$ = opr(ITERATION_STATEMENT, 1, 2, $3, $5); }
	| DO statement WHILE '(' expression ')' ';'                { $$ = opr(ITERATION_STATEMENT, 2, 2, $2, $5); }
	| FOR '(' expression_statement expression_statement ')' statement  { $$ = opr(ITERATION_STATEMENT, 3, 3, $3, $4, $6); }
	| FOR '(' expression_statement expression_statement expression ')' statement  { $$ = opr(ITERATION_STATEMENT, 4, 4, $3, $4, $5, $7); }
  ;

jump_statement
	: GOTO IDENTIFIER ';'                                      { $$ = opr(JUMP_STATEMENT, 1, 1, id($2)); }
	| CONTINUE ';'                                             { $$ = opr(JUMP_STATEMENT, 2, 0); }
	| BREAK ';'                                                { $$ = opr(JUMP_STATEMENT, 3, 0); }
	| RETURN ';'                                               { $$ = opr(JUMP_STATEMENT, 4, 0); }
	| RETURN expression ';'                                    { $$ = opr(JUMP_STATEMENT, 5, 1, $2); }
  ;

start_here
  : translation_unit                                         { ex($1) ; freeNode($1); exit(0);}
  ;

translation_unit
	: external_declaration                                     { $$ = opr(TRANSLATION_UNIT, 1, 1, $1); }
	| translation_unit external_declaration                    { $$ = opr(TRANSLATION_UNIT, 2, 2, $1, $2); }
  ;

external_declaration
	: function_definition                                      { $$ = opr(EXTERNAL_DECLARATION, 1, 1, $1); }
	| declaration                                              { $$ = opr(EXTERNAL_DECLARATION, 2, 1, $1); }
  ;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement { $$ = opr(FUNCTION_DEFINITION, 1, 4, $1, $2, $3, $4); }
	| declaration_specifiers declarator compound_statement     { $$ = opr(FUNCTION_DEFINITION, 2, 3, $1, $2, $3); }
	| declarator declaration_list compound_statement           { $$ = opr(FUNCTION_DEFINITION, 3, 3, $1, $2, $3); }
	| declarator compound_statement                            { $$ = opr(FUNCTION_DEFINITION, 4, 2, $1, $2); }
  ;

%%

nodeType *con(int value) {
    nodeType *p;

    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    /* copy information */
    /* set the new node to constant node */
    p->type = typeCon;
    /* set constant node value */
    p->con.value = value;

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

nodeType *opr(int oper, int order, int nops, ...) {
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
    /* set order */
    p->opr.order = order;
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
    yyin = fopen(argv[1], "r");
    yyparse();
    fclose(yyin);
    return 0;
}
