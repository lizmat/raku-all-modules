use v6;
use Test;

plan 801;
   
# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl6 oo.t'

use Algorithm::Diff;

my $undef;

my ( $a, $b, $hunks );
for (
     [ "a b c   e  h j   l m n p", "  b c d e f  j k l m    r s t", 9 ],
     [ "", "", 0 ],
     [ "a b c", "", 1 ],
     [ "", "a b c d", 1 ],
     [ "a b", "x y z", 1 ],
     [ "    c  e   h j   l m n p r", "a b c d f g  j k l m      s t", 7 ],
     [ "a b c d", "a b c d", 1 ],
     [ "a     d", "a b c d", 3 ],
     [ "a b c d", "a     d", 3 ],
     [ "a b c d", "  b c  ", 3 ],
     [ "  b c  ",  "a b c d", 3 ],
     ) -> @pair
{

    ( $a, $b, $hunks ) = @pair;
    my @a = $a.comb(/ \S+ /);
    my @b = $b.comb(/ \S+ /);

    my $d = Algorithm::Diff.new( @a, @b );
    ok $d.defined, "It's defined...";
    isa-ok $d, Algorithm::Diff, "... and it's an Algorithm::Diff";

#    ('-' x 79).say;
#    say "Sequence A: ",$a;
#    say "Sequence B: ",$b;
#    $d.perl.say;
#    ('-' x 79).say;

    is( $d.Base,         0, 'call Base with nothing' );
    is( $d.Base($undef), 0, 'call Base with undef' );
    is( $d.Base(1),      0, 'call Base with 1' );
    is( $d.Base($undef), 1, 'call Base with undef' );
    is( $d.Base(0),      1, 'call Base with 0' );

    dies-ok( { $d.Diff     }, "dies properly on invalid Diff");
    dies-ok( { $d.Same     }, "dies properly on invalid Same" );
    dies-ok( { $d.Items    }, "dies properly on invalid Items" );
    dies-ok( { $d.Range(2) }, "dies properly on invalid Range" );
    dies-ok( { $d.Min(1)   }, "dies properly on invalid Min" );
    dies-ok( { $d.Max(2)   }, "dies properly on invalid Max" );

    is( $d.Next(0),      0, 'call Next with 0' );
    dies-ok( { $d.Same },   'dies properly on invalid Same' );
    is( $d.Next,         1, 'call Next with 0' )      if  0 < $hunks;
    is( $d.Next($undef), 2, 'call Next with undef' )  if  1 < $hunks;
    is( $d.Next(1),      3, 'call Next with 1' )      if  2 < $hunks;
    is( $d.Next(-1),     2, 'call Next with -1' )     if  1 < $hunks;
    is( $d.Next(-2),     0, 'call Next with -2' );
    dies-ok( { $d.Same }, "dies properly on invalid Same" );

    is( $d.Prev(0),       0, 'Prev with 0' );
    dies-ok( { $d.Same },    'dies properly on invalid Same' );
    is( $d.Prev,         -1, 'call Prev with nothing' )   if  0 < $hunks;
    is( $d.Prev($undef), -2, 'call Prev with undef' )     if  1 < $hunks;
    is( $d.Prev(1),      -3, 'call Prev with 1' )         if  2 < $hunks;
    is( $d.Prev(-1),     -2, 'call Prev with -1' )        if  1 < $hunks;
    is( $d.Prev(-2),      0, 'call Prev with -2' );

    is( $d.Next,    1, 'call Next with default' ) if  0 < $hunks;
    is( $d.Prev,    0, 'call Prev with default' );
    is( $d.Next,    1, 'call Next with default' ) if  0 < $hunks;
    is( $d.Prev(2), 0, 'call Prev with step 2' );
    is( $d.Prev,   -1, 'call Prev with default' ) if  0 < $hunks;
    is( $d.Next,    0, 'call Next with default' );
    is( $d.Prev,   -1, 'call Prev with default' ) if  0 < $hunks;
    is( $d.Next(5), 0, 'call Next with step 5');

    is( $d.Next,    1, 'call Next with default' ) if  0 < $hunks;
    is( $d.Reset,  $d, 'Reset default returns object' );
    is( $d.Prev(0), 0, 'Prev on Reset object already at 0' );

    is( $d.Reset(3).Next(0),  3, 'chained Reset->Next returns correct term' )
        if  2 < $hunks;
    is( $d.Reset(-2).Prev, -3, 'chained Reset->Prev returns correct term' )
        if  2 < $hunks;

    is( $d.Reset(0).Next(-1), $hunks,
        'chained Reset(0)->Next(-1) returns number of hunks' );

    my $c = $d.Copy;
    isa-ok $c, Algorithm::Diff, 'Copy makes a new object of the correct type.';
    is( $c.Base, $d.Base, 'with the correct Base' );
    is( $c.Next(0), $d.Next(0), 'both iterate correctly' );
    is( $d.Copy(-4).Next(0), $d.Copy().Reset(-4).Next(0),
        'equivalent chained operations return equivalent results' );

    $c = $d.Copy( $undef, 1 );
    is( $c.Base(), 1, 'Copy with parameters yields expected result' );
    is( $c.Next(0), $d.Next(0), 'Copy with parameters iterates correctly' );

    $d.Reset();
    my ( @A, @B );

# The two tests in the following group marked with the comments are different
# from the perl5 tests. .Same and .Items return elements and .Range returns
# indicies. The perl 5 tests were comparing array refs in scalar context so they
# would pass as long as they both were the same size. Now they check to see if
# they have the same contents.

    while ( $d.Next ) {
        my $i = 1;
        if ( $d.Same ) {
            is( $d.Diff,            0,               "if loop sequence #{$i++}" );
            is( $d.Same,            @b[$d.Range(2)], "if loop sequence #{$i++}" ); # different from perl 5 !!
            is( $d.Items(2),        @a[$d.Range(1)], "if loop sequence #{$i++}" ); # different from perl 5 !!
            is( ~$d.Same,          ~$d.Items(1),     "if loop sequence #{$i++}" );
            is( ~$d.Items(1),      ~$d.Items(2),     "if loop sequence #{$i++}" );
            is( ~$d.Items(2),      ~@a[$d.Range(1)], "if loop sequence #{$i++}" );
            is( ~@a[$d.Range(1,0)], @b[$d.Range(2)], "if loop sequence #{$i++}" );
            push @A, $d.Same;
            push @B, @b[$d.Range(2)];
        } else {
            is( $d.Same,      '',                   "else loop sequence #{$i++}" );
            is( $d.Diff && 1, 1 * $d.Range(1).Bool, "else loop sequence #{$i++}" );
            is( $d.Diff && 2, 2 * $d.Range(2).Bool, "else loop sequence #{$i++}" );
            is( ~$d.Items(1), ~@a[$d.Range(1)],     "else loop sequence #{$i++}" );
            is( ~$d.Items(2), ~@b[$d.Range(2,0)],   "else loop sequence #{$i++}" );

            push @A, @a[$d.Range(1)];
            push @B, $d.Items(2);
        }
    }
    is( ~@A, ~@a, 'A & a arrays are equivalent' );
    is( ~@B, ~@b, 'B & b arrays are equivalent' );

    next unless $hunks;

    is($d.Next, 1, 'next ok if hunks left' );
    dies-ok( { $d.Items    }, 'need to call Items with a parameter' ); 
    dies-ok( { $d.Items(0) }, 'need to call Items with a valid parameter' );
    dies-ok( { $d.Range    }, 'need to call Range with a parameter' );
    dies-ok( { $d.Range(3) }, 'need to call Range with a valid parameter' );
    dies-ok( { $d.Min      }, 'need to call Min with a parameter' );
    dies-ok( { $d.Min(-1)  }, 'need to call Min with a valid parameter' );
    dies-ok( { $d.Max      }, 'need to call Max with a parameter' );
    dies-ok( { $d.Max(9)   }, 'need to call Max with a valid parameter' );

    $d.Reset(-1);
    $c = $d.Copy( $undef, 1 );

    is( ~@a[$d.Range(1)],   ~[(0,@a).flat.[$c.Range(1)]],   'Range offsets are sane' );
    is( ~@b[$c.Range(2,0)], ~[(0,@b).flat.[$d.Range(2,1)]], 'Range offsets are sane' );
}

##############################################################################
# .Get not implemented so can't test Get method
#
#     ok( "@a[$d->Get('min1')..$d->Get('0Max1')]",
#         "@{[(0,@a)[$d->Get('1MIN1')..$c->Get('MAX1')]]}" );
#     ok( "@{[$c->Min(1),$c->Max(2,0)]}",
#         "@{[$c->Get('Min1','0Max2')]}" );
#     ok( ! eval { scalar $c->Get('Min1','0Max2'); 1 } );
#     ok( "@{[0+$d->Same(),$d->Diff(),$d->Base()]}",
#         "@{[$d->Get(qq<same Diff BASE>)]}" );
#     ok( "@{[0+$d->Range(1),0+$d->Range(2)]}",
#         "@{[$d->Get(qq<Range1 rAnGe2>)]}" );
#     ok( ! eval { $c->Get('range'); 1 } );
#     ok( ! eval { $c->Get('min'); 1 } );
#     ok( ! eval { $c->Get('max'); 1 } ); }



