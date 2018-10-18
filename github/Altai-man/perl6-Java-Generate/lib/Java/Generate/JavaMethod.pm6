use Java::Generate::Expression;
use Java::Generate::Variable;
use Java::Generate::Statement;
use Java::Generate::ASTNode;
use Java::Generate::JavaSignature;
use Java::Generate::Utils;

unit module Java::Generate::JavaMethod;

role JavaMethod does ASTNode is export {
    has JavaSignature $.signature;
    has Int $.indent = 4;
}

class InterfaceMethod does JavaMethod is export {
    has AccessLevel $.access;
    has Str $.name;
    has Str $.return-type;

    method generate(--> Str) {
        "{$!access} {$!return-type} {$!name}({$!signature.generate()});"
    }
}

class ConstructorMethod does JavaMethod is export {
    has Statement @.statements;

    method generate(:$name --> Str) {
        my $code = "{$name}({$!signature.generate()}) \{";
        $code ~= {@!statements.map(*.generate()).join.indent($!indent)} if @!statements;
        $code ~= "\}";
    }
}

class ClassMethod does JavaMethod is export {
    has AccessLevel $.access;
    has Modifier @.modifiers;
    has Statement @.statements;
    has Str @.generic-types;
    has Str $.name;
    has $.return-type;

    method generate(--> Str) {
        my $code = "{$!access}";
        $code ~= ' ' ~ @!modifiers.join(' ') if @!modifiers;
        $code ~= ' <' ~ @!generic-types.join(', ') ~ '>' if @!generic-types;
        $code ~= " {$!return-type} {$!name}({$!signature.generate()}) \{\n";
        my LocalVariable %locals = $!signature.parameters.map(
            {
                my $var = LocalVariable.new(name => .name, type => .type);
                $var.initialized = True;
                .name => $var
            }
        ).Hash;
        unless @!modifiers.contains("static") {
            %locals<this> = LocalVariable.new(:name<this>);
            %locals<this>.initialized = True;
        }
        self!check-locals(%locals, @!statements);
        $code ~= @!statements.map(
            {
                my $c = .generate();
                if $_ ~~ SelfTerminating {
                    $c
                } else {
                    $c.ends-with(';') ?? $c !! $c ~ ';'
                }
            }).join("\n").indent($!indent) if @!statements;
        $code ~= "\n\}\n";
    }

    method !check-locals(%locals is copy, @statements) {
        for @statements {
            # Population of scope
            if $_ ~~ VariableDeclaration {
                die "Variable {.variable.name} is already declared" if %locals{.variable.name};
                %locals{.variable.name} = .variable;
                %locals{.variable.name}.initialized = True if .variable.default;
            } elsif $_ ~~ Expression { # Scope usage
                if $_ ~~ Assignment {
                    %locals{.left.name}.initialized = True if .left ~~ LocalVariable;
                }
                for .operands {
                    die "Variable 「$_」 is not declared"     unless %locals{$_};
                    die "Variable 「$_」 is not initialized!" unless %locals{$_}.initialized;
                }
            } elsif $_ ~~ If {
                # Check both branches
                self!check-locals(%locals, .true);
                self!check-locals(%locals, .false);
                # We exited the scope
            } elsif $_ ~~ While {
                self!check-locals(%locals, .body);
            } elsif $_ ~~ Switch {
                for .branches -> $branch {
                    self!check-locals(%locals, $branch.value);
                }
            } elsif $_ ~~ For {
                self!check-locals(%locals, .body);
            } elsif $_ ~~ Try {
                self!check-locals(%locals, .try);
                for .catchers -> $catcher {
                    self!check-locals(%locals, .block);
                }
                self!check-locals(%locals, .finally);
            }
        }
    }
}
