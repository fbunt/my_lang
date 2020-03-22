#ifndef __AST_HPP__
#define __AST_HPP__

#include <iostream>
#include <vector>

class Statement;
class Expression;
class VarDeclaration;

typedef std::vector<Statement*> StatementList;
typedef std::vector<Expression*> ExprList;
typedef std::vector<VarDeclaration*> VarList;

class AstNode
{
public:
    virtual ~AstNode() {}
    
    virtual void translate() {};
};

class Expression : public AstNode
{
};

class Statement : public AstNode
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

class Block : public Expression
{
public:
    StatementList statements;
    Block() {}
    
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
    const Identifier& type;
    Identifier& id;
    Expression* assignmentExpr;
    VarDeclaration(Identifier& id, const Identifier& type) : id(id), type(type)
    {
    }
    VarDeclaration(
            Identifier& id,
            const Identifier& type,
            Expression* assignmentExpr) :
        type(type), id(id), assignmentExpr(assignmentExpr)
    {
    }
    void set_assignment_expr(Expression* expr) { assignmentExpr = expr; }
    
    void translate() const;
};

class FuncDeclaration : public Statement
{
public:
    const Identifier& type;
    const Identifier& id;
    VarList arguments;
    Block& block;
    FuncDeclaration(
            const Identifier& id,
            const VarList& arguments,
            const Identifier& type,
            Block& block) :
        type(type), id(id), arguments(arguments), block(block)
    {
    }
    
    void translate() const;
};
#endif // __AST_HPP__
