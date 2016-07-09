use v6;

unit module Config::Netrc::Writer;

our sub dump(%config) is export {
    my $output;
    for %config<comments> -> $comment {
        $output ~= "# " ~ $comment ~ "\n" if $comment.defined;
    }
    for @(%config<entries>) -> $entry {
        if $entry<machine> {
            $output ~= "machine "  ~
            $entry<machine><value> ~ ' ' ~
            ($entry<machine><comment>.defined ??
             $entry<machine><comment>
             !! '') ~ "\n";
        }
        if !$entry<machine> {
            $output ~= "default\n";
        }
        if $entry<login> {
            $output ~= "    login " ~
            $entry<login><value> ~ ' ' ~
            ($entry<login><comment>.defined ??
             $entry<login><comment>
             !! '') ~ "\n";
        }
        if $entry<password> {
            $output ~= "    password " ~
            $entry<password><value> ~ ' ' ~
            ($entry<password><comment>.defined ??
             $entry<password><comment>
             !! '') ~ "\n";
        }
    }
    return $output;
}

our sub dumpfile(%config, $fn) is export {
    my $handle = open($fn, :w);
    $handle.print(dump(%config));
    $handle.close;
}
