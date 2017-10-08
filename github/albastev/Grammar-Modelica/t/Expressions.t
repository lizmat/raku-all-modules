#!perl6

use v6;
use Test;
use lib '../lib';
use Grammar::Modelica;

plan 169;

grammar TestExpression is Grammar::Modelica {
  rule TOP {^ <expression> $}
  rule simple_expression { 'simple_expression' }
}
ok TestExpression.parse('simple_expression');
ok TestExpression.parse("if simple_expression\nthen simple_expression elseif simple_expression then simple_expression else simple_expression\n");
my $string = q:to/END/;
if
  simple_expression
then
  if simple_expression then simple_expression elseif simple_expression then simple_expression else simple_expression
elseif
  simple_expression
then
  if
    simple_expression
  then
    if simple_expression then simple_expression elseif simple_expression then simple_expression else simple_expression
  elseif
    simple_expression
  then
    simple_expression
  elseif
    simple_expression
  then
    if
      simple_expression
    then
      if simple_expression then simple_expression elseif simple_expression then simple_expression else simple_expression
    elseif
      simple_expression
    then
      simple_expression
    elseif
      simple_expression
    then
      simple_expression
    else
      simple_expression
  else
    simple_expression
elseif
  simple_expression
then
  simple_expression
else
  simple_expression
END

ok TestExpression.parse($string);

grammar TestSimpleExpression is Grammar::Modelica {
  rule TOP {^<simple_expression>$}
  rule logical_expression {'logical_expression'}
}
ok TestSimpleExpression.parse('logical_expression:logical_expression:logical_expression');
ok TestSimpleExpression.parse('logical_expression :logical_expression: logical_expression');
ok TestSimpleExpression.parse('logical_expression:logical_expression : logical_expression');
ok TestSimpleExpression.parse('logical_expression:logical_expression');
ok TestSimpleExpression.parse('logical_expression');

grammar TestLogicalExpression is Grammar::Modelica {
  rule TOP {^<logical_expression>$}
  rule logical_term {'logical_term'}
}
ok TestLogicalExpression.parse('logical_term');
ok TestLogicalExpression.parse('logical_term or logical_term');
ok TestLogicalExpression.parse('logical_term or logical_term or logical_term or logical_term');
nok TestLogicalExpression.parse('logical_term or logical_termor logical_term or logical_term');
nok TestLogicalExpression.parse('logical_term or logical_term orlogical_term or logical_term');

grammar TestLogicalTerm is Grammar::Modelica {
  rule TOP {^<logical_term>$}
  rule logical_factor {'logical_term'}
}
ok TestLogicalTerm.parse('logical_term');
ok TestLogicalTerm.parse('logical_term and logical_term');
ok TestLogicalTerm.parse('logical_term and logical_term and logical_term and logical_term');
nok TestLogicalTerm.parse('logical_term and logical_termand logical_term and logical_term');
nok TestLogicalTerm.parse('logical_term and logical_term andlogical_term and logical_term');

grammar TestLogicalFactor is Grammar::Modelica {
  rule TOP {^<logical_factor>$}
  rule relation {'relation'}
}
ok TestLogicalFactor.parse('not relation');
ok TestLogicalFactor.parse('relation');
nok TestLogicalFactor.parse('notrelation');

grammar TestRelation is Grammar::Modelica {
  rule TOP {^<relation>$}
  rule arithmetic_expression {'arithmetic_expression'}
}
ok TestRelation.parse('arithmetic_expression');
ok TestRelation.parse('arithmetic_expression>arithmetic_expression');
ok TestRelation.parse('arithmetic_expression>=arithmetic_expression');
ok TestRelation.parse('arithmetic_expression<arithmetic_expression');
ok TestRelation.parse('arithmetic_expression<=arithmetic_expression');
ok TestRelation.parse('arithmetic_expression<>arithmetic_expression');
ok TestRelation.parse('arithmetic_expression==arithmetic_expression');
ok TestRelation.parse('arithmetic_expression <arithmetic_expression');
ok TestRelation.parse('arithmetic_expression< arithmetic_expression');
ok TestRelation.parse('arithmetic_expression < arithmetic_expression');

grammar TestRelOp is Grammar::Modelica {
  rule TOP {^<relational_operator>$}
}

ok TestRelOp.parse('<');
ok TestRelOp.parse('<=');
ok TestRelOp.parse('>');
ok TestRelOp.parse('>=');
ok TestRelOp.parse('<>');
ok TestRelOp.parse('==');
nok TestRelOp.parse(' ==');
nok TestRelOp.parse('== ');
nok TestRelOp.parse(' == ');

grammar TestArithmeticExpression is Grammar::Modelica {
  rule TOP {^<arithmetic_expression>$}
  rule term {'term'}
}
ok TestArithmeticExpression.parse('+term');
ok TestArithmeticExpression.parse('term');
ok TestArithmeticExpression.parse('+term+term.+term.-term-term');
ok TestArithmeticExpression.parse('+term +term.+ term .- term-term');

grammar TestAddOp is Grammar::Modelica {
  rule TOP {^<add_operator>$}
}

ok TestAddOp.parse('+');
ok TestAddOp.parse('.+');
ok TestAddOp.parse('-');
ok TestAddOp.parse('.-');
nok TestAddOp.parse(' .-');
nok TestAddOp.parse('.- ');
nok TestAddOp.parse(' .- ');

grammar TestTerm is Grammar::Modelica {
  rule TOP {^<term>$}
  rule factor {'factor'}
}
ok TestTerm.parse('factor');
ok TestTerm.parse('factor*factor');
ok TestTerm.parse('factor*factor.*factor/factor./factor');
ok TestTerm.parse('factor*factor .*factor/ factor ./ factor');

grammar TestMulOp is Grammar::Modelica {
  rule TOP {^<mul_operator>$}
}

ok TestMulOp.parse('*');
ok TestMulOp.parse('.*');
ok TestMulOp.parse('/');
ok TestMulOp.parse('./');
nok TestMulOp.parse(' ./');
nok TestMulOp.parse('./ ');
nok TestMulOp.parse(' ./ ');

grammar TestFactor is Grammar::Modelica {
  rule TOP {^<factor>$}
  rule primary {'primary'}
}
ok TestFactor.parse('primary');
ok TestFactor.parse('primary^primary');
ok TestFactor.parse('primary.^primary');
ok TestFactor.parse('primary ^primary');
ok TestFactor.parse('primary^ primary');
ok TestFactor.parse('primary ^ primary');
nok TestFactor.parse('primary^primary^primary');

grammar TestPrimary is Grammar::Modelica {
  rule TOP {^<primary>$}
  rule function_call_args {'function_call_args'}
  rule component_reference {'component_reference'}
  rule output_expression_list {'output_expression_list'}
  rule expression_list {'expression_list'}
  rule function_arguments {'function_arguments'}
}
ok TestPrimary.parse('12345');
ok TestPrimary.parse('"valid string"');
ok TestPrimary.parse('false');
ok TestPrimary.parse('true');
ok TestPrimary.parse('valid_name function_call_args');
ok TestPrimary.parse('der function_call_args');
ok TestPrimary.parse('initial function_call_args');
ok TestPrimary.parse('component_reference');
ok TestPrimary.parse('(output_expression_list)');
ok TestPrimary.parse('[expression_list]');
ok TestPrimary.parse('[expression_list;expression_list]');
ok TestPrimary.parse('[expression_list;expression_list;expression_list;expression_list]');
ok TestPrimary.parse('[expression_list ;expression_list; expression_list ; expression_list]');
ok TestPrimary.parse('{function_arguments}');
ok TestPrimary.parse('end');

grammar TestName is Grammar::Modelica {
  rule TOP {^<name>$}
}
ok TestName.parse('valid_ident');
nok TestName.parse('.valid_ident');
ok TestName.parse('valid_ident.valid_ident');
ok TestName.parse('valid_ident .valid_ident. valid_ident . valid_ident');
nok TestName.parse('valid_ident .valid_ident valid_ident . valid_ident');

grammar TestComponentRef is Grammar::Modelica {
  rule TOP {^<component_reference>$}
  rule array_subscripts {'array_subscripts'}
}
ok TestComponentRef.parse('valid_ident');
ok TestComponentRef.parse('.valid_ident');
ok TestComponentRef.parse('.valid_ident array_subscripts');
ok TestComponentRef.parse('.valid_ident array_subscripts.valid_ident array_subscripts');
ok TestComponentRef.parse('.valid_ident array_subscripts .valid_ident array_subscripts. valid_ident array_subscripts . valid_ident array_subscripts');
nok TestComponentRef.parse('.valid_ident array_subscripts valid_ident array_subscripts');

grammar TestFunctionCallArgs is Grammar::Modelica {
  rule TOP {^<function_call_args>$}
  rule function_arguments {'function_arguments'}
}
ok TestFunctionCallArgs.parse('()');
ok TestFunctionCallArgs.parse('(function_arguments)');
ok TestFunctionCallArgs.parse('( function_arguments )');

grammar TestFunctionArgumentsNonFirst is Grammar::Modelica {
  rule TOP {^<function_arguments_non_first>$}
  rule named_arguments {'named_arguments'}
  rule function_argument {'function_argument'}
}

ok TestFunctionArgumentsNonFirst.parse('function_argument');
ok TestFunctionArgumentsNonFirst.parse('function_argument,function_argument');
ok TestFunctionArgumentsNonFirst.parse('function_argument,function_argument,named_arguments');
ok TestFunctionArgumentsNonFirst.parse('named_arguments');
nok TestFunctionArgumentsNonFirst.parse('function_argument,named_arguments,function_argument');

grammar TestFunctionArguments is Grammar::Modelica {
  rule TOP {^<function_arguments>$}
  rule for_indices {'for_indices'}
  rule named_arguments {'named_arguments'}
  rule expression {'expression'};
  rule function_arguments_non_first {'function_arguments_non_first'};
}

ok TestFunctionArguments.parse('expression');
ok TestFunctionArguments.parse('expression,function_arguments_non_first');
ok TestFunctionArguments.parse('expression for for_indices');
nok TestFunctionArguments.parse('expressionfor for_indices');
nok TestFunctionArguments.parse('expression forfor_indices');
ok TestFunctionArguments.parse('named_arguments');
ok TestFunctionArguments.parse('function valid_name(),function_arguments_non_first');
ok TestFunctionArguments.parse('function valid_name(named_arguments),function_arguments_non_first');
ok TestFunctionArguments.parse('function valid_name (named_arguments) , function_arguments_non_first');

grammar TestNamedArguments is Grammar::Modelica {
  rule TOP {^<named_arguments>$}
  rule named_argument {'named_argument'}
}
ok TestNamedArguments.parse('named_argument');
ok TestNamedArguments.parse('named_argument,named_argument');
ok TestNamedArguments.parse('named_argument,named_argument,named_argument,named_argument');
ok TestNamedArguments.parse('named_argument ,named_argument, named_argument , named_argument');

grammar TestNamedArgument is Grammar::Modelica {
  rule TOP {^<named_argument>$}
  rule function_argument {'function_argument'}
}
ok TestNamedArgument.parse('valid_ident=function_argument');
ok TestNamedArgument.parse('valid_ident =function_argument');
ok TestNamedArgument.parse('valid_ident= function_argument');
ok TestNamedArgument.parse('valid_ident = function_argument');
nok TestNamedArgument.parse('valid_ident function_argument');
nok TestNamedArgument.parse('=function_argument');
nok TestNamedArgument.parse('valid_ident=');

grammar TestFunctionArgument is Grammar::Modelica {
  rule TOP {^<function_argument>$}
  rule named_arguments {'named_arguments'}
  rule expression {'expression'}
}
ok TestFunctionArgument.parse('expression');
ok TestFunctionArgument.parse('function valid_name (named_arguments)');
ok TestFunctionArgument.parse('function valid_name ()');
nok TestFunctionArgument.parse('function ()');
nok TestFunctionArgument.parse('function valid_name');
ok TestFunctionArgument.parse('function valid_name(named_arguments)');
nok TestFunctionArgument.parse('functionvalid_name (named_arguments)');
nok TestFunctionArgument.parse('function valid_name (named_arguments) expression');

grammar TestOutputExpressionList is Grammar::Modelica {
  rule TOP {^<output_expression_list>$}
  rule expression {'expression'}
}
ok TestOutputExpressionList.parse('expression');
ok TestOutputExpressionList.parse('expression,expression');
ok TestOutputExpressionList.parse('expression,expression,expression,expression');
ok TestOutputExpressionList.parse(',expression,expression,expression');
ok TestOutputExpressionList.parse('expression ,expression, expression , expression');
nok TestOutputExpressionList.parse('expression ,expression, expression ,');
nok TestOutputExpressionList.parse('expression ,expression expression , expression');

grammar TestExpressionList is Grammar::Modelica {
  rule TOP {^<expression_list>$}
  rule expression {'expression'}
}
ok TestExpressionList.parse('expression');
ok TestExpressionList.parse('expression,expression');
ok TestExpressionList.parse('expression,expression,expression,expression');
nok TestExpressionList.parse(',expression,expression,expression');
ok TestExpressionList.parse('expression ,expression, expression , expression');
nok TestExpressionList.parse('expression ,expression expression , expression');
nok TestExpressionList.parse('expression ,expression, expression ,');

grammar TestArraySubscripts is Grammar::Modelica {
  rule TOP {^<array_subscripts>$}
  rule subscript {'subscript'}
}
ok TestArraySubscripts.parse('[subscript]');
ok TestArraySubscripts.parse('[subscript,subscript]');
ok TestArraySubscripts.parse('[subscript,subscript,subscript,subscript]');
ok TestArraySubscripts.parse('[subscript ,subscript, subscript , subscript]');
nok TestArraySubscripts.parse('[,subscript,subscript,subscript]');
nok TestArraySubscripts.parse('[subscript,subscript,subscript,]');
nok TestArraySubscripts.parse('[subscript,subscript subscript,subscript]');

grammar TestSubscript is Grammar::Modelica {
  rule TOP {^<subscript>$}
  rule expression {'expression'}
}
ok TestSubscript.parse(':');
ok TestSubscript.parse('expression');

grammar TestComment is Grammar::Modelica {
  rule TOP {^<comment>$}
  rule annotation {'annotation'}
}
ok TestComment.parse('"valid comment" annotation');
ok TestComment.parse('"valid comment"');
ok TestComment.parse('annotation');
ok TestComment.parse('');

grammar TestStringComment is Grammar::Modelica {
  rule TOP {^<string_comment>$}
}

ok TestStringComment.parse('"this is a string comment"');
ok TestStringComment.parse('"this is a"+" string comment"');
ok TestStringComment.parse('"this is a" + " string comment"');
ok TestStringComment.parse('"this is a" +" string comment"');
ok TestStringComment.parse('"this is a"+ " string comment"');
ok TestStringComment.parse('"this is a" + " string comment" ');
ok TestStringComment.parse(' "this is a" + " string comment"');

grammar TestAnnotation is Grammar::Modelica {
  rule TOP {^<annotation>$}
  rule class_modification {'class_modification'}
}
ok TestAnnotation.parse('annotation class_modification');
nok TestAnnotation.parse('annotationclass_modification');
nok TestAnnotation.parse('annotation');
nok TestAnnotation.parse('class_modification');
