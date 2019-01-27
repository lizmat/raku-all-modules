use v6;
use Text::Levenshtein::Damerau; 
use Text::Table::Simple;
use Benchmark;

# benchmark.p6 <number of runs>
sub MAIN(Int $runs = 10) {
    for 1,5,20 -> Int $multiplier {
        my Str $str1 = "four" x $multiplier;
        my Str $str2 = "fuoru" x $multiplier;
        say "Testing lengths:\n\$str1 = {$str1.chars}\t\$str1 = {$str2.chars}";

        my %results = timethese($runs, {
            'Text::Levenshtein::Damerau::{"&dld"}' 
                => sub { Text::Levenshtein::Damerau::{"&dld($str1,$str2)"} 
            },
            'Text::Levenshtein::Damerau::{"&ld"}' 
                => sub { Text::Levenshtein::Damerau::{"&ld($str1,$str2)"}  
            },
        });

        my @headers = ['func','start','end','diff','avg'];
        my @rows    = %results.map({ [.key,.value.Slip] });

        my @table = lol2table(@headers,@rows);

        $_.say for @table;
    }
}
