my $method;
my %funcs;
my %methods;

sub dump {
    take "    $method\n";

    take "  * wraps { %funcs.keys.sort.map({ "`tcc_$_`" }).join(', ') }"
        if %funcs;

    take "  * calls { %methods.keys.sort.map({ "`TCC.$_`" }).join(', ') }"
        if %methods;

    take "\n---\n";

    %funcs = ();
    %methods = ();
}

my $api = join "\n", gather for 'TinyCC.pm6'.IO.lines {
    next unless /^ 'role TCC[' / ff False;

    if /^ '}' / {
        dump;
        last;
    }

    if /^ \s* (.* method .* '{') / {
        dump if $method;
        $method = "$0 ... }";
    }

    for .match(:g, / 'api<' (\w+) '>' /) -> $/ {
        %funcs{~$0} = True;
    }

    for .match(:g, / 'self.' (\w+) /) -> $/ {
        %methods{~$0} = True;
    }
}

for $*IN.lines {
    say / __API__ / ?? $api !! $_;
}
