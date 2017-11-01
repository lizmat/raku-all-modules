use v6;
use Test;
use BSON::Document;

#------------------------------------------------------------------------------
subtest "subdocs", {

  my BSON::Document $d .= new;
  $d.autovivify(:on);

  $d<a> = 10;
  $d<b><a> = 11;
  $d<c><b><a> = 12;

#  diag $d.perl;

  ok $d<b> ~~ BSON::Document, 'subdoc at b';
  is $d<b><a>, 11, 'is 11';
  is $d<c><b><a>, 12, 'is 12';

  my Buf $b = $d.encode;
  $d .= new($b);
  ok $d<b> ~~ BSON::Document, 'subdoc at b after encode, decode';
  is $d<b><a>, 11, 'is 11 after encode, decode';
  is $d<c><b><a>, 12, 'is 12 after encode, decode';

  $d.autovivify(:!on);
}

#------------------------------------------------------------------------------
subtest "subdoc and array", {

  my BSON::Document $d .= new;
  $d.autovivify(:on);

  $d<b><a> = [^5];

#  diag $d.perl;

  is-deeply $d<b><a>, [^5], 'is ^5';

  my Buf $b = $d.encode;
  $d .= new($b);
  is-deeply $d<b><a>, [^5], 'is ^5 after encode, decode';

  # try nesting with BSON::Document
  $d .= new;
  $d<a> = 10;
  $d<b> = 11;
  $d<c> = BSON::Document.new: ( p => 1, q => 2);
  $d<c><a> = 100;
  $d<c><b> = 110;
  $d<c><c> = [ 1, 2, BSON::Document.new(( p => 1, q => [1,2,3])), 110];

  is $d<c><b>, 110, "\$d<c><b> = $d<c><b>";
  is $d<c><p>, 1, "\$d<c><p> = $d<c><p>";
  is-deeply $d<c><c>,
            [ 1, 2, BSON::Document.new(( p => 1, q => [1,2,3])), 110],
            'and a complex one';

  $d.autovivify(:!on);
}

#-------------------------------------------------------------------------------
subtest "Document nesting 2", {

  # Try nesting with k => v
  #
  my BSON::Document $d .= new;
  $d.autovivify(:on);

  $d<abcdef> = a1 => 10, bb => 11;
  is $d<abcdef><a1>, 10, "sub document \$d<abcdef><a1> = $d<abcdef><a1>";

  $d<abcdef><b1> = q => 255;
  is $d<abcdef><b1><q>, 255,
     "sub document \$d<abcdef><b1><q> = $d<abcdef><b1><q>";

  $d .= new;
  $d<a> = v1 => (v2 => 'v3');
  is $d<a><v1><v2>, 'v3', "\$d<a><v1><v2> = $d<a><v1><v2>";
  $d<a><v1><w3> = 110;
  is $d<a><v1><w3>, 110, "\$d<a><v1><w3> = $d<a><v1><w3>";

  $d.autovivify(:!on);
}

#-------------------------------------------------------------------------------
# Test to see if no hangup takes place when making a special doc.
# On ubuntu docker (Gabor) this test seems to fail. On Travis(Ubuntu)
# or Fedora it works fine. So test only when on TRAVIS.

subtest "Big, wide and deep nesting", {

  # Keys must be sufficiently long and value complex enough to keep a
  # thread busy causing the process to runout of available threads
  # which are by default 16.
  my Num $count = 0.1e0;
  my BSON::Document $d .= new;
  $d.autovivify(:on);

  for ('zxnbcvzbnxvc-aa', *.succ ... 'zxnbcvzbnxvc-bz') -> $char {
    $d{$char} = ($count += 2.44e0);
  }

  my BSON::Document $dsub .= new;
  for ('uqwteuyqwte-aa', *.succ ... 'uqwteuyqwte-bz') -> $char {
    $dsub{$char} = ($count += 2.1e0);
  }

  for ('uqwteuyqwte-da', *.succ ... 'uqwteuyqwte-dz') -> $char {
    $d<x1>{$char} = ($count += 2.1e0);
    $d<x2><x1>{$char} = $dsub.clone;
    $d<x2><x2><x3>{$char} = $dsub.clone;
  }

  for ('jhgsajhgasjdg-ca', *.succ ... 'jhgsajhgasjdg-cz') -> $char {
    $d{$char} = ($count -= 0.02e0);
  }

  for ('uqwteuyqwte-ea', *.succ ... 'uqwteuyqwte-ez') -> $char {
    $d<x3>{$char} = $dsub.clone;
    $d<x4><x1>{$char} = $dsub.clone;
    $d<x4><x2><x3>{$char} = $dsub.clone;
  }

#note "Encode big document";
  my Buf $b = $d.encode;
#note "Done encoding";
#note "Decode big document";
  $dsub .= new($b);
#note "Done decoding";

  is-deeply $dsub, $d, 'document the same after encoding/decoding';

  $d.autovivify(:!on);
}

#------------------------------------------------------------------------------
# Cleanup
done-testing();
exit(0);
