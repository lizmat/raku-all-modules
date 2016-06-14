unit module Test::Notice;

use Test;
# use Terminal::Width; # doesn't actually work under `prove`
constant AVERAGE_READING_SPEED_WPM = 184; # words per minute

sub notice (Str $message, Bool :$try-color = True) is export {
    my $color = sub (Str $s) { '' };
    $try-color and try {
        require Terminal::ANSIColor;
        $color = GLOBAL::Terminal::ANSIColor::EXPORT::DEFAULT::<&color>;
    };

    my $t-width = 80; #terminal-width;
    $t-width -= 2; # diag adds two chars
    $t-width = 10 if $t-width < 10;

    my $hr = '#' x $t-width;
    my $blank = '#' ~ ' ' x ($t-width - 2) ~ '#';
    diag join "\n",
        '', # <-- avoid shifted first line when noticing inside a subtest
        $color('bold red on_green') ~ $hr ~ $color('reset'),
        $color('bold blue on_green') ~ $hr ~ $color('reset'),
        $color('bold yellow on_green') ~ $hr ~ $color('reset'),
        $color('bold white on_black') ~ $blank,
        $color('bold white on_black') ~ $blank,
            to-lines($message, $t-width - 6)
                .map({$color('bold white on_black') ~ "#  $_  #"}),
        $color('bold white on_black') ~ $blank,
        $color('bold white on_black') ~ $blank,
        $color('bold yellow on_green') ~ $hr ~ $color('reset'),
        $color('bold blue on_green') ~ $hr ~ $color('reset'),
        $color('bold red on_green') ~ $hr ~ $color('reset');

    # Pause long enough for the person to read the message...
    # ...plus 1 second to notice it in the first place
    sleep 1 + $message.words / AVERAGE_READING_SPEED_WPM * 60
        unless %*ENV<NONINTERACTIVE_TESTING>;
}

sub to-lines (Str $message, Int $line-length) {
    my @out;
    my @line;
    for $message.words -> $word {
        if @line.join(' ').chars + $word.chars > $line-length {
            if $word.chars >= $line-length {
                @out.append: @line.join(' '), $word;
                @line = ();
            }
            else {
                @out.push: @line.join: ' ';
                @line = $word;
            }
            next;
        }
        @line.push: $word;
    }
    @out.push: @line.join: ' ' if @line;

    # pad lines with whitespace so right "border" of the message is straight
    $_ ~= ' ' x ($line-length - .chars) for @out;

    @out;
}
