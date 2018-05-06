use v6;
use Test;
plan 7;

use PDF::Content:ver(v0.0.5+);
use PDF::Class;
use PDF::Grammar::Test :is-json-equiv;

my $pdf = PDF::Class.open: "t/helloworld.pdf";
my $page = $pdf.page: 1;

my %seen;
# image 2 is painted 3 times
my @img-seq = <Im1 Im2 Im2 Im2>;

my sub callback($op, *@args) {
   %seen{$op}++;
   given $op {
       when 'Do' {
           is-json-equiv @args, [shift @img-seq], 'Do callback arguments';
       }
   }
}

my $gfx = $page.render: :&callback;

ok +%seen > 10, 'Operator spread';
ok +%seen<Q> > 3, '"Q" (save) operator spread';
is %seen<Q>, %seen<q>, 'Q ... q pairs';

done-testing;
