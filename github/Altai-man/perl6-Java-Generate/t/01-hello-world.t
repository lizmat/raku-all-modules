use Java::Generate::Class;
use Java::Generate::Expression;
use Java::Generate::JavaMethod;
use Java::Generate::JavaParameter;
use Java::Generate::JavaSignature;
use Java::Generate::Literal;
use Java::Generate::Variable;
use Test;

plan 1;

my $signature = JavaSignature.new(
    parameters => JavaParameter.new('args', 'String[]')
);

my $out = StaticVariable.new(
    :name<out>,
    :type<PrintStream>,
    :access<public>,
    class => 'System'
);

my $statements = MethodCall.new(
    object => $out,
    :name<println>,
    arguments => StringLiteral.new(value => 'Hello, World')
);

my $hello-method = ClassMethod.new(
    :access<public>,
    :name<main>,
    :$signature, :$statements
    :return-type<void>,
    modifiers => 'static'
);

my $hello-class = Class.new(
    :access<public>,
    :name<HelloWorld>,
    methods => $hello-method
);

my $java = q:to/END/;
public class HelloWorld {

    public static void main(String[] args) {
        System.out.println("Hello, World");
    }

}
END

is $hello-class.generate, $java, 'Hello World is generated';
