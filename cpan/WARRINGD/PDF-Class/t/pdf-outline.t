use v6;
use Test;

plan 17;

use PDF::Class;
use PDF::IO::IndObj;
use PDF::Outline;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;
use PDF::Grammar::Test :is-json-equiv;
use PDF::COS;

my PDF::Grammar::PDF::Actions $actions .= new;

my $input = q:to"--END-OBJ--";
20 0 obj <<
  /A 21 0 R
  /Count 2
  /First 22 0 R
  /Last 22 0 R
  /Parent 18 0 R
  /Prev 19 0 R
  /Title (\376\377\000M\000o\000d\000e\000r\000a\000t\000o\000r\000 \000Q\000u\000i\000c\000k\000 \000R\000e\000f\000e\000r\000e\000n\000c\000e\000 \000G\000u\000i\000d\000e)
>>
endobj
--END-OBJ--

PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
    // die "parse failed";
my %ast = $/.ast;
my $reader = class { has $.auto-deref = False }.new;
my PDF::IO::IndObj $ind-obj .= new( |%ast, :$reader);
is $ind-obj.obj-num, 20, '$.obj-num';
is $ind-obj.gen-num, 0, '$.gen-num';
my $outline-obj = PDF::COS.coerce($ind-obj.object, PDF::Outline);
does-ok $outline-obj, PDF::Outline;
is $outline-obj.Title, 'Moderator Quick Reference Guide', '$.Title accessor';
is-deeply $outline-obj.First, (:ind-ref[22, 0]), '$obj.First';
is-deeply $outline-obj.Parent, (:ind-ref[18, 0]), '$obj.Parent';
is-deeply $outline-obj.Prev, (:ind-ref[19, 0]), '$obj.Prev';
is $outline-obj.Count, 2, '.Count';
is $outline-obj.count, 2, '.count';
is $outline-obj.is-open, True, '.is-open';

lives-ok {$outline-obj.is-open = False}, '.is-open rw accessor';
is $outline-obj.Count, -2, '.Count';
is $outline-obj.count, 2, '.count';
is $outline-obj.is-open, False, '.is-open';

lives-ok {$outline-obj.check}, '$outline-obj.check lives';

lives-ok {$outline-obj.is-open = True}, '.is-open rw accessor';

# Rewritten as a simple ASCII string
%ast<ind-obj>[2]<dict><Title> = :literal('Moderator Quick Reference Guide');
is-json-equiv $ind-obj.ast, %ast, 'ast regeneration';
