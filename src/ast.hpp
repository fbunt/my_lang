#ifndef __AST_HPP__
#define __AST_HPP__

#include <iostream>
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
    const Identifier& id;
    ExprList arguments;
    FuncCall(const Identifier& id, ExprList& arguments) :
        id(id), arguments(arguments)
    {
    }
    FuncCall(const Identifier& id) : id(id) {}

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
    const Identifier& id;
    ParamList arguments;
    const Identifier& type;
    Block& block;
    FuncDeclaration(
            const Identifier& id,
            const ParamList& arguments,
            const Identifier& type,
            Block& block) :
        id(id), arguments(arguments), type(type), block(block)
    {
        block.set_parent(this);
    }

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
#endif  // __AST_HPP__
