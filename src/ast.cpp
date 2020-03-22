#include "ast.hpp"

#include <iostream>
#include <string>

#include "parser.hpp"

using std::cout;
using std::endl;
using std::string;

void ast_print(string s) { cout << s; }
void ast_println(string s) { cout << s << endl; }

void AstNode::translate() const { ast_println("Base AstNode"); }

void Integer::translate() const { cout << value; }

void Double::translate() const { cout << value; }

void Boolean::translate() const
{
    string out(value ? "true" : "false");
    cout << " " << out;
}

void Identifier::translate() const { cout << name; }

void FuncCall::translate() const
{
    id.translate();
    ast_print("(");
    for (size_t i = 0; i < arguments.size(); ++i) {
        arguments[i]->translate();
        if (i < arguments.size() - 1) {
            ast_print(", ");
        }
    }
    ast_print(")");
}

void BinaryOp::translate() const
{
    lhs.translate();
    switch (op) {
    case ADD:
        ast_print(" + ");
        break;
    case SUB:
        ast_print(" - ");
        break;
    case MULT:
        ast_print(" * ");
        break;
    case DIV:
        ast_print(" / ");
        break;
    default:
        ast_print("Unknown binary op ");
    }
    rhs.translate();
}

void CompOp::translate() const
{
    lhs.translate();
    switch (op) {
    case COMP_EQ:
        ast_print(" == ");
        break;
    case COMP_NEQ:
        ast_print(" != ");
        break;
    case COMP_LEQ:
        ast_print(" <= ");
        break;
    case COMP_GEQ:
        ast_print(" >= ");
        break;
    case COMP_LT:
        ast_print(" < ");
        break;
    case COMP_GT:
        ast_print(" > ");
        break;
    default:
        ast_print("Unknown comparison op ");
    }
    rhs.translate();
}

void Assignment::translate() const
{
    lhs.translate();
    cout << " = ";
    rhs.translate();
}

void Block::translate() const
{
    cout << endl;
    ast_print("{");
    if (parent == NULL) {
        cout << " // end: " << id;
    }
    cout << endl;
    for (size_t i = 0; i < statements.size(); ++i) {
        statements[i]->translate();
    }
    ast_print("}");
    if (parent == NULL) {
        cout << " // end: " << id << endl;
    } else {
        cout << " // end: " << parent->id.name << endl;
    }
}

void ExprStatement::translate() const
{
    expression.translate();
    cout << ";" << endl;
}

void VarDeclaration::translate() const
{
    type.translate();
    ast_print(" ");
    id.translate();
    cout << " = ";
    assignmentExpr->translate();
    cout << ";" << endl;
}

void FuncParam::translate() const
{
    type.translate();
    ast_print(" ");
    id.translate();
}

void FuncDeclaration::translate() const
{
    type.translate();
    cout << " ";
    id.translate();
    cout << "(";
    for (size_t i = 0; i < arguments.size(); ++i) {
        arguments[i]->translate();
        if (i < arguments.size() - 1) {
            cout << ", ";
        }
    }
    cout << ")";
    block.translate();
}

void Return::translate() const
{
    ast_print("return");
    expr.translate();
    ast_println(";");
}
