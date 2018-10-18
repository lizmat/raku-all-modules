use Java::Generate::Expression;
use Java::Generate::Literal;
use Java::Generate::Statement;
use Java::Generate::Variable;
use Test;

plan 12;

my ($left, $right);

# Variable = Variable
$left  = LocalVariable.new(:name<a>);
$right = LocalVariable.new(:name<b>);
is Assignment.new(:$left, :$right).generate, 'a = b', "Variable = Variable";

# Variable = Expression
$left  = LocalVariable.new(:name<a>);
$right = InfixOp.new(left => IntLiteral.new(value => 10), right => IntLiteral.new(value => 5), :op<+>);
is Assignment.new(:$left, :$right).generate, 'a = 10 + 5', "Variable = Expression";

# Variable = Literal
$left  = LocalVariable.new(:name<a>);
$right = IntLiteral.new(value => 10, base => 'oct');
is Assignment.new(:$left, :$right).generate, 'a = 012', "Variable = Literal";

# Variable op Variable
$left  = LocalVariable.new(:name<a>);
$right = LocalVariable.new(:name<b>);
is InfixOp.new(:$left, :$right, :op<^>).generate, 'a ^ b', "Variable op Variable";

# Variable op Literal
$left  = InstanceVariable.new(:name<a>);
$right = IntLiteral.new(value => 15, base => 'hex');
is InfixOp.new(:$left, :$right, :op<->).generate, 'this.a - 0xF', "Variable op Literal";

# Variable op Expr
$left  = InstanceVariable.new(:name<a>);
$right = InfixOp.new(left => IntLiteral.new(value => 10), right => IntLiteral.new(value => 5), :op<+>);
is InfixOp.new(:$left, :$right, :op<->).generate, 'this.a - (10 + 5)', "Variable op Literal";

my $cond  = InfixOp.new(left => IntLiteral.new(value => 10), right => IntLiteral.new(value => 5), op => '>');
my $true  = InstanceVariable.new(:name<a>);
my $false = InstanceVariable.new(:name<b>);
is Ternary.new(:$cond, :$true, :$false).generate, '10 > 5 ? this.a : this.b', "Ternary operator";

$cond  = InfixOp.new(left => IntLiteral.new(value => 10), right => IntLiteral.new(value => 5), op => '+');
dies-ok { Ternary.new(:$cond, :$true, :$false).generate }, "Ternary operator's condition works with boolean only";

$left = InstanceVariable.new(:name<a>);
is PostfixOp.new(:$left, :op<++>).generate, 'this.a++', 'Postfix op';
$right = InstanceVariable.new(:name<a>);
is PrefixOp.new(:$right, :op<!>).generate, '!this.a', 'Prefix op';

my $array = LocalVariable.new(:name<array>);
my $index = IntLiteral.new(value => 10);
is Slice.new(:$array, :$index).generate, 'array[10]', 'Slicing works';
$index = LocalVariable.new(:name<i>);
is Slice.new(:$array, :$index).generate, 'array[i]', 'Slicing works with non-literals';
