use v6;
run 'wget', '-O', 'projects.json', 'http://ecosystem-api.p6c.org/projects.json';
my $json = slurp 'projects.json';
my @projects = from-json($json).list;
my %local-seen;
for @projects {
    my $url = .<source-url> // .<repo-url>;

    unless defined $url {
        warn "No source-url for $_.perl()";
        next;
    }

    my @chunks = $url.split('/');
    my $local = join '/', @chunks[*-2, *-1];
    $local ~~ s/ '.git' $ //;
    %local-seen{$local} = True;
    run 'git', 'subrepo', 'clone', '-f', $url, $local;
}

# find all dirs of the form author/module and potentially remove them

for dir().grep(*.d).grep(*.basename eq none('_tools', '.git')).map({ dir($_).grep(*.d)}).flat {
    my $local = $_.relative;
    unless %local-seen{$local} {
        say "Would remove $local";
    }
}

