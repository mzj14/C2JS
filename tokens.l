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

// store matched character in chr vector, return the index in vector
int getChrIndex(char *);

vector<string> sym;
vector<string> str;
vector<string> chr;
%}

%%

#include([^\n])*                    { ECHO;  }
\/\*(\s|.)*?\*\/                    { ECHO; yylval.sIndex = getStrIndex(yytext); return(COMMENT); }
\/\/([^\n])*                        { ECHO; yylval.sIndex = getStrIndex(yytext); return(COMMENT); }
"break"			                    { ECHO; return(BREAK); }
"continue"                          { ECHO; return(CONTINUE); }
"char"			                    { ECHO; yylval.iType = charType; return(CHAR); }
"else"			                    { ECHO; return(ELSE); }
"if"			                    { ECHO; return(IF); }
"int"			                    { ECHO; yylval.iType = intType; return(INT); }
"double"                            { ECHO; yylval.iType = doubleType; return(DOUBLE); }
"return"		                    { ECHO; return(RETURN); }
"while"			                    { ECHO; return(WHILE); }
"printf"                            { ECHO; return(PRINTF); }
"gets"                              { ECHO; return(GETS); }
"strlen"                            { ECHO; return(STRLEN); }
"strcmp"                            { ECHO; return(STRCMP); }
"isdigit"                           { ECHO; return(ISDIGIT); }
"for"                               { ECHO; return(FOR); }

{L}({L}|{D})*		                { ECHO; yylval.sIndex = getIDIndex(yytext); return(IDENTIFIER); }
{D}+		                        { ECHO; yylval.iValue = atoi(yytext); return(INTEGER); }
'(\\.|[^\\'])+'	                    { ECHO; yylval.sIndex = getChrIndex(yytext); return(CHARACTER); }
\"(\\.|[^\\"])*\"	                { ECHO; yylval.sIndex = getStrIndex(yytext); return(STRING); }

{D}*"."{D}+                         { ECHO; yylval.dValue = atof(yytext); return(DOUBLE_NUM); }
{D}+"."{D}*                         { ECHO; yylval.dValue = atof(yytext); return(DOUBLE_NUM); }

"&&"			                    { ECHO; return(AND_OP); }
"||"			                    { ECHO; return(OR_OP); }
"!"                                 { ECHO; return(NOT_OP); }
"=="			                    { ECHO; return(EQ_OP); }
"!="			                    { ECHO; return(NE_OP); }
"++"			                    { ECHO; return(INC_OP); }
"--"			                    { ECHO; return(DEC_OP); }
">="                                { ECHO; return(GE_OP); }
"<="			                    { ECHO; return(LE_OP); }
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
"*"                                 { ECHO; return('*'); }
"/"                                 { ECHO; return('/'); }
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

int getChrIndex(char* text) {
    int i = 0;
    string textStr(text);

    int chr_size = (int)chr.size();

    while (i < chr_size) {
        if (chr[i] != textStr) {
            i++;
        } else {
        return i;
        }
    }

    chr.push_back(textStr);

    return i;
}

int yywrap()
{
    return 1;
}
