use Java::Generate::ASTNode;
use Java::Generate::Argument;
use Java::Generate::JavaParameter;
use Java::Generate::Utils;

unit module Java::Generate::Statement;

role Statement does ASTNode is export {}

role Expression does Statement does Argument is export {
    method operands() {()}
    method reference() {self.generate}
}

role Variable does Expression does Argument is export {
    has Expression $.default;
    has $.initialized is rw = True;
    has $.name;
    has $.type;
    has Modifier @.modifiers;

    method reference(--> Str) { "{$!name}" }
}

role Literal does Expression is export {}

class LocalVariable does Variable is export {
    submethod TWEAK() { $!initialized = False unless $!default }

    method generate() {
        my $code = @!modifiers.join(', ') ~ ' ' if @!modifiers;
        $code ~= "{$!type} {$!name}";
        $code ~= $!default ?? " = {$!default.generate};" !! ";"
    }
}

class VariableDeclaration does Statement is export {
    has LocalVariable $.variable;

    multi method new($variable) {
        self.bless(:$variable)
    }
    multi method new($name, $type, @modifiers) {
        self.bless(variable => LocalVariable.new(:$name, :$type, :@modifiers));
    }
    multi method new($name, $type, @modifiers, $default) {
        self.bless(variable => LocalVariable.new(:$name, :$type, :@modifiers, :$default));
    }

    method generate(--> Str) {
        $!variable.generate();
    }
}

class Return does Statement is export {
    has Expression $.return;

    method generate(--> Str) {
        "return {$_ ~~ Variable ?? .reference !! .generate given $!return}"
    }
}

role Flow does Statement is export {
    has Int $.indent = 4;

    method !get-indent() { $!indent }
}

role SelfTerminating does Flow is export {
    method !generate-block(@lines) {
        my $line;
        for @lines {
            $line ~= .generate;
            $line ~= $_ ~~ SelfTerminating ?? "\n" !! ";\n";
        }
        $line.indent(self!get-indent);
    }
}

class If does SelfTerminating is export {
    has Expression $.cond;
    has Statement @.true;
    has Statement @.false;

    method generate(--> Str) {
        my $code = "if ({$!cond.generate}) \{\n{self!generate-block(@!true)}\}";
        $code ~= " else \{\n{self!generate-block(@!false)}\}" if @!false;
        $code;
    }
}

class While does SelfTerminating is export {
    has Expression $.cond;
    has Statement @.body;
    has Bool $.after;

    method generate(--> Str) {
        my $condition = "while ({$!cond.generate})";
        my $statements = " \{\n{self!generate-block(@!body)}\}";
        $!after ?? "do$statements $condition;" !! "{$condition}{$statements}";
    }
}

class Throw does Flow is export {
    has Str $.exception;

    method generate(--> Str) {
        "throw new {$!exception}()";
    }
}

class Continue does Flow is export {
    method generate(--> Str) { 'continue' }
}

class Break does Flow is export {
    method generate(--> Str) { 'break' }
}

class Switch does SelfTerminating is export {
    has Variable $.switch;
    has Pair @.branches;
    has Statement @.default;

    method generate(--> Str) {
        my $code = "switch ({$!switch.reference}) \{\n";
        for @!branches {
            $code ~= "case {$_.key.generate}:\n";
            $code ~= self!do-branch(.value) if .value;
        }
        with @!default {
            if @!default {
                $code ~= "default:\n";
                $code ~= self!do-branch($_);
            }
        }
        $code ~ '}';
    }

    method !do-branch($_) {
        my $line = self!generate-block(@$_);
        $line ~= ' ' x self!get-indent() ~ "break;" unless $_[*-1] ~~ Return|Throw|Continue;
        "$line\n";
    }
}

class For does SelfTerminating is export {
    has Statement $.initializer;
    has Expression $.cond;
    has Statement $.increment;
    has Statement @.body;

    method generate(--> Str) {
        my $initializer = $!initializer.generate() ~ ($!initializer ~~ VariableDeclaration ?? '' !! ';');
        my $block = self!generate-block(@!body);
        "for ({$initializer} {$!cond.generate}; {$!increment.generate}) \{\n$block\}";
    }
}

class CatchBlock is export {
    has JavaParameter $.exception;
    has Statement @.block;
}

class Try does SelfTerminating is export {
    has Statement @.try;
    has CatchBlock @.catchers;
    has Statement @.finally;

    method generate(--> Str) {
        my $code = "try \{\n{self!generate-block(@!try)}\}";
        for @!catchers {
            $code ~= " catch ({.exception.generate}) \{\n{self!generate-block(.block)}}";
        }
        if @!finally {
            $code ~= " finally \{\n{self!generate-block(@!finally)}\}";
        }
        $code;
    }
}
