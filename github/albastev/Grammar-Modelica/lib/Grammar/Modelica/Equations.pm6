#!perl6

use v6;

unit role Grammar::Modelica::Equations;

rule equation_section {
  'initial'? 'equation' [ <equation> ';' ]*
}

rule algorithm_section {
  'initial'? 'algorithm' [ <statement> ';' ]*
}

rule equation {
  [
    ||  <simple_expression> '=' <expression>
    ||  <if_equation>
    ||  <for_equation>
    ||  <connect_clause>
    ||  <when_equation>
    ||  <component_reference> <function_call_args>
  ]  <comment>
}

rule statement {
  [
    ||  '(' <output_expression_list> ')' ':=' <component_reference> <function_call_args>
    ||  'break'
    ||  'return'
    ||  <if_statement>
    ||  <for_statement>
    ||  <while_statement>
    ||  <when_statement>
    ||  <component_reference> [ ':=' <expression> || <function_call_args> ]
  ]
  <comment>
}

rule if_equation {
  'if' <expression> 'then'
  [ <equation> ';' ]*
  [
    'elseif' <expression> 'then'
    [ <equation> ';' ]*
  ]*
  [
    'else'
    [ <equation> ';' ]*
  ]?

  'end' 'if'
}

rule if_statement {
  'if' <expression> 'then'
  [ <statement> ';' ]*
  [
    'elseif' <expression> 'then'
    [ <statement> ';' ]*
  ]*
  [
    'else'
    [ <statement> ';' ]*
  ]?
  'end' 'if'
}

rule for_equation {
  'for' <for_indices> 'loop'
  [ <equation> ';' ]*
  'end' 'for'
}

rule for_statement {
  'for' <for_indices> 'loop'
  [ <statement> ';' ]*
  'end' 'for'
}

rule for_indices { <for_index> [ ',' <for_index> ]* }

rule for_index { <IDENT> ['in' <expression>]? }

rule while_statement {
  'while' <expression> 'loop'
  [ <statement> ';' ]*
  'end' 'while'
}

rule when_equation {
  <|w>'when'<|w> <expression> <|w>'then'<|w>
  [ <equation> ';' ]*
  [
  <|w>'elsewhen'<|w> <expression> <|w>'then'<|w>
  [ <equation> ';' ]*
  ]*
  'end' 'when'
}

rule when_statement {
  'when' <expression> 'then'
  [ <statement> ';' ]*
  [
  'elsewhen' <expression> 'then'
  [ <statement> ';' ]*
  ]*
  'end' 'when'
}

rule connect_clause {
  'connect' '(' <component_reference> ',' <component_reference> ')'
}
