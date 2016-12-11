D			[0-9]
L			[a-zA-Z_]

%{
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include "calc3.h"
#include "y.tab.h"

#define ECHO fwrite(yytext, yyleng, 1, yyout);

void yyerror(char *);

int getIndex(char *);
char* sym[100];
int sym_size = 20;
%}

%%

"auto"			{ ECHO; return(AUTO); }
"break"			{ ECHO; return(BREAK); }
"case"			{ ECHO; return(CASE); }
"char"			{ ECHO; return(CHAR); }
"const"			{ ECHO; return(CONST); }
"continue"		{ ECHO; return(CONTINUE); }
"default"		{ ECHO; return(DEFAULT); }
"do"			{ ECHO; return(DO); }
"double"		{ ECHO; return(DOUBLE); }
"else"			{ ECHO; return(ELSE); }
"enum"			{ ECHO; return(ENUM); }
"extern"		{ ECHO; return(EXTERN); }
"float"			{ ECHO; return(FLOAT); }
"for"			{ ECHO; return(FOR); }
"goto"			{ ECHO; return(GOTO); }
"if"			{ ECHO; return(IF); }
"int"			{ ECHO; return(INT); }
"long"			{ ECHO; return(LONG); }
"register"		{ ECHO; return(REGISTER); }
"return"		{ ECHO; return(RETURN); }
"short"			{ ECHO; return(SHORT); }
"signed"		{ ECHO; return(SIGNED); }
"sizeof"		{ ECHO; return(SIZEOF); }
"static"		{ ECHO; return(STATIC); }
"struct"		{ ECHO; return(STRUCT); }
"switch"		{ ECHO; return(SWITCH); }
"typedef"		{ ECHO; return(TYPEDEF); }
"union"			{ ECHO; return(UNION); }
"unsigned"		{ ECHO; return(UNSIGNED); }
"void"			{ ECHO; return(VOID); }
"volatile"		{ ECHO; return(VOLATILE); }
"while"			{ ECHO; return(WHILE); }

{L}({L}|{D})*		{ ECHO; yylval.sIndex = getIndex(yytext); return(IDENTIFIER); }

{D}+		{ ECHO; yylval.iValue = atoi(yytext); return(CONSTANT); }

"..."			{ ECHO; return(ELLIPSIS); }
">>="			{ ECHO; return(RIGHT_ASSIGN); }
"<<="			{ ECHO; return(LEFT_ASSIGN); }
"+="			{ ECHO; return(ADD_ASSIGN); }
"-="			{ ECHO; return(SUB_ASSIGN); }
"*="			{ ECHO; return(MUL_ASSIGN); }
"/="			{ ECHO; return(DIV_ASSIGN); }
"%="			{ ECHO; return(MOD_ASSIGN); }
"&="			{ ECHO; return(AND_ASSIGN); }
"^="			{ ECHO; return(XOR_ASSIGN); }
"|="			{ ECHO; return(OR_ASSIGN); }
">>"			{ ECHO; return(RIGHT_OP); }
"<<"			{ ECHO; return(LEFT_OP); }
"++"			{ ECHO; return(INC_OP); }
"--"			{ ECHO; return(DEC_OP); }
"->"			{ ECHO; return(PTR_OP); }
"&&"			{ ECHO; return(AND_OP); }
"||"			{ ECHO; return(OR_OP); }
"<="			{ ECHO; return(LE_OP); }
">="			{ ECHO; return(GE_OP); }
"=="			{ ECHO; return(EQ_OP); }
"!="			{ ECHO; return(NE_OP); }
";"			{ ECHO; return(';'); }
("{"|"<%")		{ ECHO; return('{'); }
("}"|"%>")		{ ECHO; return('}'); }
","			{ ECHO; return(','); }
":"			{ ECHO; return(':'); }
"="			{ ECHO; return('='); }
"("			{ ECHO; return('('); }
")"			{ ECHO; return(')'); }
("["|"<:")		{ ECHO; return('['); }
("]"|":>")		{ ECHO; return(']'); }
"."			{ ECHO; return('.'); }
"&"			{ ECHO; return('&'); }
"!"			{ ECHO; return('!'); }
"~"			{ ECHO; return('~'); }
"-"			{ ECHO; return('-'); }
"+"			{ ECHO; return('+'); }
"*"			{ ECHO; return('*'); }
"/"			{ ECHO; return('/'); }
"%"			{ ECHO; return('%'); }
"<"			{ ECHO; return('<'); }
">"			{ ECHO; return('>'); }
"^"			{ ECHO; return('^'); }
"|"			{ ECHO; return('|'); }
"?"			{ ECHO; return('?'); }

[ \t\v\n\f\r]		{ ECHO; }

.			{ ECHO; yyerror("Unknown character"); }

%%

int getIndex(char* str) {
  int i = 0;
  int source_len = strlen(str);

  while (sym[i]) {
    if (strcmp(sym[i], str)) {
      i++;
    } else {
      return i;
    }
  }

  if ((sym[i] = malloc(sizeof(char) * sym_size)) == NULL) {
    yyerror("out of memory");
  } else {
    strncpy(sym[i], str, source_len);
  }
  sym[i][source_len] = '\0';
  return i;
}

int yywrap()
{
	return 1;
}
