use v6;
use Test;
use Crypt::TweetNacl::Basics;

plan 1;

my $aaa = Buf.new(0, 1, 2);
my $exp = Buf.new(1, 2);

my $dut = remove_leading_elems(Buf, $aaa, 1);
is-deeply $dut, $exp;
