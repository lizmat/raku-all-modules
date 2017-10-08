unit module Terminal::Width;

sub terminal-width (Int :$default = 80) is export {
    my Int $width = $default;

    if $*SPEC ~~ IO::Spec::Win32 {
        # Look for CON: device; the columns are on the second info line.
        # Can't use actual words due to different languages available
        my $out = try run('mode', :out).out.slurp-rest;
        if $out {
            $out ~~ /
                'CON:' \s*\n
                '----------------------' \s*\n
                <-[:]>+ ':' \N+\n # Lines
                <-[:]>+ ':' \s* $<columns>=\d+
            /;
            $width = $<columns>.Int // $width;
        }
    } else {
        $width = try {
            run('tput', 'cols', :out).out.slurp-rest.trim.Int
        } // $width;
    }

    fail 'Could not determine terminal width' unless $width;
    $width;
}
