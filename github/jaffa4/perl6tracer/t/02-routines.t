use v6;

use Test;
use lib 'lib';
use Rakudo::Perl6::Tracer;

plan 3;
my $tracer = Rakudo::Perl6::Tracer.new();

# test that proto declarations are not noted
my $code_proto = "proto method( \$ ) \{\} ";
my $result = $tracer.trace({},$code_proto); 
ok (not $result ~~ /^note/), "Did not note proto declaration";

# test that multi subs are not noted
my $code_multi = "multi sub method() \{ \}";
$result = $tracer.trace({},$code_multi); 
ok (not $result ~~ /^note/), "Did not note multi sub declaration";

# test that calls are noted
# there are still bugs here with one liners
my $code_call = "sub method \{ 1 \} \nmethod(1);";
$result = $tracer.trace({},$code_call); 
ok ($result ~~ /\nnote/), "Noted call";

# vim: ft=perl6

