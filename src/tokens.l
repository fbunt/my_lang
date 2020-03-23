D    [0-9]
NZ   [1-9]
H    [a-fA-F0-9]
HP   (0[xX])
A    [a-zA-Z_]
AN   [a-zA-Z_0-9]
E    ([Ee][+-]?{D}+)

%{
#include <iostream>
#include <string>
#include "ast.hpp"
#include "parser.hpp"

#define SAVE_TOKEN yylval.string = new std::string(yytext, yyleng)
#define TOKEN(t) (yylval.token = t)

extern "C" int yylex();

%}

/***
"^"                { return TOKEN(EXP); }
***/

%option stack

%x line_comment
%x block_comment

%%

[ \t\n]            ;

"//"                   { yy_push_state(line_comment); }
<line_comment>\n       { yy_pop_state(); }
<line_comment>.*       ;

"/*"                   { yy_push_state(block_comment); }
<block_comment>"/*"    { yy_push_state(block_comment); }
<block_comment>"*/"    { yy_pop_state(); }
<block_comment>(.|\n)  ;

"fn"               { return TOKEN(FN); }
"return"           { return TOKEN(RETURN); }
"if"               { return TOKEN(IF); }
"else"             { return TOKEN(ELSE); }
"while"            { return TOKEN(WHILE); }

"true"             { SAVE_TOKEN; return BOOLEAN; }
"false"            { SAVE_TOKEN; return BOOLEAN; }

[+-]?{HP}{H}+           { SAVE_TOKEN; return INTEGER; }
[+-]?{NZ}{D}*           { SAVE_TOKEN; return INTEGER; }

[+-]?{D}+{E}?           { SAVE_TOKEN; return FLOAT; }
[+-]?{D}*"."{D}+{E}?    { SAVE_TOKEN; return FLOAT; }
[+-]?{D}+"."{E}?        { SAVE_TOKEN; return FLOAT; }

{A}{AN}*           { SAVE_TOKEN; return IDENTIFIER; }

"="                { return TOKEN(EQUALS); }
"+"                { return TOKEN(ADD); }
"-"                { return TOKEN(SUB); }
"*"                { return TOKEN(MULT); }
"/"                { return TOKEN(DIV); }

"=="               { return TOKEN(COMP_EQ); }
"!="               { return TOKEN(COMP_NEQ); }
"<="               { return TOKEN(COMP_LEQ); }
">="               { return TOKEN(COMP_GEQ); }
"<"                { return TOKEN(COMP_LT); }
">"                { return TOKEN(COMP_GT); }

"->"               { return TOKEN(ARROW); }
"("                { return TOKEN(LPAREN); }
")"                { return TOKEN(RPAREN); }
"{"                { return TOKEN(LBRACE); }
"}"                { return TOKEN(RBRACE); }
"."                { return TOKEN(DOT); }
","                { return TOKEN(COMMA); }
";"                { return TOKEN(SEMI); }
":"                { return TOKEN(COLON); }
.                  { std::cout << "Unknown token" << std::endl; yyterminate(); }


%%
