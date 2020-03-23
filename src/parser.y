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
Block* ast_root = nullptr;
// Block id; used for comments in final output
long long bid = 0;
%}

/*** union of all possible data return types from grammar ***/
%union {
    Expression* expr;
    Statement* stmt;
    Block* block;
    Identifier* id;
    VarDeclaration* var_decl;
    FuncParam* param_decl;
    ParamList* paramlist;
    ExprList* exprlist;
    std::string* string;
    int token;
}

/* Terminal tokens */
%token<string> IDENTIFIER INTEGER FLOAT BOOLEAN
%token<token> EQUALS ADD SUB MULT DIV COMMA DOT_DOT
%token<token> COMP_EQ COMP_NEQ COMP_LEQ COMP_GEQ COMP_LT COMP_GT
%token<token> LPAREN RPAREN LBRACE RBRACE SEMI ARROW COLON
%token<token> FN LET RETURN IF ELSE WHILE FOR IN


/* Nonterminal types */
%type<id> id
%type<expr> literal expr binary_op_expr boolean_expr
%type<paramlist> func_decl_params
%type<exprlist> call_args
%type<block> program statements block
%type<stmt> statement var_decl func_decl param_decl return control_flow if_else
%type<stmt> while_loop for_loop
%type<token> comparison

%right EQUALS
%left COMP_EQ COMP_NEQ
%left COMP_LEQ COMP_GEQ COMP_LT COMP_GT
%left ADD SUB
%left MULT DIV

%start program
%%

program
    : /* blank */ {
        ast_root = new Block(bid++);
    }
    | statements {
        ast_root = $1;
    }
    ;
statements
    : statement {
        $$ = new Block(bid++);
        $$->statements.push_back($1);
    }
    | statements statement {
        $1->statements.push_back($2);
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
    : id COLON id {
        $$ = new VarDeclaration(*$1, *$3);
    }
    | id COLON id EQUALS expr {
        $$ = new VarDeclaration(*$1, *$3, $5);
    }
    ;
func_decl
    : FN id LPAREN func_decl_params RPAREN block {
        Identifier* type = new Identifier("void");
        $$ = new FuncDeclaration(*$2, *$4, *type, *$6);
        delete $4;
    }
    | FN id LPAREN func_decl_params RPAREN ARROW id block {
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
    : id COLON id {
        $$ = new FuncParam(*$1, *$3);
    }
    ;
id
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
    | while_loop
    | for_loop
    ;
if_else
    : IF expr block {
        $$ = new Conditional(*$2, *$3);
    }
    | IF expr block ELSE block {
        $$ = new Conditional(*$2, *$3, $5);
    }
    | IF expr block ELSE if_else {
        $$ = new Conditional(*$2, *$3, $5);
    }
    ;
while_loop
    : WHILE expr block {
        $$ = new WhileLoop(*$2, *$3);
    }
    ;
for_loop
    : FOR id IN LPAREN expr DOT_DOT expr RPAREN block {
        $$ = new ForLoop(*$2, *$5, *$7, *$9);
    }
    ;
expr
    : id EQUALS expr {
        $$ = new Assignment(*$1, *$3);
    }
    | id LPAREN call_args RPAREN {
        $$ = new FuncCall(*$1, *$3);
        delete $3;
    }
    | id {
        $$ = $1;
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

int main(int argc, char** argv)
{
    yyparse();
    if (ast_root != nullptr) {
        Program program(ast_root);
        program.validate();
        program.translate();
        return 0;
    }
}
