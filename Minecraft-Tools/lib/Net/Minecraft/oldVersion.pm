unit module Net::Minecraft::VersionCheck:ver<1.0.0>;
#= This code uses some flaky heuristics to guess the newest snapshot version.
#= I wrote this before finding out there's a JSON API to get the same info.
#= It's kept around as a historical curiosity; please use :ver<2.*> instead.

#| Returns ([+year,+week,~letter] => ~jar-url) of newest snapshot on success.
sub get-newest-snapshot(Int :$weeks = 5 --> Pair) is export {
    my DateTime $now .= now;
    my Int      $year = $now.year - 2000;

    # Step backwards through weeks until we have something
    for $now.week-number X- ^$weeks -> $week {
        my Pair $found-version;

        # Step forward through revisions until we stop finding something
        for 'a'..'z' -> Str $letter {
            my @bits = [$year, $week, $letter];
            $*ERR.print: @bits ~ '...';

            with get-url-for-version(@bits) {
                note 'OK';
                $found-version = @bits => $_;
            }
            else {
                note ~.exception when Failure;
                last;
            }
        }

        # XXX .return ought to work but... doesn't return?
        return $_ with $found-version;
    }

    fail "No recent snapshots found in last $weeks weeks";
}

sub get-url-for-version(@ [Int $year, Int $week, Str $letter] --> Str) {
    $_ = sprintf('%02dw%02d%s', $year, $week, $letter);

    my $host = 's3.amazonaws.com';
    my $path = "/Minecraft.Download/versions/{$_}/minecraft_server.{$_}.jar";

    return "http://{$host}{$path}" if http-status($host, $path) == 200;

    fail 'Not Found';
}

sub http-status(Str:D $host, Str:D $path --> Int) {
    #use newline :crlf;

    given IO::Socket::INET.new(:$host, :port(80), :enc<ascii>, :nl-in("\r\n")) {
        LEAVE .close;
        for "HEAD {$path} HTTP/1.1"
          , "Host: {$host}"
          , "Connection: close"
          , "" -> $l { .put: $l }

        +$0 if .get ~~ /^'HTTP/1.'\d' '(\d+)/;
    }

}
