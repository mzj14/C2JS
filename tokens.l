D			[0-9]
L			[a-zA-Z_]

%{
//TODO: remove the unnecessary header file
#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <string>

#include "graph.hpp"
#include "parser.hpp"

using namespace std;

// print the matched text
#define ECHO fwrite(yytext, yyleng, 1, yyout);

// store matched identifier in sym vector, return the index in vector
int getIDIndex(char *);

// store matched string in str vector, return the index in vector
int getStrIndex(char *);

vector<string> sym;
vector<string> str;
%}

%%
"break"			                    { ECHO; return(BREAK); }
"char"			                    { ECHO; yylval.iType = charType; return(CHAR); }
"else"			                    { ECHO; return(ELSE); }
"if"			                    { ECHO; return(IF); }
"int"			                    { ECHO; yylval.iType = intType; return(INT); }
"return"		                    { ECHO; return(RETURN); }
"while"			                    { ECHO; return(WHILE); }
"printf"                            { ECHO; return(PRINTF); }
"gets"                              { ECHO; return(GETS); }
"strlen"                            { ECHO; return(STRLEN); }

{L}({L}|{D})*		                { ECHO; yylval.sIndex = getIDIndex(yytext); return(IDENTIFIER); }
{D}+		                        { ECHO; yylval.iValue = atoi(yytext); return(INTEGER); }
L?'(\\.|[^\\'])+'	                { ECHO; yylval.iChar = *yytext; return(CHARACTER); }
L?\"(\\.|[^\\"])*\"	                { ECHO; yylval.sIndex = getStrIndex(yytext); return(STRING); }

"&&"			                    { ECHO; return(AND_OP); }
"||"			                    { ECHO; return(OR_OP); }
"=="			                    { ECHO; return(EQ_OP); }
"!="			                    { ECHO; return(NE_OP); }
";"			                        { ECHO; return(';'); }
"{"		                            { ECHO; return('{'); }
"}"		                            { ECHO; return('}'); }
"="			                        { ECHO; return('='); }
"("			                        { ECHO; return('('); }
")"			                        { ECHO; return(')'); }
"["		                            { ECHO; return('['); }
"]"		                            { ECHO; return(']'); }
"-"			                        { ECHO; return('-'); }
"+"			                        { ECHO; return('+'); }
"<"			                        { ECHO; return('<'); }
">"			                        { ECHO; return('>'); }
","                                 { ECHO; return(','); }

[ \t\n\r\v\f]		                { ECHO; }

.			                        { ECHO; cout << "Unknown character" << endl; }

%%

int getStrIndex(char* text) {
    string textStr(text);

    str.push_back(textStr);

    return (int)str.size() - 1;
}

int getIDIndex(char* text) {
    int i = 0;
    string textStr(text);

    int sym_size = (int)sym.size();

    while (i < sym_size) {
        if (sym[i] != textStr) {
            i++;
        } else {
        return i;
        }
    }

    sym.push_back(textStr);

    return i;
}

int yywrap()
{
    return 1;
}
