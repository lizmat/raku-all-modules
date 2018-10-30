use v6;

need JsonC;
use JSON::Fast;

# An speed test.
my sub findProyectsFile(Str $prefix?) {
    my (@repos, $target, $pandadir);
    if defined $prefix {
	@repos.push: CompUnit::RepositoryRegistry.repository-for-spec($prefix);
    }
    @repos.append: <site home>.map({CompUnit::RepositoryRegistry.repository-for-name($_)});
    @repos.=grep(*.defined);
    for @repos {
	$target = $_;
	$pandadir = $target.prefix.child('panda');
	try $pandadir.mkdir;
	last if $pandadir.w;
    }
    if $pandadir.w && $pandadir.child('projects.json') -> $_ {
	$_.f && $_;
    } else { Nil }
}

with findProyectsFile() -> $_ {
    say "Testing with $_";
    say "Trying to read with JsonC (raw):";
    {
	my $start = now;
	my @a := JsonC::JSON.new-from-file($_);
	say "Last module is '{@a[@a.elems-1]<description>}";
	say "Parsed in { now - $start }s. @a.elems() projects";
	my $s1 = now;
	my %b = @a.first({$_<name> eq 'DBIish'});
	say "DBDish '%b<description>' located in { now - $s1 }s";
	say "Total time: { now - $start }";
    }
    say "---";
    say "Trying to read with JsonC (unmarshaled):";
    {
	my $start = now;
	my @a := JsonC::JSON.new-from-file($_).Perl;
	say "Last module is '{@a[@a.elems-1]<description>}";
	say "Parsed in { now - $start }s. @a.elems() projects";
	my $s1 = now;
	my %b = @a.first({$_<name> eq 'DBIish'});
	say "DBDish '%b<description>' located in { now - $s1 }s";
	say "Total time: { now - $start }";
    }
    say "---";
    say "Trying to read with JSON::Fast";
    {
	my $start = now;
	my @a := from-json($_.IO.slurp);
	say "Last module is '{@a[@a.elems-1]<description>}";
	say "Parsed in { now - $start }s. @a.elems() projects";
	my $s1 = now;
	my %b = @a.first({$_<name> eq 'DBIish'});
	say "DBDish '%b<description>' located in { now - $s1 }s";
	say "Total time: { now - $start }";
    }
}


