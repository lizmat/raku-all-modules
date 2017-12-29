use lib <lib>;
use WWW::P6lert;

my $conf := $*HOME.add: '.last-p6lert.data';
my $last-time := +(slurp $conf orelse 0);
$conf.spurt: DateTime.now.Instant.to-posix.head.Int;
say "Saved last fetch time to $conf.absolute()";

with WWW::P6lert.new(|(:api-url($_) with %*ENV<WWW_P6LERT_API_URL>))
.since: $last-time {
    for @^alerts {
        say join ' | ', "ID#{.id}", DateTime.new(.time),
            "severity: {.severity}";
        say join ' | ', ("affects: {.affects}" if .affects),
            "posted by: {.creator}";
        say .alert;
        say();
    }
    @alerts or say "No new alerts since {DateTime.new: $last-time}";
}
else {
    say "Error fetching alerts: " ~ $^e.exception.message
}
