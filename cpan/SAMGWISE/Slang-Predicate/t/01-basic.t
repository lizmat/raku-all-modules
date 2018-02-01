use v6.c;
use Test;

use-ok 'Slang::Predicate';
use Slang::Predicate;

is T, True, "T is True";
is F, False, "F is False";
is (T, F, T), (T, F, T), "T and F are usable like values (Positional).";

{

  my \α = T;
  is α, T, "T is usable to test againts like a value."
}

#
# Operators:
#

diag '-' x 78;
my \disjunction-table =
  (T, T, T),
  (F, T, T),
  (T, F, T),
  (F, F, F);
for disjunction-table -> (\α, \β, \answer) {
  is (α ∨ β), answer, "{ α } ∨ { β } ⇔ { answer }";
  # is α \/ β, answer, "{ α } \\/ { β } ⇔ { answer }"
}

diag '-' x 78;
my \conjunction-table =
  (T, T, T),
  (F, T, F),
  (T, F, F),
  (F, F, F);
for conjunction-table -> (\α, \β, \answer) {
  is (α ∧ β), answer, "{ α } ∧ { β } ⇔ { answer }";
  # is α /\ β, answer, "{ α } /\\ { β } ⇔ { answer }"
}

diag '-' x 78;
my \exclusive-disjunction-table =
  (T, T, F),
  (F, T, T),
  (T, F, T),
  (F, F, F);
for exclusive-disjunction-table -> (\α, \β, \answer) {
  is (α ⊻ β), answer, "{ α } ⊻ { β } ⇔ { answer }";
  is (α ⊕ β), answer, "{ α } ⊕ { β } ⇔ { answer }"
}

diag '-' x 78;
my \negation-table =
  (T, F),
  (F, T);
for negation-table -> (\α, \answer) {
  is ¬α, answer, "¬{ α } ⇔ { answer }";
}

diag '-' x 78;
my \verum-table =
  (T, T),
  (F, T);
for verum-table -> (\α, \answer) {
  is ⊤α, answer, "⊤{ α } ⇔ { answer }";
}

diag '-' x 78;
my \falsum-table =
  (T, F),
  (F, F);
for falsum-table -> (\α, \answer) {
  is ⊥α, answer, "⊥{ α } ⇔ { answer }";
}

# implies → or ⇒ or ⊃
diag '-' x 78;
my \conditional-table =
  (T, T, T),
  (F, T, T),
  (T, F, F),
  (F, F, T);
for conditional-table -> (\α, \β, \answer) {
  is (α → β), answer, "{ α } → { β } ⇔ { answer }";
  is (α ⇒ β), answer, "{ α } ⇒ { β } ⇔ { answer }";
  is (α ⊃ β), answer, "{ α } ⊃ { β } ⇔ { answer }";
}

# Biconditional ↔ or ⇔ or ≡
diag '-' x 78;
my \biconditional-table =
  (T, T, T),
  (F, T, F),
  (T, F, F),
  (F, F, T);
for biconditional-table -> (\α, \β, \answer) {
  is (α ↔ β), answer, "{ α } ↔ { β } ⇔ { answer }";
  is (α ⇔ β), answer, "{ α } ⇔ { β } ⇔ { answer }";
  is (α ≡ β), answer, "{ α } ≡ { β } ⇔ { answer }";
}

done-testing;
