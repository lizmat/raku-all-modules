#! /usr/bin/env perl6
use v6.c;
use Test;
use Slang::Predicate;

my \truth-table =
  (T, T),
  (F, T),
  (T, F),
  (F, F);

for truth-table -> (\α, \β) {
  is ¬(α ∧ ¬β), (α → β), "Conditional statment ⇔ conditional operator.";
  is ( ((α → β) ∧ α) → β ), ( (α ∧ (α → β)) → β ), "Modus Ponens ⇔ Alternate spelling."
}

done-testing
