use v6;

# Build.pm can also be run standalone 
sub MAIN(*@sources) {
    say '';
    say "ISO_32000 Reference|Role|Entries";
    say "----|-----|-----";
    my %entries;
    for @sources.sort {
        my $iso-ref = .IO.slurp.lines.grep(/'Table'/)[0];
        s/'#|' .* 'Table'/Table/ with $iso-ref;
        my $role-name = .subst(/'.pm6'$/, '').subst(m{'/'}, '::', :g);
        my $role-name-short = $role-name.split('::')[1];
        my $link = "gen/lib/" ~ $_;
        my $role-ref = "[$role-name-short]($link)";
        my @entries = (require ::($role-name)).^methods.map: {'/' ~ .name};
        say "$iso-ref|$role-ref|{@entries.join: ' '}";
        %entries{$_}.push($role-ref)
            for @entries;
    }
    say '';
    say '## Entry to role mappings';
    say '';
    say "Entry|ISO_32000 Roles";
    say "----|-----";
    say "{.key}|{.value.join: ' '}"
        for %entries.pairs.sort;
}
