use Java::Generate::Argument;
use Java::Generate::Literal;
use Java::Generate::Statement;
use Java::Generate::Variable;
use Java::Generate::Utils;

unit module Java::Generate::Expression;

class ConstructorCall does Java::Generate::Statement::Expression is export {
    has Str $.name;
    has Argument @.arguments;

    method generate(--> Str) {
        "new {$!name}({@!arguments.map({$_ ~~ Variable ?? .reference !! .generate}).join(', ')})";
    }
}

class MethodCall does Java::Generate::Statement::Expression is export {
    has Variable $.object;
    has Str $.name;
    has Argument @.arguments;

    method generate(--> Str) {
        my @args = @!arguments.map({ $_ ~~ Literal ?? .generate !! .reference }).join(', ');
        "{$!object.reference()}.{$!name}({@args})";
    }

    method operands() {
        $!object ~~ LocalVariable ?? ($!object.name) !! ()
    }
}

my subset Operand where Variable|Literal|Java::Generate::Statement::Expression;

class PrefixOp does Java::Generate::Statement::Expression is export {
    my constant %known-ops := set '++', '--', '+', '-', '~', '!';
    my subset Op of Str where %known-ops{$_}:exists;
    has Operand $.right;
    has Op $.op;

    method generate() {
        my $right = $_ ~~ Variable ?? .reference() !! .generate() given $!right;
        $right = "($right)" if $!right !~~ Variable|Literal;
        "{$!op}$right"
    }

    method operands() {
        return ($!right.name) if $!right ~~ LocalVariable;
        return $!right.operands if $!right ~~ Expression;
        ()
    }
}

class Slice does Java::Generate::Statement::Expression is export {
    has Variable $.array;
    has Operand $.index;

    method generate {
        my $index = $_ ~~ Variable ?? .reference() !! .generate() given $!index;
        "{$!array.reference()}[$index]"
    }
}

class PostfixOp does Java::Generate::Statement::Expression is export {
    my constant %known-ops := set '++', '--';
    my subset Op of Str where %known-ops{$_}:exists;
    has Operand $.left;
    has Op $.op;

    method generate() {
        my $left = $_ ~~ Variable ?? .reference() !! .generate() given $!left;
        $left = "($left)" if $!left !~~ Variable|Literal;
        "{$left}{$!op}"
    }

    method operands() {
        return ($!left.name) if $!left ~~ LocalVariable;
        return $!left.operands if $!left ~~ Expression;
        ()
    }
}

class Assignment does Java::Generate::Statement::Expression is export {
    has Variable $.left;
    has Operand $.right;

    method generate(--> Str) {
        my $right = $_ ~~ Variable ?? .reference() !! .generate() given $!right;
        "{$!left.reference()} = $right"
    }

    method operands() {
        my @right = ($!right.name) if $!right ~~ LocalVariable;
        @right.append: $!right.operands if $!right ~~ Expression;
        my @operands;
        @operands.append: $!left.name if $!left ~~ LocalVariable;
        @operands.append: @right;
    }
}

class InfixOp does Java::Generate::Statement::Expression is export {
    my constant %known-ops := set '+', '-', '*', '/', '%',
                              '<<', '>>','>>>',
                              '&', '^', '|',
                              '<=', '>=', '<', '>', '==', '!=', '&&', '||';
    my subset Op of Str where %known-ops{$_}:exists;

    has Operand $.left;
    has Operand $.right;
    has Op $.op;

    method generate(--> Str) {
        my $left  = $_ ~~ Variable ?? .reference() !! .generate() given $!left;
        my $right = $_ ~~ Variable ?? .reference() !! .generate() given $!right;
        $left  = "($left)"  if $!left  !~~ Variable|Literal;
        $right = "($right)" if $!right !~~ Variable|Literal;
        "$left {$!op} $right"
    }

    method operands() {
        my @operands;
        for ($!left, $!right) {
            @operands.append: .name     if $_ ~~ LocalVariable;
            @operands.append: .operands if $_ ~~ Expression;
        }
        @operands.flat
    }
}

class Ternary does Java::Generate::Statement::Expression is export {
    has InfixOp $.cond;
    has Operand $.true;
    has Operand $.false;

    method generate(--> Str) {
        unless %boolean-ops{$!cond.op}:exists {
            die "Ternary operator conditional expression is not boolean, its operator is {$!cond.op}";
        }

        my $true  = $_ ~~ Variable ?? .reference() !! .generate() given $!true;
        my $false = $_ ~~ Variable ?? .reference() !! .generate() given $!false;
        "{$!cond.generate} ? $true : $false"
    }

    method operands() {
        my @operands;
        for ($!true, $!false) {
            @operands.append: .name     if $_ ~~ LocalVariable;
            @operands.append: .operands if $_ ~~ Expression;
        }
        @operands.flat
    }
}

