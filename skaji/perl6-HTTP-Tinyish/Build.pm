use v6.c;
unit class Build;

method build($dist-path) {
    my $proc = run "curl", "--version", :out, :err;
    return if $proc.exitcode == 0;

    die "This module requires 'curl' command, but couldn't find it, abort.";
}
