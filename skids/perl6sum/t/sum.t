use v6;
use lib	<blib/lib lib>;

use Test;

plan 80;

use Sum;
ok(1,'We use Sum and we are still alive');
lives-ok { X::Sum::Final.new() }, 'X::Sum::Final is available';
lives-ok { X::Sum::Missing.new() }, 'X::Sum::Missing is available';
lives-ok { X::Sum::Spill.new() }, 'X::Sum::Spill is available';
lives-ok { X::Sum::Push::Usage.new() }, 'X::Sum::Push::Usage is available';
lives-ok { X::Sum::Recourse.new() }, 'X::Sum::Recourse is available';
lives-ok { X::Sum::Marshal.new(:addend(Str)) }, 'X::Sum::Marshal is available';
lives-ok { EVAL 'class foo1 does Sum { method size { }; method finalize { }; method add { }; method push { }; }' }, 'Sum composes when interface is implemented';
dies-ok { EVAL 'class fooX does Sum { }' }, 'Sum requires interface to compose';
lives-ok { EVAL 'class foo2 does Sum does Sum::Marshal::Raw { method size { }; method finalize { }; method add { }; }' }, 'Sum::Marshal::Raw composes and provides push';
lives-ok { EVAL 'class foo3 does Sum does Sum::Marshal::Cooked { method size { }; method finalize { }; method add { }; }' }, 'Sum::Marshal::Cooked composes and provides push';
lives-ok { EVAL 'class foo4 does Sum does Sum::Marshal::Method[:atype(Str) :method<ords>] { method size { }; method finalize { }; method add { }; }' }, 'Sum::Marshal::Method composes and provides push';
lives-ok { EVAL 'class foo6 does Sum does Sum::Marshal::Pack[] { method size { }; method finalize { }; method add { }; }' }, 'Sum::Marshal::Pack composes and provides push';
lives-ok { EVAL 'class foo7 does Sum::Marshal::Pack[] does Sum::Marshal::Pack::Bits[ :accept(Int) ] { method size { }; method finalize { }; method add { }; }' }, 'Sum::Marshal::Pack::Bits composes';
lives-ok { EVAL 'class foo7a does Sum::Marshal::Pack[] does Sum::Marshal::Pack::Bits[ :width(4) :accept(Int) ] { method size { }; method finalize { }; method add { }; }' }, 'other Sum::Marshal::Pack::Bits composes';

lives-ok { EVAL 'class fooC1 does Sum does Sum::Marshal::Method[:atype(Str) :method<ords>] does Sum::Marshal::Method[:atype(Buf) :method<values>] { method size { }; method finalize { }; method add { }; }' }, 'Two Sum::Marshal subroles can compose with same cronies';

lives-ok {
class Foo does Sum does Sum::Marshal::Cooked {
        has $.accum is rw = 0;
        method size () { 24 };
        method finalize (*@addends) {
            self.push(@addends);
            self
        }
        method Numeric () {
            self.finalize;
            $.accum
        }
	method buf8 () {
	    buf8.new(self.Numeric X+> (16, 8, 0))
	}
        method add (*@addends) {
            $.accum += [+] @addends;
        };
} }, "can compose a basic Sum class";

my Foo $f;
lives-ok { $f .= new(); }, "can instantiate a basic Sum class (Cooked)";

ok $f.elems.WHAT ~~ Failure, "missing elems method is a soft failure";
ok $f.pos.WHAT ~~ Failure, "missing pos method is a soft failure";
ok $f.push(1).WHAT ~~ Failure, "push method returns a failure (Cooked)";
$f.push(2,3);
is $f.accum, 6, "pushed a list of addends (Cooked)";
my @a;
@a <== $f <== (4,5);
is @a.join(""), "45", "is seen as feed tap (passes through values)";
is $f.accum, 15, "tapped a list of addends from a feed(Cooked)";
is +$f.finalize, 15, "finalize with no arguments works (Cooked)";
is +$f.finalize(5), 20, "finalize with one argument works (Cooked)";
is +$f.finalize(5,6), 31, "finalize with multiple arguments works (Cooked)";
$f.push();
is $f.accum, 31, "push with no arguments works(Cooked)";

is $f.base(2), "000000000000000000011111", ".base(2) works";
is $f.base(16), "00001F", ".base(16) works";
is $f.fmt, "00001f", ".fmt works";

lives-ok {
class Foo2 does Sum does Sum::Marshal::Raw {
        has $.accum is rw = 0;
        method size () { 64 };
        method finalize (*@addends) {
            self.push(@addends);
	    self
        }
        method Numeric () {
            self.finalize;
            $.accum;
        }
        method add (*@addends) {
            $.accum += [+] @addends;
        };
} }, "can compose a basic Sum class (Raw)";

my Foo2 $g;
lives-ok { $g .= new(); }, "can instantiate a basic Sum class";

ok $g.push(1).WHAT ~~ Failure, "push method returns a failure (Raw)";
$g.push(2,3);
is $g.accum, 6, "pushed a list of addends (Raw)";
my @b;
@b <== $g <== (4,5);
is @b.join(""), "45", "is seen as feed tap (passes through values) (Raw)";
is $g.accum, 15, "tapped a list of addends from a feed (Raw)";
is +$g.finalize, 15, "finalize with no arguments works (Raw)";
is +$g.finalize(5), 20, "finalize with one argument works (Raw)";
is +$g.finalize(5,6), 31, "finalize with multiple arguments works (Raw)";
$g.push();
is $g.accum, 31, "push with no arguments works(Raw)";

lives-ok {
class Foo3 does Sum::Partial does Sum does Sum::Marshal::Cooked {
        has $.accum is rw = 0;
        method size () { 64 };
        method finalize (*@addends) {
            self.push(@addends);
            self
        }
        method Numeric () {
            self.finalize;
            $.accum
        }
        method add (*@addends) {
            $.accum += [+] @addends;
        };
} }, "can compose a basic Sum class (Raw)";

my Foo3 $h;
lives-ok { $h .= new(); }, "can instantiate a partial Sum class";

ok $h.push(1).WHAT ~~ Failure, "push method returns a failure (Partial)";
$h.push(2,3);
is $h.accum, 6, "pushed a list of addends (Partial)";
my @c;
@c <== $h <== (4,5);
is @c.join(""), "45", "is seen as feed tap (passes through values) (Partial)";
is $h.accum, 15, "tapped a list of addends from a feed (Partial)";
is +$h.finalize, 15, "finalize with no arguments works (Partial)";
is +$h.finalize(5), 20, "finalize with one argument works (Partial)";
is +$h.finalize(5,6), 31, "finalize with multiple arguments works (Partial)";
$h.push();
is $h.accum, 31, "push with no arguments works(Partial)";
is $h.partials(3,2,1)».Numeric.join(''), "343637", "partials method works";
is $h.partials(), (), "partials with no arguments gives empty list";
my @d;
#? rakudo skip 'feed through a slurpy arity function'
#@d <== $h.partials <== (2,3);
#is @d.join(""), "3942", "partials inserts values in a feed"
my $fail = Failure.new(X::AdHoc.new(:payload<foo>));
is $h.partials(4,5,$fail,6).map({.WHAT.gist}), '(Foo3) (Foo3) (Failure)', "partials stops iterating on Failure (Partial,Cooked).";
$fail.defined;

class Foo3r does Sum::Partial does Sum does Sum::Marshal::Raw {
        has $.accum is rw = 0;
        method size () { 64 }
        method finalize (*@addends) {
            self.push(@addends);
            self
        }
        method Numeric () {
            self.finalize;
            $.accum
        }
        method add (*@addends) {
            $.accum += [+] @addends;
        };
}
my Foo3r $hr .= new();

# XXX do some tests of laziness of partials method
is $hr.partials(4,5,$fail,6).map({.WHAT.gist}), '(Foo3r) (Foo3r) (Failure)', "partials stops iterating on Failure (Partial,Raw).";

lives-ok {
class Foo4 does Sum::Partial does Sum does Sum::Marshal::Method[:atype(Str) :method<ords>] {
        has $.accum is rw = 0;
        method size () { 64 }
        method finalize (*@addends) {
            self.push(@addends);
            self
        }
        method Numeric () {
            self.finalize;
            $.accum
        }
        method add (*@addends) {
            $.accum += [+] @addends;
        };
} }, "can compose a basic Sum class (Str.ords)";

my Foo4 $o1;
lives-ok { $o1 .= new(); }, "can instantiate a basic Cooked subclass";
$o1.push("ABC");
is +$o1.finalize, 65 + 66 + 67, "Cooked subclass explodes an addend";
$o1 .= new();
$o1.push(1,"ABC");
is +$o1.finalize, 65 + 66 + 67 + 1, "mix addend before exploding addend";
$o1 .= new();
$o1.push(1,"ABC",2);
is +$o1.finalize, 65 + 66 + 67 + 3, "mix addends around exploding addend";

lives-ok {
class Foo5
     does Sum does Sum::Marshal::Pack[]
     does Sum::Marshal::Pack::Bits[]
     does Sum::Marshal::Pack::Bits[ :width(4) :accept(Str) :coerce(Int) ]
{
        has $.accum is rw = 0;
        method size () { 64 }
        method finalize (*@addends) {
            self.push(@addends);
            return Failure.new(X::Sum::Missing.new()) unless self.whole;
	    self
        }
        method Numeric () {
            self.finalize;
            $.accum;
        }
        method add (*@addends) {
            $.accum += [+] @addends;
        };
} }, "Can instantiate basic Pack subclass";

my Foo5 $o2;
lives-ok { $o2 .= new(); }, "can instantiate Pack subclasses";
$o2.push(True,False,False,False,True,False,True,False);
is +$o2.finalize, 138, "can combine 8 bits";
$o2 .= new();
$o2.push(True,False,False,False,True,False,True,False,8);
is +$o2.finalize, 146, "can combine 8 bits then add an Int";
$o2 .= new();
$o2.push(8,True,False,False,False,True,False,True,False);
is +$o2.finalize, 146, "can add 8 combined bits after an Int";
$o2 .= new();
$o2.push(True,False,False,False,True,False,True);
throws-like { +$o2.finalize }, X::Sum::Missing, "Trying to finalize 7 bits fails";
$o2 .= new();
ok $o2.push(True,False,False,False,True,False,True,8) ~~ Failure, "Normal addend after 7 bits fails";
$o2 .= new();
ok $o2.push(True,False,False,False,True,False,True,8,False) ~~ Failure, "Normal addend amid 8 bits fails";
$o2 .= new();
$o2.push("8","4");
is +$o2.finalize, 0x84, "Bitfield addend works";
$o2 .= new();
$o2.push(True,False,False,False,"4");
is +$o2.finalize, 0x84, "Mixed bit and bitfields works";
$o2 .= new();
ok $o2.push("4") ~~ Failure, "Short bitfield finalize fails";
$o2 .= new();
ok $o2.push("4",8,"4").WHAT ~~ Failure, "Normal addend amid bitfields fails";
$o2 .= new();
$o2.push(8,"4","3");
is +$o2.finalize, 8 + 0x43, "Normal addend after bitfields works";
$o2 .= new();
$o2.push("4","3",8);
is +$o2.finalize, 0x43 + 8, "Normal addend before bitfields works";

lives-ok {
class Foo6
     does Sum does Sum::Marshal::Block[ :BufT(blob16) :elems(2) ]
{
        has @.a is rw;
        method size () { 64 }
        method finalize (*@addends) {
            self.push(@addends);
	    self.add(|self.drain);
            @.a.gist;
        }
        method Numeric () { 1; };
        method add (*@addends) {
	    @.a.push(@addends);
        };
} }, "Can make custom Sum::Marshal::Block subclass";

my Foo6 $b16;
lives-ok { $b16 .= new(); }, "Can instantiate custom Sum::Marshal::Block subclass";
$b16.push(1, 2, buf16.new(3), False xx 17, 4, blob16.new(5));
is $b16.finalize, [ blob16.new(1,2), blob16.new(3,0), blob16.new(2,2), blob16.new(), True ].gist , "Sum::Marshal::Block can correctly produce blob16s";

class Foo7 does Sum::Marshal::IO does Sum::Marshal::Cooked
{
        has $.a is rw = "";
        method size () { 64 }
        method finalize (*@addends) {
            self.push(@addends);
            $.a;
        }
        method Numeric () { 1; };
        method add (*@addends) {
	    $.a = join(",", ($.a, @addends).grep(/./));
        };
}

my Foo7 $tf;
lives-ok { $tf .= new(); }, "Can instantiate custom Sum::Marshal::IO subclass";
$tf.push(open($?FILE.IO.parent.child('testfile.txt')));
is $tf.finalize, open($?FILE.IO.parent.child('testfile.txt')).read(5000).values.join(','), "Sum::Marshal::IO works";

# Now grab the code in the synopsis from the POD and make sure it runs.
# This is currently complete hackery but might improve when pod support does.
# And also an outputs_ok Test.pm function that redirects $*OUT might be nice.
class sayer {
    has $.accum is rw = "";
    method print (*@s) { $.accum ~= [~] @s }
}
my sayer $s .= new();
{ temp $*OUT = $s; EVAL $Sum::Doc::synopsis; }
is $s.accum, $Sum::Doc::synopsis.comb(/<.after \x23\s> (<.ws> <[\d\(\)\[\]]>+)+/).join("\n") ~ "\n", 'Code in manpage synopsis actually works';
