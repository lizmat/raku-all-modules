#! /usr/bin/env perl6
use v6;
use Test;

plan 14;

use-ok 'Music::Engine::Generator::CurveMD';
use Music::Engine::Generator::CurveMD;

# use 한골 so as not to confuse perl6... use perl십...
# 1 <=> 일
# 2 <=> 이
my $on-step-cb-일D = Promise.new;
my $on-step-cb-이D = Promise.new;

# provide timeout for failure
Promise.in(3).then( {
  try $on-step-cb-일D.keep: False;
  try $on-step-cb-이D.keep: False;
  Promise.in(1).then: {
    exit 1
  }
} );

# Get to testing out generator #
# Single dimension
my Music::Engine::Generator::CurveMD $curve .= new(
  :curve-current(-12)
  :curve-target(12)
  :steps(4)
  :on-steps-finished( -> $c { try $on-step-cb-일D.keep: True } )
);
$curve.queue-target($(-12,), 4);
for (-12, -10, -5, 4, 12).kv -> $step, $value {
  is $curve.next-step, $value, "1D curve step $step";
}

# two dimensions
$curve .= new(
  :curve-current(-12, -12)
  :curve-target(12, 12)
  :steps(4)
  :on-steps-finished( -> $c { try $on-step-cb-이D.keep: True } )
);
$curve.queue-target($(-12, -12), 4);
for ((-12, -12), (-10, -10), (-5, -5), (4, 4), (12, 12)).kv -> $step, $value {
  is $curve.next-step, $value, "1D curve step $step";
}

# collect callback promises #
# check results
is await($on-step-cb-일D), True, "On step finished callback executed for 1D curve.";
is await($on-step-cb-이D), True, "On step finished callback executed for 2D curve.";

is distribute-targets($(1, 2, 3, 4), 4), ($(1, 1,), $(2, 1,), $(3, 1,), $(4, 1,)), "Distribute simple";
