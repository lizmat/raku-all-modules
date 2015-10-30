use Text::Table::Simple;

use Text::Levenshtein::Damerau; 
use Benchmark;

my $str1 = "lsd";
my $str2 = "lds";

my %results = timethese(1000, {
    'dld' => sub { Text::Levenshtein::Damerau::{"&dld($str1,$str2)"} },
    'ld ' => sub { Text::Levenshtein::Damerau::{"&ld($str1,$str2)"}  },
});

my @headers = ['func','start','end','diff','avg'];
my @rows    = %results.map: {.key, .value.Slip}
my @table   = lol2table(@headers,@rows);

.say for @table;
