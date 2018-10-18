use Java::Generate::ASTNode;

class JavaParameter does ASTNode {
    has Str $.name;
    has Str $.type;

    method new($name, $type) {
        self.bless(:$name, :$type);
    }

    method generate(--> Str) {
        "{$!type} {$!name}"
    }
}
