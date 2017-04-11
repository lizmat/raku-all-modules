sub EXPORT (*@args, *%args) {
    my $testing = set @args;
    my $valid-env-keywords
    = set <smoke interactive extended release author online>;

    $testing ⊆ $valid-env-keywords
        or die "Positional arguments to Test::When can only be "
            ~ $valid-env-keywords.keys.sort;

    %args ⊆ <libs modules>
        or die "Only `libs` and `modules` named arguments are supported";

    unless %*ENV<ALL_TESTING> {
        skip-all 'To enable smoke tests, set AUTOMATED_TESTING env var'
            if $testing<smoke> and not %*ENV<AUTOMATED_TESTING>;

        skip-all 'To enable interactive tests, unset NONINTERACTIVE_TESTING env var'
            if $testing<interactive> and %*ENV<NONINTERACTIVE_TESTING>;

        skip-all 'To enable extended tests, set EXTENDED_TESTING or RELEASE_TESTING env var'
            if $testing<extended> and not (
                %*ENV<EXTENDED_TESTING> or %*ENV<RELEASE_TESTING>
            );

        skip-all 'To enable release tests, set RELEASE_TESTING env var'
            if $testing<release> and not %*ENV<RELEASE_TESTING>;

        skip-all 'To enable author tests, set AUTHOR_TESTING env var'
            if $testing<author> and not %*ENV<AUTHOR_TESTING>;

        skip-all 'To enable online tests, set ONLINE_TESTING env var'
            if $testing<online> and not %*ENV<ONLINE_TESTING>;
    }

    return {};
}

sub skip-all (Str $message) {
    say "1..0 # SKIPPING test: $message";
    exit 0;
}
