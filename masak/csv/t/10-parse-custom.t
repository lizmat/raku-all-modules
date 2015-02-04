use v6;
use Test;

use Text::CSV;

my $ugly =
qq|Name,Number,Sentence\nAble,1/2/2013,"It's got like, a comma"\n| ~
qq|Baker,3.14e+0,"New\nLines,\nLots\tof\nNew Lines and \tTabs"\n| ~
qq|Charlie,Nope,"Quoth the raven, ""Nevermore"""\n| ~
qq|Davidovich,√2,Это русский\n|;

my $uglys =
qq|Name,Number,Sentence\nAble,1/2/2013,'It''s got like, a comma'\n| ~
qq|Baker,3.14e+0,'New\nLines,\nLots\tof\nNew Lines and \tTabs'\n| ~
qq|Charlie,Nope,'Quoth the raven, "Nevermore"'\n| ~
qq|Davidovich,√2,Это русский\n|;

my $uglyt =
qq|Name\tNumber\tSentence\nAble\t1/2/2013\tIt's got like, a comma\n| ~
qq|Baker\t3.14e+0\t"New\nLines,\nLots\tof\nNew Lines and \tTabs"\n| ~
qq|Charlie\tNope\t"Quoth the raven, ""Nevermore"""\n| ~
qq|Davidovich\t√2\tЭто русский\n|;


dies_ok { Text::CSV.parse( $ugly, :quote("") ) },
  'Dies properly if tries to use blank quoting character';

dies_ok { Text::CSV.parse( $ugly, :quote(" ") ) },
  'Dies properly if tries to use a space for a quoting character';

dies_ok { Text::CSV.parse( $ugly, :quote("''") ) },
  'Dies properly if tries to use multi characters for a quoting character';

dies_ok { Text::CSV.parse( $ugly, :separator("") ) },
  'Dies properly if tries to use blank separator character';

dies_ok { Text::CSV.parse( $ugly, :quote("\n") ) },
  'Dies properly if tries to use a space for a separator character';

dies_ok { Text::CSV.parse( $ugly, :quote("''") ) },
  'Dies properly if tries to use multi characters for a separator character';

dies_ok { Text::CSV.parse( $ugly, :quote("'"), :separator("'") ) },
  'Dies properly if tries to use the same characters for both separator and quote character';

my @csv = Text::CSV.parse($ugly);

is_deeply Text::CSV.parse( $uglys, :quote("'") ),
    @csv, 'Parsing using custom quote "\'" works correctly';

is_deeply Text::CSV.parse( $uglyt, :separator("\t") ),
    @csv, 'Parsing using custom separator "\t" works correctly';

done;

# vim:ft=perl6
