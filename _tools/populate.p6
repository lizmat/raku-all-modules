use v6;
use JSON::Tiny;
unit sub MAIN(Bool :$delete=True, Bool :$fetch=True, Bool :$ignore-errors);

run <wget -O cpan.json http://modules.perl6.org/s/from:cpan/.json>
    if $fetch;

run 'wget', '-O', 'projects.json', 'http://ecosystem-api.p6c.org/projects.json'
    if $fetch;

my @cpan-projects = (from-json slurp 'cpan.json')<dists>.list;
my %local-seen;

for @cpan-projects -> $project {
    my $local = "cpan/$project<author_id>/" ~ $project<name>.subst(:g, '::', '-');
    %local-seen{$local} = True;
    shell qq:to/EOF/;
        git rm -rf $local
        mkdir -p $local
        wget -O - $project<url> | tar --strip-components=1 -xz --directory $local/
        git add -f $local
        git commit -m 'add or update $local'
        EOF
}

exit;

my $github-source = slurp 'projects.json';
my @projects = from-json($github-source).list;
for @projects {
    my $url = try { .<source-url> // .<repo-url> // .<support><source> };

    unless defined $url {
        warn "No source-url for $_.perl()";
        next;
    }

    my @chunks = $url.split('/');
    my $local = join '/', @chunks[*-2, *-1];
    $local ~~ s/ '.git' $ //;
    my $prefix = $url.contains('gitlab.com') ?? 'gitlab' !! 'github';
    $local = "$prefix/$local";
    %local-seen{$local} = True;
    if $ignore-errors {
       my $proc = run 'git', 'subrepo', 'clone', '-f', $url, $local;
       if $proc.exitcode {
            run 'git', 'reset', 'HEAD';
            run 'git', 'checkout', '.';
        }
    }
    else {
        run 'git', 'subrepo', 'clone', '-f', $url, $local;
    }
}

# find all dirs of the form author/module and potentially remove them

my $removed = 0;

for dir().grep(*.d).grep(*.basename eq none('_tools', '.git'))\ # source
        .map({ dir($_).grep(*.d)}).flat \                       # author
        .map({ dir($_).grep(*.d)}).flat {                       # project
    my $local = $_.relative;
    unless %local-seen{$local} {
        if $delete && $local.IO.e {
            say "Removing $local";
            try run 'git', 'rm', '-rf', $local;
            $removed++;
        }
        else {
            say "Would remove $local";
        }
    }
}

if $removed {
    run 'git', 'commit', '-m', "Remove repos that no longer exist\n\n(This commit was automatically generated)";
}

say "Done updating, now doing a repack to save space";
run 'git', 'repack', '-Ad';
