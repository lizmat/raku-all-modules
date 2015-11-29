use v6;

unit class Term::ProgressBar;

has Int $.count = 100;
has Cool:D $.name = " ";
has Int $.width = 100;

has Bool $.p;
has Bool $.t;

has Cool:D $.left = '[';
has Cool:D $.right = ']';
has Cool:D $.style = '=';

has Str $!as = "";

has $!step = 0.0;

method update(Int $step) {
    # This is a bit gross but the other alternative is to use nqp::time_n
    # which leads to warnings. It'd be nice if the DateTime core provided
    # something to get this value directly (posix-hi-res?).
    my $now = DateTime.now;
    my $start = $now.posix + ($now.second - $now.whole-second);

    my $multi = ($step/($.count/$.width)).floor;
    my $ext = ' ';

    $ext ~= $multi*(100/$.width).round(0.1)~"% " if $.p;
    $ext ~= 'eta '~ (( $start - $!step ) * ( $.count - $step ) ).floor ~ 's' if $.t && $step > 1;

    $!as = "$.name "~$.left~($.style x $multi)~(' ' x ($.width - $multi))~$.right~" $ext";

    self!clear;
    print $!as;
    say '' if $step == $.count;

    $!step = $start;
}

method message($s) {
    self!clear;
    say $s;
}

method !clear {
    print "\r";
    print ' ' x $!as.chars+1;
    print "\r";
}

=begin pod

=NAME

Term::ProgressBar - Show a progress bar as you do something

=SYNOPSIS

    use Term::ProgressBar;

    my @items = ...;
    my $bar = Term::ProgressBar.new( :count(@items.elems) );
    for @items -> $x, $item {
        do-something($item);
        $bar->update($x);
    }

    $bar.message('done');

=DESCRIPTION

This class implements a simply progress bar.

=METHODS

This class provides the following methods:

=METHOD Term::ProgressBar.new(...)

Constructs a new progress bar object. The constructor accepts the following
named parameters:

=begin item
C<:count(Int)>

The total number of items for the progress bar. Default to 100.
=end item

=begin item
C<:name(Cool:D)>

A name to prefix to the beginning of the bar. Default to a single sapce.
=end item

=begin item
C<:width(Int)>

The width of the progress bar as a number of graphemes. Default to 100.
=end item

=begin item
C<:p(Bool)>

If this is true, then the bar will include a percent indicator at the right
end of the bar.
=end item

=begin item
C<:t(Bool)>

If this is true, then the bar will include an eta estimate at the right end of
the bar.
=end item

=begin item
C<:left(Cool:D)>

The string to use for the left side of the bar. Defaults to C<[>.
=end item

=begin item
C<:right(Cool:D)>

The string to use for the left side of the bar. Defaults to C<]>.
=end item

=begin item
C<:style(Cool:D)>

The string to use for the body of the bar. Default to C<=>.
=end item

=METHOD $bar.update(Int:D $items)

This method tells the bar to update its indicator to show that C<$items>
number of have been completed.

=METHOD $bar.message(Cool:D $message)

Call this method to indicate that you are done. The C<$message> is actually
optional. If you provide one it will be printed in place of the bar.

=end pod
