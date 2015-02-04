use v6;
use Test;

use Text::CSV;


my $prettyq = 
qq|"subject","predicate","object"\n| ~
qq|"dog","bites","man"\n| ~
qq|"child","gets","cake"\n| ~
qq|"arthur","extracts","excalibur"|;


my @pretty =
[<subject predicate object>],
[<dog bites man>],
[<child gets cake>],
[<arthur extracts excalibur>];


is( csv-write( @pretty, :always_quote ), $prettyq, 
    'Always quote works on pretty CSV' );


my $uglyq =
qq|"Name","Number","Sentence"\n"Able","1/2/2013","It's got like, a comma"\n| ~
qq|"Baker","3.14e+0","New\nLines,\nLots\tof\nNew Lines and \tTabs"\n| ~
qq|"Charlie","Nope","Quoth the raven, ""Nevermore"""\n| ~
qq|"Davidovich","√2","Это русский"|;

my @ugly =
[<Name Number Sentence>],
[<Able 1/2/2013>, "It's got like, a comma"],
['Baker',"3.14e+0","New\nLines,\nLots\tof\nNew Lines and \tTabs"],
[<Charlie Nope>, 'Quoth the raven, "Nevermore"'],
[<Davidovich √2>, 'Это русский'];


is( csv-write( @ugly, :always_quote ), $uglyq,
  'Always quote works on ugly CSV');

is( q|"","","","","NotEmpty"|,
    csv-write( [['','','','','NotEmpty']], :always_quote ),
    'Always quote works on empty CSV fields');

done;

# vim:ft=perl6
