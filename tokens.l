D			[0-9]
L			[a-zA-Z_]

%{
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <string>
#include "graph.hpp"
#include "parser.hpp"
using namespace std;

#define ECHO fwrite(yytext, yyleng, 1, yyout);

void yyerror(string);

int getIDIndex(char *);
int getStrIndex(char *);

char* sym[100];
int sym_num = 0;
char* str[100];
int str_num = 0;
%}

%%

"break"			{ ECHO; return(BREAK); }
"char"			{ ECHO; yylval.iType = charType; return(CHAR); }
"else"			{ ECHO; return(ELSE); }
"if"			{ ECHO; return(IF); }
"int"			{ ECHO; yylval.iType = intType; return(INT); }
"return"		{ ECHO; return(RETURN); }
"while"			{ ECHO; return(WHILE); }
"main"          { ECHO; return(MAIN); }
"printf"        { ECHO; return(PRINTF); }
"gets"          { ECHO; return(GETS); }
"strlen"        { ECHO; return(STRLEN); }

{L}({L}|{D})*		{ ECHO; yylval.sIndex = getIDIndex(yytext); return(IDENTIFIER); }

{D}+		{ ECHO; yylval.iValue = atoi(yytext); return(INTEGER); }

L?'(\\.|[^\\'])+'	{ ECHO; yylval.iChar = *yytext; return(CHARACTER); }

L?\"(\\.|[^\\"])*\"	{ ECHO; yylval.sIndex = getStrIndex(yytext); return(STRING); }

"&&"			{ ECHO; return(AND_OP); }
"||"			{ ECHO; return(OR_OP); }
"=="			{ ECHO; return(EQ_OP); }
"!="			{ ECHO; return(NE_OP); }
";"			{ ECHO; return(';'); }
"{"		    { ECHO; return('{'); }
"}"		    { ECHO; return('}'); }
"="			{ ECHO; return('='); }
"("			{ ECHO; return('('); }
")"			{ ECHO; return(')'); }
"["		    { ECHO; return('['); }
"]"		    { ECHO; return(']'); }
"-"			{ ECHO; return('-'); }
"+"			{ ECHO; return('+'); }
"<"			{ ECHO; return('<'); }
">"			{ ECHO; return('>'); }
","         { ECHO; return(','); }
[ \t\n\r]		{ ECHO; }

.			{ ECHO; yyerror("Unknown character"); }

%%

int getStrIndex(char* text) {
  int source_len = strlen(text);

  if ((str[str_num] = malloc(sizeof(char) * (source_len + 1))) == NULL) {
      yyerror("out of memory");
  } else {
      strncpy(str[str_num], text, source_len);
  }

  str[str_num][source_len] = '\0';
  str_num = str_num + 1;
  return str_num - 1;
}

int getIDIndex(char* text) {
  int i = 0;
  int source_len = strlen(text);

  while (sym[i]) {
    if (strcmp(sym[i], text)) {
      i++;
    } else {
      return i;
    }
  }

  if ((sym[i] = malloc(sizeof(char) * (source_len + 1))) == NULL) {
    yyerror("out of memory");
  } else {
    strncpy(sym[i], text, source_len);
  }

  sym[i][source_len] = '\0';
  sym_num = i + 1;
  return i;
}

int yywrap()
{
  return 1;
}
