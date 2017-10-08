use v6;

unit module Text::Tabs;

our sub expand(@input, $tabstop = 8 --> Array) is export {
    my Array $output = [];
    for @input -> $el {
        my $tmp = '';
        for (split(/^/, $el, :skip-empty)) {
            my $l = $_;
            $l .= subst(/\t/, {" " x $tabstop}, :g);
            $tmp ~= $l;
        }
        $output.push($tmp);
    }
    $output;
}

our sub unexpand(@input, $tabstop = 8 --> Array) is export {
    my $output;
    my $ts_as_space = " " x $tabstop;
    my @lines;

    for @input -> $el {
        @lines = split("\n", $el, :skip-empty);
        @lines = [expand(@lines).flat];
        my @buff;
        for @lines -> $line {
            my $replaced = $line
            .comb($tabstop)
            .map({ $_ eq $ts_as_space ?? "\t" !! $_ })
            .join('');
            @buff.push($replaced);
        }
        $output.push(join("\n", @buff));
    }
    $output;
}
