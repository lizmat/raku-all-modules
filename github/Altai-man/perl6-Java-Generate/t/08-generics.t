use Java::Generate::Class;
use Java::Generate::Expression;
use Java::Generate::JavaMethod;
use Java::Generate::JavaParameter;
use Java::Generate::JavaSignature;
use Java::Generate::Literal;
use Java::Generate::Statement;
use Java::Generate::Variable;
use Test;

plan 2;

my $code = "public class Box<T> \{\n\n\}\n";

my $class = Class.new(
    :access<public>,
    :name<Box>,
    :generic-types<T>
);

is $class.generate, $code, 'Generic class';

$code = q:to/END/;
public static <E> void printArray(E[] inputArray) {
    for (int i = 0; i < inputArray.length; i++) {
        System.out.printf("%s ", inputArray[i]);
    }
    System.out.println("Finish");
}
END

my $signature = JavaSignature.new(
    parameters => JavaParameter.new('inputArray', 'E[]')
);

my @statements = (
    For.new(
        initializer => VariableDeclaration.new('i', 'int', (), IntLiteral.new(:value<0>)),
        cond => InfixOp.new(
            left => LocalVariable.new(:name<i>),
            right => StaticVariable.new(
                class => 'inputArray',
                :name<length>
            ),
            op => '<'
        ),
        increment => PostfixOp.new(left => LocalVariable.new(:name<i>), :op<++>),
        body => MethodCall.new(
            object => StaticVariable.new(class => 'System', :name<out>),
            :name<printf>,
            arguments => [StringLiteral.new(value => "%s "),
                          Slice.new(array => LocalVariable.new(:name<inputArray>),
                                    index => LocalVariable.new(:name<i>))]
        ),
    ),
    MethodCall.new(
        object => StaticVariable.new(class => 'System', :name<out>),
        :name<println>,
        arguments => StringLiteral.new(:value<Finish>)
));

my $method = ClassMethod.new(
    :access<public>, :name<printArray>,
    :$signature, :@statements,
    :modifiers<static>, :return-type<void>,
    :generic-types<E>
);

is $method.generate, $code, 'Generic method';
