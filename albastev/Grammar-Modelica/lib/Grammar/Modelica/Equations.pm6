#!perl6

use v6;

unit role Grammar::Modelica::Equations;

rule equation_section {
  [<|w>'initial'<|w>]? <|w>'equation'<|w> [ <equation> ';' ]*
}

rule algorithm_section {
  [<|w>'initial'<|w>]? <|w>'algorithm'<|w> [ <statement> ';' ]*
}

rule equation {
  [
  [<simple_expression> '=' <expression>] ||
  <if_equation> ||
  <for_equation> ||
  <connect_clause> ||
  <when_equation> ||
  [<component_reference> <function_call_args>]
  ]
  <comment>
}

rule statement {
  [
  [ <component_reference> [ [':=' <expression>] || <function_call_args> ]] ||
  [ '(' <output_expression_list> ')' ':=' <component_reference> <function_call_args> ] ||
  <|w>'break'<|w> ||
  <|w>'return'<|w> ||
  <if_statement> ||
  <for_statement> ||
  <while_statement> ||
  <when_statement>
  ]
  <comment>
}

rule if_equation {
  <|w>'if'<|w> <expression> <|w>'then'<|w>
  [ <equation> ';' ]*
  [
    <|w>'elseif'<|w> <expression> <|w>'then'<|w>
    [ <equation> ';' ]*
  ]*
  [
    <|w>'else'<|w>
    [ <equation> ';' ]*
  ]?

  <|w>'end'<|w> <|w>'if'<|w>
}

rule if_statement {
  <|w>'if'<|w> <expression> <|w>'then'<|w>
  [ <statement> ';' ]*
  [
    <|w>'elseif'<|w> <expression> <|w>'then'<|w>
    [ <statement> ';' ]*
  ]*
  [
    <|w>'else'<|w>
    [ <statement> ';' ]*
  ]?
  <|w>'end'<|w> <|w>'if'<|w>
}

rule for_equation {
  <|w>'for'<|w> <for_indices> <|w>'loop'<|w>
  [ <equation> ';' ]*
  <|w>'end'<|w> <|w>'for'<|w>
}

rule for_statement {
  <|w>'for'<|w> <for_indices> <|w>'loop'<|w>
  [ <statement> ';' ]*
  <|w>'end'<|w> <|w>'for'<|w>
}

rule for_indices { <for_index> [ ',' <for_index> ]* }

rule for_index { <IDENT> ['in'<|w> <expression>]? }

rule while_statement {
  <|w>'while'<|w> <expression> <|w>'loop'<|w>
  [ <statement> ';' ]*
  <|w>'end'<|w> <|w>'while'<|w>
}

rule when_equation {
  <|w>'when'<|w> <expression> <|w>'then'<|w>
  [ <equation> ';' ]*
  [
  <|w>'elsewhen'<|w> <expression> <|w>'then'<|w>
  [ <equation> ';' ]*
  ]*
  <|w>'end'<|w> <|w>'when'<|w>
}

rule when_statement {
  <|w>'when'<|w> <expression> <|w>'then'<|w>
  [ <statement> ';' ]*
  [
  <|w>'elsewhen'<|w> <expression> <|w>'then'<|w><|w><|w>
  [ <statement> ';' ]*
  ]*
  <|w>'end'<|w> <|w>'when'<|w>
}

rule connect_clause {
  <|w>'connect'<|w> '(' <component_reference> ',' <component_reference> ')'
}
