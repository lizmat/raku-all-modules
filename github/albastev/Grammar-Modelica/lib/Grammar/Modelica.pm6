#!perl6

use v6;

#no precompilation; # GH grammar-debugger issue #40
#use Grammar::Tracer;

use Grammar::Modelica::LexicalConventions;
use Grammar::Modelica::ClassDefinition;
use Grammar::Modelica::Extends;
use Grammar::Modelica::ComponentClause;
use Grammar::Modelica::Modification;
use Grammar::Modelica::Equations;
use Grammar::Modelica::Expressions;

unit grammar Grammar::Modelica
  does Grammar::Modelica::LexicalConventions
  does Grammar::Modelica::ClassDefinition
  does Grammar::Modelica::Extends
  does Grammar::Modelica::ComponentClause
  does Grammar::Modelica::Modification
  does Grammar::Modelica::Equations
  does Grammar::Modelica::Expressions;

rule TOP {^ <within>?<class_def>* $}

rule within { 'within' <name>? ';' }

rule class_def { 'final'? <class_definition> ';' }

rule bgs { 'cou!!asdfafsd!!'  }
