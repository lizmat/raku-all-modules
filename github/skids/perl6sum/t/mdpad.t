use v6;
use lib <blib/lib lib>;

use Test;

plan 50;

use Sum::MDPad;
ok(1,'We use Sum::MDPad and we are still alive');

class M1 does Sum::MDPad does Sum::Marshal::Raw {
    has $.total is rw = 0;
    has $.lastblock is rw;
    method finalize { $.total }
    method size { Inf }
    multi method add (Buf $block where { .elems == 64 }) {
        return Failure.new(X::Sum::Final.new()) if $.final;
        given self.pos_block_inc {
            when Failure { return $_ };
        }
        $.total += [+] $block.values;
	$.lastblock = $block;
    }
}

my $s1 = M1.new();
ok $s1.WHAT ~~ M1, "We create and instantiate a simple Sum::MDPad subclass";
is $s1.pos, 0, "pos method on new object returns 0";
is $s1.elems, 0, "elems method on new object returns 0";
ok $s1.push(Buf.new(3,0 xx 63)).exception ~~ X::Sum::Push::Usage, "can push a whole block";
is $s1.pos, 512, "pos count increments on whole block push";
is $s1.elems, 512, "elems follows pos on indeterminate-length string";
ok $s1.push(Buf.new(1)).exception ~~ X::Sum::Push::Usage, "can push a short block";
is $s1.pos, 520, "pos count increments on short block push";
is $s1.total, 3 + 1 + 128 + 2 + 8, "block + single byte total is correct";
is ($s1.lastblock.values), (1,0x80,0 xx 60,2,8), "single byte last block looks correct";
ok $s1.push(Buf.new(0 xx 64)).exception ~~ X::Sum::Final, "attempting to push full block to finalized sum causes X::Sum::Final";
ok $s1.push(Buf.new(1)).exception ~~ X::Sum::Final, "attempting to push partial block to finalized sum causes X::Sum::Final";

$s1 = M1.new();
$s1.elems = 513;
is $s1.elems, 513, "elems is lvalue before pushing addends";
is $s1.pos, 0, "pos is still zero after specifying elems";
ok $s1.push(Buf.new(0 xx 64)).exception ~~ X::Sum::Push::Usage, "can push a whole block with explicit elems";
is $s1.elems, 513, "elems immune to increment when explicit";
is $s1.pos, 512, "pos incremented with explicit elems";
throws-like { $s1.elems = 1024 }, X::Sum::Started, "elems unassignable after push";
ok $s1.push(Buf.new(0 xx 64)).exception ~~ X::Sum::Spill, "attempting to push full block past explicit elems causes X::Sum::Spill";
ok $s1.push(Buf.new(1)).exception ~~ X::Sum::Spill, "attempting to push frag past explicit elems causes X::Sum::Spill";
ok $s1.push(Buf.new(),True).exception ~~ X::Sum::Push::Usage, "can push a single bit up to explicit elems";
ok $s1.push(Buf.new(0 xx 64)).exception ~~ X::Sum::Final, "attempting to push full block explicit/finalized causes X::Sum::Final";
ok $s1.push(Buf.new(1)).exception ~~ X::Sum::Final, "attempting to push frag explicit/finalized causes X::Sum::Final";
is $s1.lastblock.values, (192,0 xx 61, 2, 1), "single bit block looks right";
is $s1.total, 128 + 64 + 2 + 1, "total after block + bit looks right";

$s1 = M1.new();
ok ($s1.push(Buf.new(),False)).exception ~~ X::Sum::Push::Usage, "can push single bit to empty sum";
is ($s1.elems, $s1.pos), (1,1), "pos and elems on single (zero) bit sum are right";
is $s1.lastblock.values, (64, 0 xx 62, 1), "sole single (zero) bit block looks right";
is $s1.total, 65, "total for sole single (zero) bit looks right";

$s1 = M1.new();
ok ($s1.push(Buf.new(),False,True,False,True,False,True,False)).exception ~~ X::Sum::Push::Usage, "can push seven bits to empty sum";
is ($s1.elems, $s1.pos), (7,7), "pos and elems on sole seven bit sum are right";
is $s1.lastblock.values, (0x55, 0 xx 62, 7), "sole seven bit block looks right";
is $s1.total, 0x55 + 7, "total for sole seven bit looks right";

$s1 = M1.new();
ok ($s1.push(Buf.new(0 xx 55))).exception ~~ X::Sum::Push::Usage, "can push 55 bytes to empty sum";
is ($s1.elems, $s1.pos), (55*8,55*8), "pos and elems on sole 55 byte sum are right";
is $s1.lastblock.values, (0 xx 55, 128, 0 xx 6, 1, 0xb8), "sole 55 byte block looks right";
is $s1.total, 128 + 1 + 0xb8, "total for sole 55 byte block looks right";

$s1 = M1.new();
ok ($s1.push(Buf.new(0 xx 56))).exception ~~ X::Sum::Push::Usage, "can push 56 bytes to empty sum";
is ($s1.elems, $s1.pos), (56*8,56*8), "pos and elems on 56 byte sum are right";
is $s1.lastblock.values, (0 xx 62, 1, 0xc0), "56 byte final block looks right";
is $s1.total, 128 + 1 + 0xc0, "total for 56 byte sum looks right";

$s1 = M1.new();
ok ($s1.push(Buf.new(0 xx 55), True, False, True, False, True, False, True)).exception ~~ X::Sum::Push::Usage, "can push 447 bits to empty sum";
is ($s1.elems, $s1.pos), (447,447), "pos and elems on 447 bit sum are right";
is $s1.lastblock.values, (0 xx 55, 0xab, 0 xx 6, 0x1, 0xbf), "447-bit sole block looks right";
is $s1.total, 0xab + 0x1 + 0xbf, "total for 447-bit sum looks right";

class M2 does Sum::MDPad[:lengthtype<uint64_le>] does Sum::Marshal::Raw {
    has $.total is rw = 0;
    has $.lastblock is rw;
    method finalize { $.total }
    method size { Inf }
    multi method add (Buf $block where { .elems == 64 }) {
        given self.pos_block_inc {
            when Failure { return $_ };
        }
        $.total += [+] $block.values;
	$.lastblock = $block;
    }
}

my $s2 = M2.new();

$s1 = M2.new();
ok ($s1.push(Buf.new(0 xx 56), False)).exception ~~ X::Sum::Push::Usage, "can push 449 bytes to empty sum";
is ($s1.elems, $s1.pos), (449,449), "pos and elems on 449 bit sum are right";
is $s1.lastblock.values, (0 xx 56, 0xc1, 1, 0 xx 6), "449 bit final block looks right (le)";
is $s1.total, 64 + 1 + 0xc1, "total for 449 bit sum looks right";
