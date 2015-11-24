unit module Text::Wrap:auth<github:flussence>:ver<0.2.4>;
use Text::Tabs;

sub wrap(Str $lead-indent,
         Str $body-indent,
         UInt :$tabstop         = $?TABSTOP,
         UInt :$columns         = 76,
         Str  :$separator       = "\n",
         Str  :$separator2      = Str,
         Bool :$unexpand        = True,
         Bool :$may-overflow    = False,
         Bool :$strict-break    = False,
         Regex :$word-break     = rx{\s},
         *@texts) is export {

    my Str $text = expand(:$tabstop, trailing-space-join(@texts));

    my Str @pieces;         # Output buffer
    my Str $remainder = ''; # Buffer to catch trailing text

    # Precompute a few things before the main loop
    my (UInt $intrinsic-width, UInt $lead-width, UInt $body-width) =
        compute-sizes($lead-indent, $body-indent, $tabstop, $columns);

    my UInt $current-width  = $lead-width; # Target width of current line (minus indent)
    my Str $current-indent  = $lead-indent; # String to prefix current line with

    # These depend on the two vars above, which change at runtime.
    my Regex $greedy-line   = rx/ (\N ** {0..$current-width}) /;
    my Regex $soft-wrap     = rx/ ($greedy-line) (<$word-break>|\n+|$) /;
    my Regex $fallback-wrap = $may-overflow ?? rx/ (\N*?) (<$word-break>|\n+|$) /
                                            !! $greedy-line;
    my &output-line = $unexpand
                    ?? -> $text { &unexpand.assuming(:$tabstop).($current-indent ~ $text) }
                    !! $current-indent ~ *;

    # The main loop. I'd like to make this a grammar but there's so many variables...
    my Int $pos = 0;
    while $pos <= $text.chars {
        last if $text.match(/\s*$/, :$pos);

        my Match $current-line;

        # Grab as many whole words as possible that'll fit in current line width
        if $current-line = $text.match($soft-wrap, :$pos) {
            $pos = $current-line[0].to + 1;
            $remainder = $current-line[1].Str;
            @pieces.push: output-line($current-line[0]);

            next;
        }

        fail "Text will not fit within requested width ($intrinsic-width)"
            if $strict-break;

        # Try again with fallback method if that fails
        if $current-line = $text.match($fallback-wrap, :$pos) {
            $pos = $current-line[0].to;
            $remainder = $may-overflow ?? $current-line[1].Str
                                       !! ($separator2 // $separator);
            @pieces.push: output-line($current-line[0]);

            next;
        }

        # Prevents explosion with (literal) edge cases
        if $intrinsic-width < 2 {
            warn "Text will not fit within requested width ($intrinsic-width), retrying with 2";
            return wrap($lead-indent, $body-indent, :columns(2), @texts);
        }

        # If this happens things have gone very wrong...
        die "Text will not fit within requested width ($intrinsic-width), confused";

        # width/indent can be different for the first line vs. subsequent lines, so we have to swap
        # them after the first iteration. "once {...}" doesn't quite do what we want here so we need
        # to use a flag variable instead.
        NEXT {
            if @pieces.elems == 1 {
                $current-width = $body-width;
                $current-indent = $body-indent;
            }

            @pieces.push:
                $separator2 ?? $remainder eq "\n" ?? "\n"
                                                  !! $separator2
                            !! $separator;
        }
    }

    return '' unless @pieces;

    @pieces[*-1] = $remainder;
    return @pieces.join;
}

sub fill(Str $lead-indent,
         Str $body-indent,
         *@raw,
         *%wrap-opts) is export {

    @raw.join("\n")\
        .split(/\n\s+/)\
        .map({
            wrap($lead-indent, $body-indent, $^paragraph.split(/\s+/).join(' '), %wrap-opts)
        })\
        .join($lead-indent eq $body-indent ?? "\n\n" !! "\n");
}

# Joins an array of strings with space between, preferring to preserve existing trailing spaces.
sub trailing-space-join(*@texts) {
    my Str $tail = pop(@texts);
    return @texts.map({ /\s+$/ ?? $_ !! $_ ~ q{ } }).join ~ $tail;
}

sub compute-sizes(Str $lead-indent, Str $body-indent, UInt $tabstop, UInt $columns) is pure {
    # The first line is allowed to have zero characters if the indent consumes all available space,
    # in which case text starts on the next line instead.
    my UInt %min-widths = ( lead => 0, body => 1 );
    my UInt %margins = (
        lead => expand(:$tabstop, $lead-indent).chars,
        body => expand(:$tabstop, $body-indent).chars,
    );

    # If either margin is larger than $columns, emit a warning and use the largest number
    my UInt $intrinsic-width = [max] $columns, %margins.values.max;
    if $columns < $intrinsic-width {
        warn "Increasing columns from $columns to $intrinsic-width to contain requested indent";
    }

    # Compute available space left for text content
    my UInt %widths =
        ($_ => ([max] %min-widths{$_}, $intrinsic-width - %margins{$_})
            for <lead body>);

    # 1 char is reserved for "\n", but remove it if the constraints imposed would already cause
    # every line to overflow.
    # NOTE "all(" causes an error in both R and N here, and ()s are necessary for precedence.
    %widths»-- if all (%widths{$_} > %min-widths{$_} for <lead body>);

    return $intrinsic-width, |%widths<lead body>;
}

# vim: ft=perl6 sw=4 ts=4 tw=100
