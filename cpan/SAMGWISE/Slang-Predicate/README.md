NAME
====

Slang::Predicate - Predicates in perl6

SYNOPSIS
========

    use Slang::Predicate;

    my (\α, \β) = (T, F);

    say ((α → β) ∧ α) → β;

DESCRIPTION
===========

Slang::Predicate adds operators common to predicate logic directly to perl6.

Exported terms and operators are:

<table>
  <thead>
    <tr>
      <td>Terms</td>
      <td>Term</td>
      <td>Example</td>
    </tr>
  </thead>
  <tr>
    <td>True</td>
    <td>T</td>
    <td>T ~~ True</td>
  </tr>
  <tr>
    <td>False</td>
    <td>F</td>
    <td>F ~~ False</td>
  </tr>
</table>

<table>
  <thead>
    <tr>
      <td>Infix</td>
      <td>operator</td>
      <td>Example</td>
    </tr>
  </thead>
  <tr>
    <td>True</td>
    <td>T</td>
    <td>T ~~ True</td>
  </tr>
  <tr>
    <td>False</td>
    <td>F</td>
    <td>F ~~ False</td>
  </tr>
  <tr>
    <td>Disjunction</td>
    <td>∨</td>
    <td>T ∨ F ~~ True</td>
  </tr>
  <tr>
    <td>Conjunction</td>
    <td>∧</td>
    <td>T ∧ F ~~ False</td>
  </tr>
  <tr>
    <td>Exclusive disjunction</td>
    <td>⊻ or ⊕</td>
    <td>T ⊻ F ~~ True</td>
  </tr>
  <tr>
    <td>Conditional</td>
    <td>→ or ⇒ or ⊃</td>
    <td>T → F ~~ False</td>
  </tr>
  <tr>
    <td>Biconditional</td>
    <td>↔ or ⇔ or ≡</td>
    <td>T ↔ F ~~ False</td>
  </tr>
</table>

<table>
  <thead>
    <tr>
      <td>Prefix</td>
      <td>operator</td>
      <td>Example</td>
    </tr>
  </thead>
  <tr>
    <td>Negation</td>
    <td>¬</td>
    <td>¬T ~~ False</td>
  </tr>
  <tr>
    <td>Verum</td>
    <td>⊤</td>
    <td>⊤F ~~ True</td>
  </tr>
  <tr>
    <td>Falsum</td>
    <td>⊥</td>
    <td>⊥T ~~ False</td>
  </tr>
</table>

AUTHOR
======

Sam Gillespie <samgwise@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2017 Sam Gillespie

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
