use Java::Generate::ASTNode;
use Java::Generate::Class;
use Java::Generate::Interface;

class CompUnit does ASTNode {
    my subset Unit where Class|Interface;

    has Str $.package;
    has Str @.imports;
    has Unit $.type;

    method generate(--> Str) {
        my $code = "package {$!package};\n";
        for @!imports {
            $code ~= "import $_;\n";
        }
        $code ~= "\n"~ $!type.generate;
    }
}
