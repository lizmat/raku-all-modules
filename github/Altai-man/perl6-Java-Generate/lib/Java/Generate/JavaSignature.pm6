use Java::Generate::ASTNode;
use Java::Generate::JavaParameter;

class JavaSignature does ASTNode {
    has JavaParameter @.parameters;

    method generate(--> Str) {
        @!parameters.map(*.generate).join(', ');
    }
}
