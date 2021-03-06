#include "ast.hpp"

#include <cstdlib>
#include <iostream>
#include <string>

#include "parser.hpp"

using std::cerr;
using std::cout;
using std::endl;
using std::string;

void ast_print(string s) { cout << s; }
void ast_println(string s) { cout << s << endl; }

/** Avoid collisions with C++ names */
void mangle_func_name(string& name)
{
    if (name == "main") {
        name.append("__func__");
    }
}

Identifier& mangle_func_id(Identifier& id)
{
    mangle_func_name(id.name);
    return id;
}

void AstNode::translate() const { ast_println("Base AstNode"); }

void Integer::translate() const { cout << value; }

void Double::translate() const { cout << value; }

void Boolean::translate() const
{
    string out(value ? "true" : "false");
    cout << " " << out;
}

void Identifier::translate() const { cout << name; }

FuncCall::FuncCall(Identifier& id, ExprList& arguments) :
    id(mangle_func_id(id)), arguments(arguments)
{
}

FuncCall::FuncCall(Identifier& id) : id(mangle_func_id(id)) {}

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
    // Only print braces if not outer most block
    if (!is_outer) {
        ast_print("{");
        if (parent == NULL) {
            cout << " // start: " << id;
        }
    }
    cout << endl;

    for (size_t i = 0; i < statements.size(); ++i) {
        statements[i]->translate();
    }

    // Only print braces if not outer most block
    if (!is_outer) {
        ast_print("}");
        if (parent == nullptr) {
            cout << " // end: " << id;
        } else {
            cout << " // end: " << parent->id.name;
        }
    }
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

std::unordered_set<std::string> Program::func_name_set;

FuncDeclaration::FuncDeclaration(
        Identifier& id,
        const ParamList& arguments,
        const Identifier& type,
        Block& block) :
    id(mangle_func_id(id)), arguments(arguments), type(type), block(block)
{
    if (Program::func_name_set.count(id.name) > 0) {
        cerr << "ERROR: Redefinition of function: " << id.name << endl;
        std::exit(1);
    }
    Program::func_name_set.insert(id.name);
    block.set_parent(this);
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
    cout << endl;
}

void Return::translate() const
{
    ast_print("return ");
    expr.translate();
    ast_println(";");
}

void Conditional::translate() const
{
    cout << endl;
    ast_print("if (");
    condition.translate();
    ast_print(")");
    block.translate();
    if (else_block != nullptr) {
        ast_print("else");
        else_block->translate();
    }
}

void WhileLoop::translate() const
{
    ast_print("while (");
    condition.translate();
    ast_print(")");
    block.translate();
}

void ForLoop::translate() const
{
    cout << "for (long long ";
    loop_var.translate();
    cout << " = ";
    start.translate();
    cout << "; ";
    loop_var.translate();
    cout << " < ";
    end.translate();
    cout << "; ++";
    loop_var.translate();
    ast_print(")");
    block.translate();
}

void Program::validate() const
{
    // TODO: walk AST and enforce sturcture
    string main("main");
    mangle_func_name(main);
    if (Program::func_name_set.count(main) == 0) {
        cerr << "ERROR: no main function definition found" << endl;
        std::exit(1);
    }
}

void Program::declare_imports() const
{
    ast_println("#include <iostream>");
    cout << endl;
}

void Program::declare_builtin_funcs() const
{
    string func_printi = "printi";
    string func_printd = "printd";
    mangle_func_name(func_printi);
    mangle_func_name(func_printd);

    // printi(long long)
    cout << "void " << func_printi << "(long long arg) {" << endl;
    ast_println("std::cout << arg << std::endl;");
    ast_println("}");
    cout << endl;
    // printd(double)
    cout << "void " << func_printd << "(double arg) {" << endl;
    ast_println("std::cout << arg << std::endl;");
    ast_println("}");
}

void Program::translate() const
{
    declare_imports();
    declare_builtin_funcs();

    ast->translate();
    ast_println("int main(int argc, char** argv) {");
    string main_str("main");
    mangle_func_name(main_str);
    Identifier main_id(main_str);
    ExprList exprs;
    FuncCall(main_id, exprs).translate();
    ast_println(";");
    ast_println("return 0;");
    ast_println("}");
}
