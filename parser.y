%{
#include <cstdio>
#include <cstring>
#include <iostream>
#include <string>
#include <vector>

#include "ast.hpp"

extern "C" int yylex();
extern "C" int yyparse();
/* Display error messages */
void yyerror(const char* s) { std::printf("ERROR: %s\n", s); }

#define YYERROR_VERBOSE
#define YYDEBUG 1

// Root node for the program
Block* program;
%}

/*** union of all possible data return types from grammar ***/
%union {
    Block* block;
    Expression* expr;
    Statement* stmt;
    Identifier* ident;
    VarDeclaration* var_decl;
    VarList* varlist;
    ExprList* exprlist;
    std::string* string;
    int token;
}

/* Terminal tokens */
%token<string> IDENTIFIER INTEGER FLOAT BOOLEAN
%token<token> EQUALS ADD SUB MULT DIV DOT COMMA
%token<token> COMP_EQ COMP_NEQ COMP_LEQ COMP_GEQ COMP_LT COMP_GT
%token<token> LPAREN RPAREN LBRACE RBRACE SEMI ARROW
%token<token> FN


/* Nonterminal types */
%type<ident> ident
%type<expr> literal expr binary_op_expr boolean_expr
%type<varlist> func_decl_args
%type<exprlist> call_args
%type<block> program statements block
%type<stmt> statement var_decl_full var_decl func_decl 
%type<token> comparison

%left ADD SUB
%left MULT DIV
%left COMP_EQ COMP_NEQ COMP_LEQ COMP_GEQ COMP_LT COMP_GT

%start program
%%

program
    : { program = new Block(); }
    | statements { program = $1; }
    ;
statements
    : statement {
        $$ = new Block();
        $$->statements.push_back($<stmt>1);
    }
    | statements statement { $1->statements.push_back($<stmt>2); }
    ;
statement
    : var_decl_full
    | func_decl
    | expr { $$ = new ExprStatement(*$1); }
    ;
block
    : LBRACE statements RBRACE { $$ = $2; }
    | LBRACE RBRACE { $$ = new Block(); }
    ;
var_decl_full
    : var_decl SEMI { /* Already handled */ }
    | var_decl EQUALS expr SEMI {
        static_cast<VarDeclaration*>($$)->set_assignment_expr($3);
    }
    ;
var_decl
    : ident ident { $$ = new VarDeclaration(*$1, *$2); }
    ;
func_decl
    : FN ident LPAREN func_decl_args RPAREN ARROW ident block {
        $$ = new FuncDeclaration(*$2, *$4, *$7, *$8);
        delete $4;
    }
    ;
func_decl_args
    : /* blank */ { $$ = new VarList(); }
    | var_decl {
        $$ = new VarList();
        $$->push_back($<var_decl>1);
    }
    | func_decl_args COMMA var_decl { $1->push_back($<var_decl>3); }
    ;
ident
    : IDENTIFIER {
        $$ = new Identifier(*$1);
        delete $1;
    }
    ;
literal
    : INTEGER {
        $$ = new Integer(std::stol(*$1));
        delete $1;
    }
    | FLOAT {
        $$ = new Double(std::stod(*$1));
        delete $1;
    }
    | BOOLEAN {
        $$ = new Boolean(*$1 == "true" ? true : false);
    }
    ;
expr
    : ident EQUALS expr { $$ = new Assignment(*$<ident>1, *$3); }
    | ident LPAREN call_args RPAREN {
        $$ = new FuncCall(*$1, *$3);
        delete $3;
    }
    | ident { $<ident>$ = $1; }
    | binary_op_expr
    | boolean_expr
    | LPAREN expr RPAREN { $$ = $2; }
    | literal
    ;
binary_op_expr
    : expr ADD expr { $$ = new BinaryOp(*$1, $2, *$3); }
    | expr SUB expr { $$ = new BinaryOp(*$1, $2, *$3); }
    | expr MULT expr { $$ = new BinaryOp(*$1, $2, *$3); }
    | expr DIV expr { $$ = new BinaryOp(*$1, $2, *$3); }
    ;
boolean_expr
    : expr comparison expr { $$ = new CompOp(*$1, $2, *$3); }
    ;
call_args
    : /* blank */ { $$ = new ExprList(); }
    | expr {
        $$ = new ExprList();
        $$->push_back($1);
    }
    | call_args COMMA expr { $1->push_back($3); }
    ;
comparison
    : COMP_EQ
    | COMP_NEQ
    | COMP_LEQ
    | COMP_GEQ
    | COMP_LT
    | COMP_GT
    ;

%%

int main(int argc, char **argv)
{
	yyparse();
    return 0;
}
