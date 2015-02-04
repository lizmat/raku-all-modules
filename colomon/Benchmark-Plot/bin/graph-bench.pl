use v6;
use SVG;
use SVG::Plot;

my %benchmarks;
for lines() -> $line {
    my ($rakudo, $benchmark, $time) = $line.split(/\s* "," \s*/);
    %benchmarks{$benchmark} //= Hash.new;
    %benchmarks{$benchmark}.push($rakudo => $time);
}

# for %benchmarks.keys -> $benchmark {
#     my %results = %benchmarks{$benchmark};
#     say "\n$benchmark:";
#     for %results.keys -> $rakudo {
#         say "  $rakudo { %results{$rakudo} }";
#     }
# }

for %benchmarks.keys -> $benchmark {
    my %results = %benchmarks{$benchmark};
    my @data = %results.pairs.sort(*.key).grep(*.key ne "latest-rakudo");
    @data.push("latest-rakudo" => %results{"latest-rakudo"});
    # say :@data.perl;
    
    my $svg = SVG::Plot.new(
            :title($benchmark),
            :width(800),
            :height(550),
            :plot-height(400),
            :fill-width(1.01), # work a round a common SVG rendering bug
            :values([@data>>.value]),
            :labels(@data>>.key),
            :max-x-labels(20),
            :colors<lawngreen red blue yellow lightgrey>,
        );
    $svg .=plot(:lines);

    my $file = open $benchmark ~ ".svg", :w;
    $file.say: SVG.serialize($svg);
    $file.close;
}


# vim: ft=perl6
