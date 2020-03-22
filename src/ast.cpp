#include "ast.hpp"

#include <iostream>
#include <string>

#include "parser.hpp"

using std::cout;
using std::endl;
using std::string;


void Integer::translate() const
{
    cout << " " << value;
}

void Double::translate() const
{
    cout << " " << value;
}

void Boolean::translate() const
{
    string out(value ? "true" : "false");
    cout << " " << out;
}

void Identifier::translate() const
{
    cout << " " << name;
}

void FuncCall::translate() const
{
    id.translate();
    cout << "(";
    for (size_t i = 0; i < arguments.size(); ++i) {
        arguments[i]->translate();
        if (i < arguments.size() - 1) {
            cout << ", ";
        }
    }
    cout << ")";
}

void BinaryOp::translate() const
{
    lhs.translate();
    // TODO: get token;
    rhs.translate();
}

void CompOp::translate() const
{
    lhs.translate();
    // TODO: get token;
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
    cout << "{";
    for (size_t i = 0; i < statements.size(); ++i) {
        statements[i]->translate();
    }
    cout << "}";
    cout << endl;
}

void ExprStatement::translate() const
{
    expression.translate();
    cout << ";" << endl;
}

void VarDeclaration::translate() const
{
    type.translate();
    id.translate();
    cout << " = ";
    assignmentExpr->translate();
    cout << ";" << endl;
}

void FuncDeclaration::translate() const
{
    cout << endl;
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
