sub EXPORT (Version:D $v, Str $user-message?, Str() $opts = '') {
    my constant @valid-opts = <rakudo-only  no-where>;
    my $where-to = try {$*W.current_file} // '<unknown file>';
    my $message = 'This program requires Rakudo compiler';

    (my %opts = $opts.lc.words »=>» 1).keys.grep(none @valid-opts) and die
        "Only @valid-opts.map({"'$_'"}).join(', ') are valid as options to"
          ~ " RakudoPrereq but got %opts.keys.sort.map({"'$_'"}).join(', ')"
          ~ " at $where-to";

    my $out = ($*PERL.compiler.name ne 'rakudo' and %opts<rakudo-only>)
        ?? ($user-message || $message)
        !! ($*PERL.compiler.version before $v)
            ?? ($user-message || "$message version $v.perl() or newer; this is"
              ~ " $*PERL.compiler.version.perl()")
            !! return Map.new;

    $out ~= "\nat $where-to" unless %opts<no-where>;
    note $out;
    exit 1;
}
