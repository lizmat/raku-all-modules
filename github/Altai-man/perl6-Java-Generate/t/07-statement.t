use Java::Generate::Class;
use Java::Generate::Expression;
use Java::Generate::JavaMethod;
use Java::Generate::JavaSignature;
use Java::Generate::JavaParameter;
use Java::Generate::Literal;
use Java::Generate::Statement;
use Java::Generate::Variable;
use Test;

plan 12;

sub generates(@statements, $result, $desc) {
    is @statements.map(*.generate).join('\n'), $result, $desc;
}

my $code = "if (1 > 0) \{\n    return true;\n\}";

generates([If.new(
    cond => InfixOp.new(left => IntLiteral.new(value => 1), right => IntLiteral.new(value => 0), op => '>'),
    true => Return.new(return => BooleanLiteral.new(:value)))],
          $code, 'Single if-conditional');

$code = "if (1 > 0) \{\n    return true;\n\} else \{\n    return false;\n\}";

generates([If.new(
    cond => InfixOp.new(left => IntLiteral.new(value => 1), right => IntLiteral.new(value => 0), op => '>'),
    true => Return.new(return => BooleanLiteral.new(:value)),
    false => Return.new(return => BooleanLiteral.new(:!value)))],
          $code, 'if-else conditional');

$code = "while (true) \{\n    0 + 1;\n    return 1;\n\}";

generates([While.new(
    cond => BooleanLiteral.new(:value),
    body => [InfixOp.new(left => IntLiteral.new(value => 0), right => IntLiteral.new(value => 1), op => '+'),
             Return.new(return => IntLiteral.new(value => 1))])],
          $code, 'while statement');

$code = "do \{\n    0 + 1;\n    return 1;\n\} while (true);";

generates([While.new(:after,
                     cond => BooleanLiteral.new(:value),
                     body => [InfixOp.new(
                                     left => IntLiteral.new(value => 0),
                                     right => IntLiteral.new(value => 1),
                                     op => '+'),
                              Return.new(return => IntLiteral.new(value => 1))
                             ]
                    )
          ],
          $code, 'do-while statement');

$code = q/switch (month) {
case 1:
    monthValue = "January";
    break;
case 2:
    monthValue = "February";
    break;
default:
    monthValue = "";
    break;
}/;

generates([Switch.new(
                  switch => LocalVariable.new(:name<month>, :type<int>),
                  branches => [IntLiteral.new(value => 1) => Assignment.new(
                                      left => LocalVariable.new(:name<monthValue>, :type<string>),
                                      right => StringLiteral.new(:value<January>)),
                               IntLiteral.new(value => 2) => Assignment.new(
                                      left => LocalVariable.new(:name<monthValue>, :type<string>),
                                      right => StringLiteral.new(:value<February>)),
                             ],
                  default => Assignment.new(
                      left => LocalVariable.new(:name<monthValue>, :type<string>),
                      right => StringLiteral.new(value => "")
                    ))
          ],
          $code, 'switch-case statement');

$code = "while (true) \{\n    if (1 >= 0) \{\n        break;\n    \}\n\}";

generates([While.new(
    cond => BooleanLiteral.new(:value),
    body => [
             If.new(
                 cond => InfixOp.new(
                     left => IntLiteral.new(value => 1),
                     right => IntLiteral.new(value => 0),
                     op => '>='),
                 true => Break.new)
         ])],
          $code, 'while statement + break');

$code = "while (true) \{\n    if (0 >= 1) \{\n        continue;\n    \}\n\}";

generates([While.new(
    cond => BooleanLiteral.new(:value),
    body => [
             If.new(
                 cond => InfixOp.new(
                     left  => IntLiteral.new(value => 0),
                     right => IntLiteral.new(value => 1),
                     op => '>='),
                 true => Continue.new)])],
          $code, 'while statement + continue');

$code = "throw new EmptyStackException()";
generates([Throw.new(exception => 'EmptyStackException')], $code, 'throw statement');

$code = "try \{\n    throw new EmptyStackException();\n\} catch (EmptyStackException e) \{\n    return false;\n\}";
generates(
    [Try.new(
            try => [Throw.new(exception => 'EmptyStackException')],
            catchers => CatchBlock.new(
                exception => JavaParameter.new('e', 'EmptyStackException'),
                block => Return.new(return => BooleanLiteral.new(:!value))
            ))
    ], $code, 'try/catch block');

$code = "try \{\n    throw new EmptyStackException();\n\} catch (EmptyStackException e) \{\n    return false;\n\} catch (AnotherException e) \{\n    return true;\n\}";
generates(
    [Try.new(
            try => [Throw.new(exception => 'EmptyStackException')],
            catchers => [CatchBlock.new(
                                exception => JavaParameter.new('e', 'EmptyStackException'),
                                block => Return.new(return => BooleanLiteral.new(:!value))),
                         CatchBlock.new(
                                exception => JavaParameter.new('e', 'AnotherException'),
                                block => Return.new(return => BooleanLiteral.new(:value)))]),
    ], $code, 'try/catch block with two catchers');

my $out = StaticVariable.new(
    :name<out>,
    class => 'System'
);

$code = "try \{\n    throw new EmptyStackException();\n\} catch (EmptyStackException e) \{\n    return false;\n\} finally \{\n    System.out.println(\"Final\");\n\}";
generates(
    [Try.new(
            try => [Throw.new(exception => 'EmptyStackException')],
            catchers => CatchBlock.new(
                exception => JavaParameter.new('e', 'EmptyStackException'),
                block => Return.new(return => BooleanLiteral.new(:!value))
            ),
            finally => MethodCall.new(
                object => $out,
                :name<println>,
                arguments => StringLiteral.new(:value<Final>)))
    ], $code, 'try/catch/finally block');

$code = "for (int i = 0; i < 10; i++) \{\n    System.out.println(i);\n\}";

generates([For.new(
    initializer => VariableDeclaration.new('i', 'int', (), IntLiteral.new(value => 0)),
    cond => InfixOp.new(
        left => LocalVariable.new(:name<i>),
        right => IntLiteral.new(value => 10),
        op => "<"
    ),
    increment => PostfixOp.new(left => LocalVariable.new(:name<i>), :op<++>),
    body => [MethodCall.new(
        object => $out,
        :name<println>,
        arguments => LocalVariable.new(:name<i>))])],
          $code, 'for loop');
