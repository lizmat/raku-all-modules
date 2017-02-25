use v6;
use Test;
use BSON::Document;

#-------------------------------------------------------------------------------
subtest "Empty document", {

  my BSON::Document $d .= new;
  is $d.^name, 'BSON::Document', 'Isa ok';
  my Buf $b = $d.encode;

  is $b, Buf.new( 0x05, 0x00 xx 4), 'Empty doc encoded ok';

  $d .= new;
  $d.decode($b);
  is $d.elems, 0, "Zero elements/keys in decoded document";
}

#-------------------------------------------------------------------------------
subtest "Initialize document", {

  # Init via Seq
  #
  my BSON::Document $d .= new: ('a' ... 'z') Z=> 120..145;

  is $d<a>, 120, "\$d<a> = $d<a>";
  is $d<b>, 121, "\$d<b> = $d<b>";
  is $d.elems, 26, "{$d.elems} elements";

  # Add one element, encode and decode using new(Buf)
  #
  $d<aaa> = 11;
  my Buf $b2 = $d.encode;
  my BSON::Document $d2 .= new($b2);
  is $d2.elems, 27, "{$d.elems} elements in decoded doc";
  is $d2<aaa>, 11, "Item is $d2<aaa>";

  # Init via list
  #
  $d .= new: (ppp => 100, qqq => ( d => 110, e => 120));
  is $d<ppp>, 100, "\$d<ppp> = $d<ppp>";
  is $d<qqq><d>, 110, "\$d<qqq><d> = $d<qqq><d>";

  # Init via hash inhibited
  #
  try {
    $d .= new: ppp => 100, qqq => ( d => 110, e => 120);

    CATCH {
      when X::BSON::Parse-document {
        ok .message ~~ ms/'Cannot' 'use' 'hash' 'values' 'on' 'init'/,
           'Cannot use hashes on init';
      }
    }
  }
}

#-------------------------------------------------------------------------------
subtest "Ban the hash", {

  my BSON::Document $d .= new;
  try {
    $d<q> = {a => 20};
    is $d<q><a>, 20, "Hash value $d<q><a>";

    CATCH {
      when X::BSON::Parse-document {
        ok .message ~~ ms/'Cannot' 'use' 'hash' 'values'/,
           'Cannot use hashes';
      }
    }
  }

  $d.accept-hash(True);
  $d<q> = {
    a => 120, b => 121, c => 122, d => 123, e => 124, f => 125, g => 126,
    h => 127, i => 128, j => 129, k => 130, l => 131, m => 132, n => 133,
    o => 134, p => 135, q => 136, r => 137, s => 138, t => 139, u => 140,
    v => 141, w => 142, x => 143, y => 144, z => 145
  };
  is $d<q><a>, 120, "Hash value $d<q><a>";
  my $x = $d<q>.keys.sort;
  nok $x eqv $d<q>.keys.List, 'Not same order';

  $d.autovivify(True);

  $d<e><f><g> = {b => 30};
  is $d<e><f><g><b>, 30, "Autovivified hash value $d<e><f><g><b>";
}

#-------------------------------------------------------------------------------
subtest "Test document, associative", {

  my BSON::Document $d .= new;

  my $count = 0;
  for 'a' ... 'z' -> $c { $d{$c} = $count++; }

  is $d.elems, 26, "26 pairs";
  is $d{'d'}, 3, "\$d\{'d'\} = $d{'d'}";

  ok $d<a>:exists, 'First pair $d<a> exists';
  ok $d<q>:exists, '$d<q> exists';
  ok ! ($d<hsdgf>:exists), '$d<hsdgf> does not exist';

  is-deeply $d<a b>, ( 0, 1), 'Ask for two elements';
  is $d<d>:delete, 3, 'Deleted value is 3';
  is $d.elems, 25, "25 pairs left";

  try {
    is $d<e>, 4, "Pre binding: \$d<e> = $d<e>";
    my $x = 10;
    $d<e> := $x;
    is $d<e>, 10, "Bound: \$d<e> = $d<e> == \$x = $x";
    $x = 11;
    is $d<e>, 11, "Bound: \$d<e> = $d<e> == \$x = $x";

    CATCH {
      when X::BSON::Parse-document {
        my $s = ~$_;
        $s ~~ s:g/\n//;
        ok .message ~~ ms/'Cannot' 'use' 'binding'/, $s;
      }
    }
  }
}

#-------------------------------------------------------------------------------
subtest "Test document, other", {

  my BSON::Document $d .= new: ('a' ... 'z') Z=> 120..145;

  is ($d.kv).elems, 2 * 26, '2 * 26 keys and values';
  is ($d.keys).elems, 26, '26 keys';
  is ($d.keys)[*-1], 'z', "Last key is 'z'";
  is ($d.values).elems, 26, '26 values';
  is ($d.values)[*-1], 145, "Last value is 145";
  is ($d.keys)[3], 'd', "4th key is 'd'";
  is ($d.values)[3], 123, '4th value is 123';
}

#-------------------------------------------------------------------------------
subtest "Document nesting 1", {

  # Try nesting with BSON::Document
  #
  my BSON::Document $d .= new;
  $d<a> = 10;
  $d<b> = 11;
  $d<c> = BSON::Document.new: ( p => 1, q => 2);
  $d<c><a> = 100;
  $d<c><b> = 110;

  is $d<c><b>, 110, "\$d<c><b> = $d<c><b>";
  is $d<c><p>, 1, "\$d<c><p> = $d<c><p>";
}

#-------------------------------------------------------------------------------
subtest "Document nesting 2", {

  # Try nesting with k => v
  #
  my BSON::Document $d .= new;
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

#  $d<foo> = 'v3';
#  $d<bar> = 10;
#  $d.encode;

#say $d.perl;
#say $d<a><v1>.perl;

#$d .= new: ('a' ... 'z') Z=> 120..145;
#say $d.kv;
}

#-------------------------------------------------------------------------------
subtest "Exception tests", {

  # Hash tests done above
  # Bind keys done above


  try {
    my BSON::Document $d .= new;
    $d<js> = BSON::Javascript.new(:javascript(''));
    $d.encode;

    CATCH {
      when X::BSON::Parse-document {
        my $m = .message;
        $m ~~ s:g/\n//;
        like $m, / :s cannot process empty javascript code /, $m;
      }
    }
  }

  try {
    my BSON::Document $d .= new;
    $d<int1> = 1762534762537612763576215376534;
    $d.encode;

    CATCH {
      when X::BSON::Parse-document {
        my $m = .message;
        $m ~~ s:g/\n//;
        like $m, /'Number too large'/, $m;
      }
    }
  }

  try {
    my BSON::Document $d .= new;
    $d<int2> = -1762534762537612763576215376534;
    $d.encode;

    CATCH {
      when X::BSON::Parse-document {
        my $m = .message;
        $m ~~ s:g/\n//;
        like $m, /'Number too small'/, $m;
      }
    }
  }

  try {
    my BSON::Document $d .= new;
    $d{"Double\0test"} = 1.2.Num;
    $d.encode;

    CATCH {
      when X::BSON::Parse-document {
        my $m = .message;
        $m ~~ s:g/\n//;
        like $m, /'Forbidden 0x00 sequence in'/, $m;
      }
    }
  }

  try {
    my BSON::Document $d .= new;
    $d<test> = 1.2.Num;
    my Buf $b = $d.encode;
    # Now use encoded buffer and take a slice from it rendering it currupt.
    $d .= new(Buf.new($b[0 ..^ ($b.elems - 2)]));

    CATCH {
      when X::BSON::Parse-document {
        my $m = .message;
        $m ~~ s:g/\n//;
        like $m, /'Not enaugh characters left'/, $m;
      }
    }
  }

  try {
    my $b = Buf.new(
      0x0B, 0x00, 0x00, 0x00,           # 11 bytes
        BSON::C-INT32,                  # 0x10
        0x62,                           # 'b' note missing tailing char
        0x01, 0x01, 0x00, 0x00,         # integer
      0x00
    );

    my BSON::Document $d .= new($b);

    CATCH {
      when X::BSON::Parse-document {
        my $m = .message;
        $m ~~ s:g/\n//;
        like $m, /:s 'Size of document' .* 'does not match'/, $m;
      }
    }
  }

  try {
    class A { }
    my A $a .= new;

    my BSON::Document $d .= new;
    $d{"A"} = $a;
    $d.encode;

    CATCH {
      when X::BSON::NYS {
        my $m = .message;
        $m ~~ s:g/\n//;
        like $m, /'BSON type' .* 'A<' \d+ '>'/, $m;
      }
    }
  }

  try {
    my $b = Buf.new(
      0x0B, 0x00, 0x00, 0x00,           # 11 bytes
        0xa0,                           # Unimplemented BSON code
        0x62, 0x00,                     # 'b'
        0x01, 0x01, 0x00, 0x00,         # integer
      0x00
    );

    my BSON::Document $d .= new($b);

    CATCH {
      when X::BSON::Parse-document {
        ok .message ~~ ms/'BSON code \'0xa0\' not supported'/,
           'BSON code \'0xa0\' not supported';
      }
    }
  }

  try {
    my $b = Buf.new(
      0x0F, 0x00, 0x00, 0x00,           # 15 bytes
        BSON::C-STRING,                 # 0x02
        0x62, 0x00,                     # 'b'
        0x03, 0x00, 0x00, 0x00,         # 3 bytes total
        0x61, 0x62, 0x63,               # Missing 0x00 at the end
      0x00
    );

    my BSON::Document $d .= new($b);

    CATCH {
      when X::BSON::Parse-document {
        ok .message ~~ ms/'Missing trailing 0x00'/, 'Missing trailing 0x00';
      }
    }
  }
}

#-------------------------------------------------------------------------------
# Cleanup
#
done-testing();
exit(0);



















