unit class Grammar::Highlighter;

has $.formatter;

class Highlighted {
    has Str $.orig;
    has Int $.from;
    has Int $.to;
    has @.children;
    has $.color;
    has $.formatter;

    method Str() {
        if @.children {
            my $first-sub = @.children>>.from.min - $.from;
            my $last-sub  = @.children>>.to.max;
            my $children  = @.children.map(*.Str).join('');
            if $first-sub > 0 or $last-sub > 0 {
                return $.formatter.colored(
                    $.orig.substr($.from, $first-sub),
                    $children,
                    $.orig.substr($last-sub, $.to - $last-sub),
                    $.color
                );
            }
            else {
                return $children;
            }
        }
        else {
            return $.formatter.colored(
                $.orig.substr($.from, $.to - $.from),
                Str,
                Str,
                $.color
            );
        }
    }
}

my $current = 0;
my %known;
::?CLASS.HOW.add_fallback(::?CLASS, -> $, $ { True },
    method ($name) {
        -> \self, $/ {
            if $name eq 'ws' {
                make $/;
            }
            else {
                make Highlighted.new(
                    orig      => $/.orig,
                    from      => $/.from,
                    to        => $/.to,
                    children  => $/.hash.values.map({$_ ~~ Positional ?? |$_.map: *.ast !! $_.ast}),
                    color     => %known{$name} //= $current++,
                    formatter => $.formatter,
                );
            }
        }
    }
);

# vim: ft=perl6
