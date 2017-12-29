use lib <lib>;
use Test::When <author>;

use Testo;
use Temp::Path;
use JSON::Fast;

plan 3;

my $script := 'bin/p6lert';
my $config := make-temp-path;
is-run $script, :args["--no-color", "--config=$config.absolute()"],
    :out(/
        'Creating new config file'
        .+ 'ID#' \d+ ' | ' \S+ ' | severity: '
    /), 'program runs';

is $config.IO.slurp.&from-json, Hash, 'can decode newly created conf';

is-run $script, :args[
    "--no-color", "--block-on=info", "--config=$*SPEC.devnull()"
], :in<Y>,
    :out(/
        'ID#' \d+ ' | ' \S+ ' | severity: '
        .+? 'Seen important alerts. Proceed'
    /), 'program appears to block when seen some alerts';
