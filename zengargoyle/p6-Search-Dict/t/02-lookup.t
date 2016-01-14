use v6;
use Test;
use Search::Dict;

my &lookup = search-dict('t/words', :block-size(1));

my $dict = 't/words';
my @all-words = $dict.IO.words;
my $end-pos = $dict.IO.s;
my @existing-words = @all-words.pick(15);
my $first-word = @all-words[0];
my $last-word = @all-words[*-1];
my @out-words = < a zzzzzzzz >;

diag "search for @existing-words.elems() existing words";
for @existing-words -> $word {
  state $found = 0;
  my $ret = lookup($word);
  $found++ if ?$ret && ~$ret eq $word;
  LAST {
    is $found, @existing-words.elems, "found @existing-words.elems() matches";
  }
}

diag "search for @out-words.elems() non-existing words";
for @out-words -> $word {
  state $found = 0;
  my $ret = lookup($word);
  $found++ if ?$ret && ~$ret eq $word;
  LAST {
    is $found, 0, "found 0 matches";
  }
}

my $ret;
diag "search for first word";
$ret = lookup($first-word);
is ?$ret, True, "first word found";
is +$ret, 0, "position is 0";
is $ret, $first-word, "string is the first word";

diag "search before first word";
$ret = lookup(@out-words[0]);
is ?$ret, False, "not found";
is +$ret, 0, "position is 0";
is $ret, $first-word, "string is the next word";

diag "search after last word";
$ret = lookup(@out-words[1]);
is ?$ret, False, "not found";
is +$ret, $end-pos, "position is at end";
is $ret.match.defined, False, "string is undefined";
# is $ret.Str.defined, False, "string is undefined";

diag "search for last word";
$ret = lookup($last-word);
is ?$ret, True, "last word found";
is +$ret, $end-pos - $last-word.chars - 2, "position is at start of last word";
given $dict.IO.open {
  .seek: +$ret, SeekFromBeginning;
  is .get, $last-word, 'seek and read last word';
}
is $ret, $last-word, "string is last word";

done-testing;
