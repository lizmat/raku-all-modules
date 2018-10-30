use v6;
BEGIN { @*INC.unshift: 'blib/lib' }

use Test;
use Pod::Strip;
plan 1;

=NAME
Pod::Strip    

my $test1;
    
=begin pod
asdf
=head2 asdf
my $test2;
=begin asdf
    alsdjkflasdjfklajsdf
=end asdf
=end pod
my $test3;
    
=for comment
asdf
asdf

my $test4;
    
is pod-strip(slurp $?FILE).trim, slurp('t/test-out.txt').trim,
    'Strips Pod from code correctly';
    