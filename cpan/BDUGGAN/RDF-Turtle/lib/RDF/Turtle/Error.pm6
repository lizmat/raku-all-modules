unit class RDF::Turtle::Error;
use Terminal::ANSIColor;

has $.parsed;
has $.target;

sub throw-error(Match $m, $msg) is export {
    my $e = RDF::Turtle::Error.new:
        parsed => $m.target.substr(0, $*HIGHWATER),
        target => $m.target;
    $e.report($msg);
}
method generate-report($msg) {
    my @msg;
    @msg.push: "--errors--";
    unless $.parsed {
        @msg.push: "Rats, unable to parse anything, giving up.";
        @msg.push: $msg;
        return;
    }
    my $line-no = $.parsed.lines.elems;
    my @lines = $.target.lines;
    my $first = ( ($line-no - 3) max 0 );
    my @near = @lines[ $first.. (($line-no + 3) min @lines-1) ];
    my $i = $line-no - 3 max 0;
    my $chars-so-far = @lines[0..^$first].join("\n").chars;
    my $error-position = $.parsed.chars;
    if %*ENV<RDF_TURTLE_NO_COLOR> {
        &color.wrap(-> | { "" });
    }
    for @near {
        $i++;
        if $i==$line-no {
            @msg.push: color('bold yellow') ~ $i.fmt("%3d") ~ " │▶"
                     ~ "$_" ~ color('reset') ~ "\n";
            @msg.push: "     " ~ '^'.indent($error-position - $chars-so-far);
        } else {
            @msg.push: color('green') ~ $i.fmt("%3d") ~ " │ " ~ color('reset') ~ $_;
            $chars-so-far += .chars;
            $chars-so-far++;
        }
    }
    @msg.push: "";
    @msg.push: "Uh oh, something went wrong around line $line-no.\n";
    @msg.push: "Unable to parse $*LASTRULE." if $*LASTRULE;
    return @msg;
}

method report($msg) {
    say self.generate-report($msg).join("\n");
}
