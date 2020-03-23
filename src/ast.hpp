#ifndef __AST_HPP__
#define __AST_HPP__

#include <iostream>
#include <unordered_set>
#include <vector>

class Statement;
class Expression;
class VarDeclaration;
class FuncParam;

typedef std::vector<Statement*> StatementList;
typedef std::vector<Expression*> ExprList;
typedef std::vector<FuncParam*> ParamList;

class AstNode
{
public:
    virtual ~AstNode() {}

    virtual void translate() const;
};

class Statement : public AstNode
{
};

class Expression : public Statement
{
};

class Integer : public Expression
{
public:
    long long value;

    Integer(long long value) : value(value) {}

    void translate() const;
};

class Double : public Expression
{
public:
    double value;

    Double(double value) : value(value) {}

    void translate() const;
};

class Boolean : public Expression
{
public:
    bool value;

    Boolean(bool value) : value(value) {}

    void translate() const;
};

class Identifier : public Expression
{
public:
    std::string name;

    Identifier(const std::string& name) : name(name) {}

    void translate() const;
};

class FuncCall : public Expression
{
public:
    Identifier& id;
    ExprList arguments;

    FuncCall(Identifier& id, ExprList& arguments);
    FuncCall(Identifier& id);

    void translate() const;
};

class BinaryOp : public Expression
{
public:
    Expression& lhs;
    Expression& rhs;
    int op;

    BinaryOp(Expression& lhs, int op, Expression& rhs) :
        lhs(lhs), rhs(rhs), op(op)
    {
    }

    void translate() const;
};

class CompOp : public Expression
{
public:
    Expression& lhs;
    Expression& rhs;
    int op;

    CompOp(Expression& lhs, int op, Expression& rhs) :
        lhs(lhs), rhs(rhs), op(op)
    {
    }

    void translate() const;
};

class Assignment : public Expression
{
public:
    Identifier& lhs;
    Expression& rhs;

    Assignment(Identifier& lhs, Expression& rhs) : lhs(lhs), rhs(rhs) {}

    void translate() const;
};

class FuncDeclaration;

class Block : public Expression
{
public:
    StatementList statements;
    FuncDeclaration* parent = nullptr;
    bool is_outer = false;
    long long id;

    Block(long long id) : id(id) {}

    void set_parent(FuncDeclaration* parent) { this->parent = parent; }
    void set_outer() { is_outer = true; }
    void translate() const;
};

class ExprStatement : public Statement
{
public:
    Expression& expression;

    ExprStatement(Expression& expression) : expression(expression) {}

    void translate() const;
};

class VarDeclaration : public Statement
{
public:
    Identifier& id;
    const Identifier& type;
    Expression* assignmentExpr;

    VarDeclaration(
            Identifier& id,
            const Identifier& type,
            Expression* assignmentExpr = nullptr) :
        id(id), type(type), assignmentExpr(assignmentExpr)
    {
    }
    void set_assignment_expr(Expression* expr) { assignmentExpr = expr; }

    void translate() const;
};

class FuncParam : public Statement
{
public:
    Identifier& id;
    const Identifier& type;

    FuncParam(Identifier& id, const Identifier& type) : id(id), type(type) {}

    void translate() const;
};

class FuncDeclaration : public Statement
{
public:
    Identifier& id;
    ParamList arguments;
    const Identifier& type;
    Block& block;

    FuncDeclaration(
            Identifier& id,
            const ParamList& arguments,
            const Identifier& type,
            Block& block);

    void translate() const;
};

class Return : public Statement
{
public:
    Expression& expr;
    Return(Expression& expr) : expr(expr) {}

    void translate() const;
};

class Conditional : public Statement
{
public:
    Expression& condition;
    Statement& block;
    Statement* else_block;

    Conditional(
            Expression& condition,
            Statement& block,
            Statement* else_block = nullptr) :
        condition(condition), block(block), else_block(else_block)
    {
    }

    void translate() const;
};

class WhileLoop : public Statement
{
public:
    Expression& condition;
    Block& block;

    WhileLoop(Expression& condition, Block& block) :
        condition(condition), block(block)
    {
    }

    void translate() const;
};

class ForLoop : public Statement
{
public:
    const Identifier& loop_var;
    Expression& start;
    Expression& end;
    Block& block;

    ForLoop(const Identifier& loop_var,
            Expression& start,
            Expression& end,
            Block& block) :
        loop_var(loop_var), start(start), end(end), block(block)
    {
    }

    void translate() const;
};

class Program
{
public:
    static std::unordered_set<std::string> func_name_set;
    Block* ast;

    Program(Block* ast) : ast(ast) { ast->set_outer(); }

    void validate() const;
    void translate() const;

private:
    void declare_imports() const;
    void declare_builtin_funcs() const;
};
#endif  // __AST_HPP__
