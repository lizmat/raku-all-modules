use v6;
use Test;

use Text::CSV;


my $out = './t/test.csv';

my $pretty =
qq|subject,predicate,object\ndog,bites,man\n| ~
qq|child,gets,cake\narthur,extracts,excalibur|;

my @pretty-header = <subject predicate object>;

my $ugly =
qq|Name,Number,Sentence\nAble,1/2/2013,"It's got like, a comma"\n| ~
qq|Baker,3.14e+0,"New\nLines,\nLots\tof\nNew Lines and \tTabs"\n| ~
qq|Charlie,Nope,"Quoth the raven, ""Nevermore"""\n| ~
qq|Davidovich,√2,Это русский|;

my @ugly-header = <Name Number Sentence>;

#---- Test Array writing -------------------------------------------------------

dies_ok { csv-write-file( [] ) },
      'Dies if no file name is provided';


csv-write-file( :file($out), Text::CSV.parse($pretty) );
is($pretty, slurp($out),
      'Array output for parse / write on pretty round-trips');

csv-write-file( :file($out), Text::CSV.parse($ugly) );
is($ugly, slurp($out),
      'Array output for parse / write on ugly round-trips');

csv-write-file(:file($out), Text::CSV.parse($pretty, :skip-header), :header(@pretty-header));
is($pretty, slurp($out),
      'Parse with skip-header / write with given header on pretty ok');

csv-write-file(:file($out), Text::CSV.parse($ugly, :skip-header), :header(@ugly-header));
is($ugly, slurp($out),
      'Parse with skip-header / write with given header on ugly.csv ok');

csv-write-file(file => $out, Text::CSV.parse($ugly, :skip-header), header => @ugly-header);
is($ugly, slurp($out),
      'Different calling convention yields the same result');

csv-write-file(:header(@ugly-header), Text::CSV.parse($ugly, :skip-header), file => $out);
is($ugly, slurp($out),
      'Different parameter order yields the same result');

#---- Test Hash writing -----------------------------------------------------

dies_ok {
    csv-write-file(
         file => $out,
         Text::CSV.parse-file($pretty, output => 'hashes')
    )
}, 'Dies properly if no header is provided in hash mode';

csv-write-file(
     :file( $out ),
     Text::CSV.parse( $pretty, output => 'hashes' ),
     :header( @pretty-header )
);

is( $pretty, slurp($out),
  'Hash output for parse / write with given header on pretty.csv round-trips');

csv-write-file(
     :file( $out ),
     Text::CSV.parse($ugly, output => 'hashes'),
     :header( @ugly-header )
);

is( $ugly, slurp($out),
  'Hash output for parse / write with given header on ugly.csv round-trips');

#---- Test Object writing ----------------------------------------------------

class Sentence {
    has Str $.subject;
    has Str $.predicate;
    has Str $.object;
}

dies_ok {
  csv-write-file(file => $out, Text::CSV.parse($pretty, output => Sentence))
}, 'Dies properly if no header / accessor list is provided in object mode';

csv-write-file(file => $out, Text::CSV.parse($pretty, output => Sentence),
     header => @pretty-header);
is($pretty, slurp($out),
    'Parse / write objects with provided header / accessor list on pretty ok');

class UglyCSV {
    has Str $.Name;
    has Str $.Number;
    has Str $.Sentence;
}

csv-write-file(file => $out, Text::CSV.parse($ugly, output => UglyCSV),
    header => @ugly-header);
is($ugly, slurp($out),
    'Parse / write objects with provided header / accessor list on ugly ok');

#---- Test writing with custom quotes and / separators-------------------------



my $just-checking =
q|"1,2","\t\n",Don't do this
"3,4,5",Hellooo Nurse!,"(Seriously, Don't)"|;

my $insane =
q|,1,,2,"\t\n"Don't do this
,3,,4,,5,"Hellooo Nurse!",(Seriously,, Don't),|;

my @csv = Text::CSV.parse($just-checking);

csv-write-file( @csv, :file($out), :separator('"'), :quote(',') );
is($insane, slurp($out),
  'Writes / Parses correctly with swapped quote and separator characters.');

dies_ok { csv-write-file( @csv, :file($out), :quote('') ) },
  'Dies properly if tries to use blank quoting character';

dies_ok { csv-write-file( @csv, :file($out), :quote("''") ) },
  'Dies properly if tries to use multi-character quoting character';

dies_ok { csv-write-file( @csv, :file($out), :separator('') ) },
  'Dies properly if tries to use blank separator character';

dies_ok { csv-write-file( @csv, :file($out), :separator("''") ) },
  'Dies properly if tries to use multi-char separator character';

dies_ok { csv-write-file( @csv, :file($out), :separator("'"), :quote("'") ) },
  'Dies properly if uses same character for separator and quote';

unlink $out;

done;

# vim:ft=perl6
