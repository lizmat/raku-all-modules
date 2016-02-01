unit class Build::Simple;
use fatal;
role Node { ... }
class Phony { ... }
class File { ... }
has Node:D %!nodes;
my subset Filename of Any:D where { $_ ~~ Str|IO::Path };

method add-file(Filename:D $name, :dependencies(@dependency-names), *%args) {
	die "Already exists" if %!nodes{$name} :exists;
	die "Missing dependencies" unless %!nodes{all(@dependency-names)} :exists;
	my Node:D @dependencies = @dependency-names.map: { %!nodes{$^dep} };
	%!nodes{$name} = Build::Simple::File.new(|%args, :name($name.IO), :@dependencies);
	return;
}

method add-phony(Filename:D $name, :dependencies(@dependency-names), *%args) {
	die "Already exists" if %!nodes{$name} :exists;
	die "Missing dependencies" unless %!nodes{all(@dependency-names)} :exists;
	my Node:D @dependencies = @dependency-names.map: { %!nodes{$^dep} };
	%!nodes{$name} = Build::Simple::Phony.new(|%args, :name($name.IO), :@dependencies);
	return;
}

method !nodes-for(Str:D $name) {
	my %seen;
	sub node-sorter($node) {
		node-sorter($_) for $node.dependencies.grep: { !%seen{$^node}++ };
		take $node;
	}
	return gather { node-sorter(%!nodes{$name}) };
}

method _sort-nodes(Str:D $name) {
	self!nodes-for($name).map(*.name.Str);
}

method run(Filename:D $name, *%args) {
	for self!nodes-for(~$name) -> $node {
		$node.run(%args)
	}
	return;
}

my role Node {
	has IO::Path:D $.name is required;
	has Node:D @.dependencies;
	has Sub $.action;
}

class Phony does Node {
	method run (%options) {
		$!action.(:$!name, :@!dependencies, |%options) if $!action;
	}
}

class File does Node {
	has Bool:D $.skip-mkdir = False;
	my sub make-parent(IO::Path $file) {
		my $parent = $file.parent.IO;
		if not $parent.d {
			make-parent($parent);
			$parent.mkdir;
		}
	}

	method run (%options) {
		if $!name.e {
			my $!names = @!dependencies.grep(File).map(*.name.IO);
			my $age = $!name.modified;
			return unless $files.grep: { $^entry.modified > $age && !$^entry.d };
		}
		make-parent($file) unless $!skip-mkdir;
		$!action.(:$!name, :@!dependencies, |%options) if $!action;
	}
}
