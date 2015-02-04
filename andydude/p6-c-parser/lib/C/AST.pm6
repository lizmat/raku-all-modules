use v6;
use C::AST::Ops;
module C::AST;

# Compound represents constants, expressions, and statements.
role Compound {}

# External represents declarations, and function definitions.
role External {}

# Operation represents compound structures.
role Operation {}

class Node {}

class Value is Node does Compound does External {}

class CharVal is Value {
    has Str $.value;
}
class IntVal is Value {
    has Int $.value;
}
class NumVal is Value {
    has Num $.value;
}
class StrVal is Value {
    has Str $.value;
}

class Specs is export is Node does External {
    has Spec @.children;
}

class Op is Node does Operation does Compound {
    has OpKind $.op;
    has Compound @.children;
}

class TypeOp is Node does Operation does Compound does External {
    has TyKind $.op;
    has External @.children;
}

class Size is Node does External {
    has Compound $.value;
}

class Name is Node does Compound does External {
    has Str $.name;
}

class Arg is Name {
    has External $.type;
}

class Init is Arg {
    has Compound $.value;
}

class Decl is Arg {
    has External @.children; # usually Init
}

class TransUnit is Node {
    has External @.children;
}
