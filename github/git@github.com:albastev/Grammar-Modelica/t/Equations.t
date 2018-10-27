#!perl6

use v6;
use Test;
use lib '../lib';
use Grammar::Modelica;

plan 170;

# Here we create a subclass to only test the bit we are interested in
grammar TestEquationSection is Grammar::Modelica {
  # Here we set the bit we want to test to TOP
  rule TOP {^<equation_section>$}
  # Here we replace bits of the regex we are not testing yet with placeholders
  token equation {'iguation'}
}
ok TestEquationSection.parse('initial equation iguation;');
nok TestEquationSection.parse('initialequation iguation;');
nok TestEquationSection.parse('initial equationiguation;');
ok TestEquationSection.parse('equation iguation;');
ok TestEquationSection.parse('initial equation iguation;iguation;');
ok TestEquationSection.parse('initial equation iguation;iguation;iguation;iguation;');
ok TestEquationSection.parse('initial equation iguation ;iguation; iguation ; iguation;');

# Here we create a subclass to only test the bit we are interested in
grammar TestAlgorithmSection is Grammar::Modelica {
  # Here we set the bit we want to test to TOP
  rule TOP {^<algorithm_section>$}
  # Here we replace bits of the regex we are not testing yet with placeholders
  token statement {'statement'}
}
ok TestAlgorithmSection.parse('initial algorithm statement;');
nok TestAlgorithmSection.parse('initialalgorithm statement;');
nok TestAlgorithmSection.parse('initial algorithmstatement;');
ok TestAlgorithmSection.parse('algorithm statement;');
ok TestAlgorithmSection.parse('initial algorithm statement;statement;');
ok TestAlgorithmSection.parse('initial algorithm statement;statement;statement;statement;');
ok TestAlgorithmSection.parse('initial algorithm statement ;statement; statement ; statement;');

grammar TestEquation is Grammar::Modelica {
  rule TOP {^<equation>$}
  token simple_expression {'simple_expression'}
  token expression {'expression'}
  token if_equation {'if_equation'}
  token for_equation {'for_equation'}
  token connect_clause {'connect_clause'}
  token when_equation {'when_equation'}
  token function_call_args {'function_call_args'}
}
ok TestEquation.parse('simple_expression=expression "valid comment"');
ok TestEquation.parse('simple_expression = expression "valid comment"');
ok TestEquation.parse('simple_expression=expression');
ok TestEquation.parse('if_equation "valid comment"');
ok TestEquation.parse('if_equation');
ok TestEquation.parse('for_equation "valid comment"');
ok TestEquation.parse('for_equation');
ok TestEquation.parse('connect_clause "valid comment"');
ok TestEquation.parse('connect_clause');
ok TestEquation.parse('when_equation "valid comment"');
ok TestEquation.parse('when_equation');
ok TestEquation.parse('valid_name function_call_args "valid comment"');
nok TestEquation.parse('valid_namefunction_call_args "valid comment"');
ok TestEquation.parse('valid_name function_call_args');
nok TestEquation.parse('simple_expression=expression when_equation "valid comment"');

grammar TestStatement is Grammar::Modelica {
  rule TOP {^<statement>$}
  token component_reference {'component_reference'}
  token expression {'expression'}
  token function_call_args {'function_call_args'}
  token if_statement {'if_statement'}
  token for_statement {'for_statement'}
  token while_statement {'while_statement'}
  token when_statement {'when_statement'}
  token output_expression_list {'output_expression_list'}
}
ok TestStatement.parse('component_reference := expression "valid comment"');
ok TestStatement.parse('component_reference function_call_args "valid comment"');
ok TestStatement.parse('( output_expression_list ) := component_reference function_call_args "valid comment"');
ok TestStatement.parse('break "valid comment"');
ok TestStatement.parse('return "valid comment"');
nok TestStatement.parse('abreak "valid comment"');
nok TestStatement.parse('areturn "valid comment"');
nok TestStatement.parse('breaka "valid comment"');
nok TestStatement.parse('returna "valid comment"');
ok TestStatement.parse('if_statement "valid comment"');
ok TestStatement.parse('for_statement "valid comment"');
ok TestStatement.parse('while_statement "valid comment"');
ok TestStatement.parse('when_statement "valid comment"');

grammar TestIfEquation is Grammar::Modelica {
  rule TOP {^<if_equation>$}
  token expression {'expression'}
  token equation {'equation'}
}
ok TestIfEquation.parse('if expression then equation; elseif expression then equation; else equation; end if');
ok TestIfEquation.parse('if expression then equation;equation;equation;equation; elseif expression then equation; else equation; end if');
ok TestIfEquation.parse('if expression then equation; elseif expression then equation;equation;equation;equation; else equation; end if');
ok TestIfEquation.parse('if expression then equation; elseif expression then equation; else equation;equation;equation;equation; end if');
nok TestIfEquation.parse('if expression then equation; elseif expression then equation; else equation;');
nok TestIfEquation.parse('if expression then equation; elseif expression then equation; else equation; endif');
nok TestIfEquation.parse('if expression then equation; elseif expression then equation; else equation; end');
nok TestIfEquation.parse('if expression then equation; elseif expression then equation; else equation; if');
nok TestIfEquation.parse('ifexpression then equation; elseif expression then equation; else equation; end if');
nok TestIfEquation.parse('if expressionthen equation; elseif expression then equation; else equation; end if');
nok TestIfEquation.parse('if expression thenequation; elseif expression then equation; else equation; end if');
nok TestIfEquation.parse('if expression then equation; elseifexpression then equation; else equation; end if');
nok TestIfEquation.parse('if expression then equation; elseif expressionthen equation; else equation; end if');
nok TestIfEquation.parse('if expression then equation; elseif expression thenequation; else equation; end if');
nok TestIfEquation.parse('if expression then equation; elseif expression then equation; elseequation; end if');
ok TestIfEquation.parse('if expression then equation; end if');
ok TestIfEquation.parse('if expression then equation; elseif expression then equation; end if');
ok TestIfEquation.parse('if expression then equation; else equation; end if');
ok TestIfEquation.parse('if expression then equation; elseif expression then equation; elseif expression then equation; elseif expression then equation; elseif expression then equation; else equation; end if');

grammar TestIfStatement is Grammar::Modelica {
  rule TOP {^<if_statement>$}
  token expression {'expression'}
  token statement {'equation'}
}
ok TestIfStatement.parse('if expression then equation; elseif expression then equation; else equation; end if');
ok TestIfStatement.parse('if expression then equation;equation;equation;equation; elseif expression then equation; else equation; end if');
ok TestIfStatement.parse('if expression then equation; elseif expression then equation;equation;equation;equation; else equation; end if');
ok TestIfStatement.parse('if expression then equation; elseif expression then equation; else equation;equation;equation;equation; end if');
nok TestIfStatement.parse('if expression then equation; elseif expression then equation; else equation;');
nok TestIfStatement.parse('if expression then equation; elseif expression then equation; else equation; endif');
nok TestIfStatement.parse('if expression then equation; elseif expression then equation; else equation; end');
nok TestIfStatement.parse('if expression then equation; elseif expression then equation; else equation; if');
nok TestIfStatement.parse('ifexpression then equation; elseif expression then equation; else equation; end if');
nok TestIfStatement.parse('if expressionthen equation; elseif expression then equation; else equation; end if');
nok TestIfStatement.parse('if expression thenequation; elseif expression then equation; else equation; end if');
nok TestIfStatement.parse('if expression then equation; elseifexpression then equation; else equation; end if');
nok TestIfStatement.parse('if expression then equation; elseif expressionthen equation; else equation; end if');
nok TestIfStatement.parse('if expression then equation; elseif expression thenequation; else equation; end if');
nok TestIfStatement.parse('if expression then equation; elseif expression then equation; elseequation; end if');
ok TestIfStatement.parse('if expression then equation; end if');
ok TestIfStatement.parse('if expression then equation; elseif expression then equation; end if');
ok TestIfStatement.parse('if expression then equation; else equation; end if');
ok TestIfStatement.parse('if expression then equation; elseif expression then equation; elseif expression then equation; elseif expression then equation; elseif expression then equation; else equation; end if');

grammar TestForEquation is Grammar::Modelica {
  token TOP {^<for_equation>$}
  token for_indices {'for_indices'}
  token equation {'equation'}
}
ok TestForEquation.parse('for for_indices loop equation; end for');
ok TestForEquation.parse('for for_indices loop equation;equation; end for');
ok TestForEquation.parse('for for_indices loop equation;equation;equation;equation; end for');
ok TestForEquation.parse('for for_indices loop equation ;equation; equation ; equation; end for');
nok TestForEquation.parse('for for_indices loop equation;');
nok TestForEquation.parse('for for_indices equation; end for');
nok TestForEquation.parse('for loop equation; end for');
ok TestForEquation.parse('for for_indices loop end for');

grammar TestForStatement is Grammar::Modelica {
  token TOP {^<for_statement>$}
  token for_indices {'for_indices'}
  token statement {'equation'}
}
ok TestForStatement.parse('for for_indices loop equation; end for');
ok TestForStatement.parse('for for_indices loop equation;equation; end for');
ok TestForStatement.parse('for for_indices loop equation;equation;equation;equation; end for');
ok TestForStatement.parse('for for_indices loop equation ;equation; equation ; equation; end for');
nok TestForStatement.parse('for for_indices loop equation;');
nok TestForStatement.parse('for for_indices equation; end for');
nok TestForStatement.parse('for loop equation; end for');
ok TestForStatement.parse('for for_indices loop end for');

grammar TestForIndices is Grammar::Modelica {
  rule TOP {^<for_indices>$}
  token for_index {'for_index'}
}
ok TestForIndices.parse('for_index');
ok TestForIndices.parse('for_index,for_index');
ok TestForIndices.parse('for_index,for_index,for_index,for_index');
ok TestForIndices.parse('for_index ,for_index, for_index , for_index');
nok TestForIndices.parse('for_index,for_index,for_index for_index');

grammar TestForIndex is Grammar::Modelica {
  rule TOP {^<for_index>$}
  token expression {'expression'}
}
ok TestForIndex.parse('valid_ident in expression');
ok TestForIndex.parse('valid_ident');
nok TestForIndex.parse('valid_identin expression');
nok TestForIndex.parse('valid_ident inexpression');

grammar TestWhileStatement is Grammar::Modelica {
  rule TOP {^<while_statement>$}
  token expression {'expression'}
  token statement {'statement'}
}
ok TestWhileStatement.parse('while expression loop statement; end while');
ok TestWhileStatement.parse('while expression loop statement;statement; end while');
ok TestWhileStatement.parse('while expression loop statement;statement;statement;statement; end while');
ok TestWhileStatement.parse('while expression loop statement ;statement; statement ; statement; end while');
nok TestWhileStatement.parse('while expression loop statement;');
nok TestWhileStatement.parse('while expression statement; end while');
nok TestWhileStatement.parse('whileexpression loop statement; end while');
nok TestWhileStatement.parse('while expressionloop statement; end while');
nok TestWhileStatement.parse('while expression loop statement; endwhile');
nok TestWhileStatement.parse('while expression loop statement end while');

grammar TestWhenEquation is Grammar::Modelica {
  rule TOP {^<when_equation>$}
  token expression {'expression'}
  token equation {'equation'}
}
ok TestWhenEquation.parse('when expression then equation; elsewhen expression then equation; end when');
ok TestWhenEquation.parse('when expression then equation;equation; elsewhen expression then equation; end when');
ok TestWhenEquation.parse('when expression then equation; elsewhen expression then equation;equation; end when');
ok TestWhenEquation.parse('when expression then equation;equation;equation;equation; elsewhen expression then equation; end when');
ok TestWhenEquation.parse('when expression then equation; elsewhen expression then equation;equation;equation;equation; end when');
ok TestWhenEquation.parse('when expression then equation ;equation; equation ; equation; elsewhen expression then equation; end when');
ok TestWhenEquation.parse('when expression then equation; elsewhen expression then equation ;equation; equation ; equation; end when');
ok TestWhenEquation.parse('when expression then equation; end when');
nok TestWhenEquation.parse('whenexpression then equation; elsewhen expression then equation; end when');
nok TestWhenEquation.parse('when expressionthen equation; elsewhen expression then equation; end when');
nok TestWhenEquation.parse('when expression thenequation; elsewhen expression then equation; end when');
nok TestWhenEquation.parse('when expression then equation; elsewhenexpression then equation; end when');
nok TestWhenEquation.parse('when expression then equation elsewhen expression then equation; end when');
nok TestWhenEquation.parse('when expression then equation; elsewhen expressionthen equation; end when');
nok TestWhenEquation.parse('when expression then equation; elsewhen expression thenequation; end when');
nok TestWhenEquation.parse('when expression then equation; elsewhen expression then equation; endwhen');
nok TestWhenEquation.parse('when expression equation; elsewhen expression then equation; end when');
nok TestWhenEquation.parse('when expression then equation; elsewhen expression then equation;');
nok TestWhenEquation.parse('when expression then equation; elsewhen expression equation; end when');
nok TestWhenEquation.parse('when expression then equation; elsewhen expression then equation; when');
nok TestWhenEquation.parse('when expression then equation; elsewhen expression then equation; end');

grammar TestWhenStatement is Grammar::Modelica {
  rule TOP {^<when_statement>$}
  token expression {'expression'}
  token statement {'equation'}
}
ok TestWhenEquation.parse('when expression then equation; elsewhen expression then equation; end when');
ok TestWhenEquation.parse('when expression then equation;equation; elsewhen expression then equation; end when');
ok TestWhenEquation.parse('when expression then equation; elsewhen expression then equation;equation; end when');
ok TestWhenEquation.parse('when expression then equation;equation;equation;equation; elsewhen expression then equation; end when');
ok TestWhenEquation.parse('when expression then equation; elsewhen expression then equation;equation;equation;equation; end when');
ok TestWhenEquation.parse('when expression then equation ;equation; equation ; equation; elsewhen expression then equation; end when');
ok TestWhenEquation.parse('when expression then equation; elsewhen expression then equation ;equation; equation ; equation; end when');
ok TestWhenEquation.parse('when expression then equation; end when');
nok TestWhenEquation.parse('whenexpression then equation; elsewhen expression then equation; end when');
nok TestWhenEquation.parse('when expressionthen equation; elsewhen expression then equation; end when');
nok TestWhenEquation.parse('when expression thenequation; elsewhen expression then equation; end when');
nok TestWhenEquation.parse('when expression then equation; elsewhenexpression then equation; end when');
nok TestWhenEquation.parse('when expression then equation elsewhen expression then equation; end when');
nok TestWhenEquation.parse('when expression then equation; elsewhen expressionthen equation; end when');
nok TestWhenEquation.parse('when expression then equation; elsewhen expression thenequation; end when');
nok TestWhenEquation.parse('when expression then equation; elsewhen expression then equation; endwhen');
nok TestWhenEquation.parse('when expression equation; elsewhen expression then equation; end when');
nok TestWhenEquation.parse('when expression then equation; elsewhen expression then equation;');
nok TestWhenEquation.parse('when expression then equation; elsewhen expression equation; end when');
nok TestWhenEquation.parse('when expression then equation; elsewhen expression then equation; when');
nok TestWhenEquation.parse('when expression then equation; elsewhen expression then equation; end');

grammar TestConnectClause is Grammar::Modelica {
  rule TOP {^<connect_clause>$}
}
ok TestConnectClause.parse('connect ( valid_reference1 , valid_reference2 )');
ok TestConnectClause.parse('connect ( valid_reference1, valid_reference2 )');
ok TestConnectClause.parse('connect ( valid_reference1 ,valid_reference2 )');
ok TestConnectClause.parse('connect( valid_reference1 , valid_reference2 )');
ok TestConnectClause.parse('connect (valid_reference1 , valid_reference2 )');
ok TestConnectClause.parse('connect ( valid_reference1 , valid_reference2)');
ok TestConnectClause.parse('connect(valid_reference1,valid_reference2)');
nok TestConnectClause.parse('connect ( valid_reference1 , valid_reference2, valid_reference3 )');
nok TestConnectClause.parse('connect ( valid_reference1 , )');
nok TestConnectClause.parse('connect ( , valid_reference2 )');
nok TestConnectClause.parse('connect ( valid_reference1  valid_reference2 )');
nok TestConnectClause.parse('connect ()');
nok TestConnectClause.parse('connect');
