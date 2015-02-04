use v6;
my $json = slurp 'projects.json';
my @projects = from-json($json).list;
for @projects {
    my $url = .<source-url> // .<repo-url>;

    unless defined $url {
        warn "No source-url for $_.perl()";
        next;
    }

    my @chunks = $url.split('/');
    my $local = join '/', @chunks[*-2, *-1];
    $local ~~ s/ '.git' $ //;
    unless $local.IO.d {
        run 'git', 'subrepo', 'clone', $url, $local;
    }
}

run 'git', 'subrepo', 'pull', '--all', '--reclone';
