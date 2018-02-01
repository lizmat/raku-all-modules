use v6.c;
unit class Slang::Predicate:ver<0.0.1>;


=begin pod

=head1 NAME

Slang::Predicate - Predicates in perl6

=head1 SYNOPSIS

  use Slang::Predicate;

  my (\α, \β) = (T, F);

  say ((α → β) ∧ α) → β;

=head1 DESCRIPTION

Slang::Predicate adds operators common to predicate logic directly to perl6.

Exported terms and operators are:

=begin table
 Terms   | Term  | Example
 ======================
 True | T | T ~~ True
 False | F | F ~~ False
=end table

=begin table
  Infix   | operator  | Example
  ======================
  True | T | T ~~ True
  False | F | F ~~ False
  Disjunction | ∨ | T ∨ F ~~ True
  Conjunction | ∧ | T ∧ F ~~ False
  Exclusive disjunction | ⊻ or ⊕ | T ⊻ F ~~ True
  Conditional | → or ⇒ or ⊃ | T → F ~~ False
  Biconditional | ↔ or ⇔ or ≡ | T ↔ F ~~ False
=end table

=begin table
  Prefix   | operator  | Example
  ======================
  Negation | ¬ | ¬T ~~ False
  Verum | ⊤ | ⊤F ~~ True
  Falsum | ⊥ | ⊥T ~~ False
=end table

=head1 AUTHOR

Sam Gillespie <samgwise@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 Sam Gillespie

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

#
# Alias Booleans to T and F
#
constant T is export = True;
constant F is export = False;

# Disjunction ∨
sub infix:<∨>(Bool \α, Bool \β --> Bool) is tighter(&infix:<or>) is assoc<chain> is export {
  α or β
}

# Conjunction ∧
sub infix:<∧>(Bool \α, Bool \β --> Bool) is tighter(&infix:<and>) is assoc<chain> is export {
  α and β
}

# Negation ¬ (or ! or not)
sub prefix:<¬>(Bool \α --> Bool) is tighter(&prefix:<!>) is export {
  not α
}

# Verum ⊤ (or T or True)
sub prefix:<⊤>(Bool $ --> Bool) is tighter(&prefix:<!>) is export {
  True
}

# Falsum ⊥ (or T or True)
sub prefix:<⊥>(Bool $ --> Bool) is tighter(&prefix:<!>) is export {
  False
}

# Exclusive disjunction ⊻ or ⊕ (or xor)
sub infix:<⊻>(Bool \α, Bool \β --> Bool) is tighter(&infix:<xor>) is assoc<chain> is export {
  (α ∨ β) ∧ ¬(α ∧ β)
}
sub infix:<⊕>(Bool \α, Bool \β --> Bool) is tighter(&infix:<xor>) is assoc<chain> is export {
  α ⊻ β
}

# Conditional → or ⇒ or ⊃
sub infix:<→>(Bool \α, Bool \β --> Bool) is tighter(&infix:<or>) is export {
  ¬α ∨ β
  # ¬(α ∧ ¬β)
}
sub infix:<⇒>(Bool \α, Bool \β --> Bool) is tighter(&infix:<or>) is export {
  α → β
}
sub infix:<⊃>(Bool \α, Bool \β --> Bool) is tighter(&infix:<or>) is export {
  α → β
}

# Biconditional ↔ or ⇔ or ≡
sub infix:<↔>(Bool \α, Bool \β --> Bool) is tighter(&infix:<and>) is export {
  ¬(α ⊻ β)
}
sub infix:<⇔>(Bool \α, Bool \β --> Bool) is tighter(&infix:<and>) is export {
  α ↔ β
}
sub infix:<≡>(Bool \α, Bool \β --> Bool) is tighter(&infix:<and>) is export {
  α ↔ β
}
