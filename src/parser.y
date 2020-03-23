%{
#include <cstdio>
#include <cstring>
#include <iostream>
#include <string>
#include <vector>

#include "ast.hpp"

using std::cout;
using std::endl;

extern "C" int yylex();
extern "C" int yyparse();
/* Display error messages */
void yyerror(const char* s) { std::printf("ERROR: %s\n", s); }

void print(std::string s) { cout << s << endl; }

// Root node for the program
Block* program;
// Block id; used for comments in final output
long long bid = 0;
%}

/*** union of all possible data return types from grammar ***/
%union {
    Block* block;
    Expression* expr;
    Statement* stmt;
    Identifier* ident;
    VarDeclaration* var_decl;
    FuncParam* param_decl;
    ParamList* paramlist;
    ExprList* exprlist;
    std::string* string;
    int token;
}

/* Terminal tokens */
%token<string> IDENTIFIER INTEGER FLOAT BOOLEAN
%token<token> EQUALS ADD SUB MULT DIV DOT COMMA
%token<token> COMP_EQ COMP_NEQ COMP_LEQ COMP_GEQ COMP_LT COMP_GT
%token<token> LPAREN RPAREN LBRACE RBRACE SEMI ARROW COLON
%token<token> FN LET RETURN IF ELSE


/* Nonterminal types */
%type<ident> ident
%type<expr> literal expr binary_op_expr boolean_expr
%type<paramlist> func_decl_params
%type<exprlist> call_args
%type<block> program statements block
%type<stmt> statement var_decl func_decl param_decl return control_flow
%type<stmt> if_else block_or_if_else
%type<token> comparison

%right EQUALS
%left COMP_EQ COMP_NEQ
%left COMP_LEQ COMP_GEQ COMP_LT COMP_GT
%left ADD SUB
%left MULT DIV

%start program
%%

program
    : {
        program = new Block(bid++);
        program->set_outer();
    }
    | statements {
        program = $1;
        program->set_outer();
    }
    ;
statements
    : statement {
        $$ = new Block(bid++);
        $$->statements.push_back($<stmt>1);
    }
    | statements statement {
        $1->statements.push_back($<stmt>2);
    }
    ;
statement
    : var_decl
    | func_decl
    | return
    | control_flow
    | expr {
        $$ = new ExprStatement(*$1);
    }
    ;
block
    : LBRACE statements RBRACE {
        $$ = $2;
    }
    | LBRACE RBRACE {
        $$ = new Block(bid++);
    }
    ;
var_decl
    : ident COLON ident {
        $$ = new VarDeclaration(*$1, *$3);
    }
    | ident COLON ident EQUALS expr {
        $$ = new VarDeclaration(*$1, *$3, $5);
    }
    ;
func_decl
    : FN ident LPAREN func_decl_params RPAREN block {
        Identifier* type = new Identifier("void");
        $$ = new FuncDeclaration(*$2, *$4, *type, *$6);
        delete $4;
    }
    | FN ident LPAREN func_decl_params RPAREN ARROW ident block {
        $$ = new FuncDeclaration(*$2, *$4, *$7, *$8);
        delete $4;
    }
    ;
func_decl_params
    : /* blank */ {
        $$ = new ParamList();
    }
    | param_decl {
        $$ = new ParamList();
        $$->push_back($<param_decl>1);
    }
    | func_decl_params COMMA param_decl {
        $1->push_back($<param_decl>3);
    }
    ;
param_decl
    : ident COLON ident {
        $$ = new FuncParam(*$1, *$3);
    }
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
        delete $1;
    }
    ;
return
    : RETURN expr {
        $$ = new Return(*$2);
    }
    ;
control_flow
    : if_else
    ;
if_else
    : IF expr block {
        $$ = new Conditional(*$2, *$2);
    }
    | IF expr block ELSE block_or_if_else {
        $$ = new Conditional(*$2, *$2, $5);
    }
    ;
block_or_if_else
    : block
    | if_else
    ;
expr
    : ident EQUALS expr {
        $$ = new Assignment(*$<ident>1, *$3);
    }
    | ident LPAREN call_args RPAREN {
        $$ = new FuncCall(*$1, *$3);
        delete $3;
    }
    | ident {
        $<ident>$ = $1;
    }
    | binary_op_expr
    | boolean_expr
    | LPAREN expr RPAREN {
        $$ = $2;
    }
    | literal
    ;
binary_op_expr
    : expr ADD expr {
        $$ = new BinaryOp(*$1, $2, *$3); }
    | expr SUB expr {
        $$ = new BinaryOp(*$1, $2, *$3); }
    | expr MULT expr {
        $$ = new BinaryOp(*$1, $2, *$3);
    }
    | expr DIV expr {
        $$ = new BinaryOp(*$1, $2, *$3);
    }
    ;
boolean_expr
    : expr comparison expr {
        $$ = new CompOp(*$1, $2, *$3);
    }
    ;
call_args
    : /* blank */ {
        $$ = new ExprList();
    }
    | expr {
        $$ = new ExprList();
        $$->push_back($1);
    }
    | call_args COMMA expr {
        $1->push_back($3);
    }
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
    program->translate();
    Block main_block(bid++);
    FuncDeclaration main(
            Identifier("main"), ParamList(), Identifier("int"), main_block);
    main.translate();
    return 0;
}
