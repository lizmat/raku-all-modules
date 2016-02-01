use v6;

unit class Build::Graph;

role Node { ... }
class File { ... }
class Phony { ... }
role Plugin { ... }

role Variable { ... }
class Wildcard { ... }
class Subst { ... }
class Free { ... }

trusts File;

has Node %.nodes;
has Plugin %!plugins;
has Variable %!variables;
has %!seen is Set;
has Int $!counter = 1;

method !expand(%options, Str:D $key, Int:D $count) {
	die "Deep variable recursion detected involving $key" if $count > 20;
	if ($key ~~ / ^ '@(' (<[\w.-]>+) ')' $ /) -> $/ {
		my $variable = %!variables{$1} or die "No such variable $1";
		return $variable.entries.map: { self!expand(%options, $_, $count + 1) };
	}
	elsif ($key ~~ / ^ '%(' (<[\w.,-]>+) ')' $ /) -> $/ {
		my @keys = grep { %options{$_} :exists }, split ',', $1;
		return { @keys.map: { $_ => %options{$_} } };
	}
	else {
		return $key.subst(/ '$(' $<name>=(<[\w.-]>+) ')' /, -> $/ { self!expand(%options, (%options{$<name>} // die "No such argument $<name>"), $count + 1) }, :g);
	}

}

method expand(%options, Str:D @values) {
	return @values.map({ self!expand(%options, $^value, 1) });
}

method lookup-plugin(Str:D $name) {
	return %!plugins{$name} // die "No such plugin $name, only have {%!plugins.keys.join(', ')}";
}

method !get-node(Str:D $name) {
	return %!nodes{$name};
}

method !add-node(Str:D $target, Node:U :$type, Bool() :$override, Str :$add-to, *%args) {
	die "{$type.^name} '$target' already exists in database" if %!nodes{$target} && !$override;
	%!nodes{$target} = $type.new(|%args, :$target, :graph(self));
	self.add-variable($add-to, $target) if $add-to;
	return $target;
}
method !set-node(Str:D $target, Node:D $node) {
	%!nodes{$target} = $node
}

method add-file(Str:D $target, |args) {
	my $node = self!add-node($target, |args, :type(File));
	for %!variables.values.grep(Wildcard) -> $wildcard {
		$wildcard.match($target);
	}
	return;
}

method add-phony(|args) {
	return self!add-node(|args, :type(Phony));
}

method add-wildcard(Str:D $name, *%args) {
	my $wildcard = Wildcard.new(|%args, :graph(self));
	%!variables{$name} = $wildcard;
	$wildcard.match($_) for %!nodes.keys.grep(File);
	$wildcard.match($_) for %!seen.keys;
	return;
}

method add-variable(Str:D $name, *@entries) {
	%!variables{$name} = Free.new(:@entries, :graph(self));
	return;
}

method add-subst(Str:D $name, Str:D $source-name, *%args) {
	my $source = %!variables{$source-name};
	my $sub = Subst.new(|%args, :$name, :graph(self));
	$source.add-subst($sub);
	%!variables{$name} = $sub;
	return;
}

method !nodes-for(Str $name) {
	my %seen;
	sub node-sorter($name, %loop is copy) {
		die "Looping" if %loop{$name} :exists;
		return if %seen{$name}++;
		%loop{$name} = 1;
		if %!nodes{$name} -> $node {
			node-sorter($_, %loop) for $node.dependencies;
			take $node;
		}
		elsif $name.IO.e.not {
			die "Node $name doesn't exist";
		}
	}
	return gather { node-sorter($name, {}) };
}

method _sort-nodes(Str:D $name) {
	self!nodes-for($name).map(*.target);
}

method run(Str:D $name, *%args) {
	for self!nodes-for($name) -> $node {
		$node.run(%args)
	}
	return;
}

method to-hash() {
	my %nodes = %!nodes.keys.map: { $^key => %!nodes{$^key}.to-hash };
	my %variables = %!variables.keys.map: { $^key => %!variables{$^key}.to-hash };
	my @plugins = %!plugins.values.sort(*.counter).map(*.to-hash);
	my @seen = %!seen.keys.sort;
	return { :%nodes, :%variables, :@plugins, :@seen };
}

method !load-subst(%entry, %source, $name) {
	if %entry<substs> {
		self!load-variables(%source, $_) for @(%entry<substs>).grep: { not %!variables{$^subst} :exists };
		return @(%entry<substs>).map: { %!variables{$^subst} };
	}
	return ();
}
method !load-variables(%source, $name) {
	return if %!variables{$name};
	my %entry = %source{$name};
	my @substs = self!load-subst(%entry, %source, $name);
	my Variable:U $class = ::(%entry<type>.tclc);
	my $entries = $class.new(|%entry, :@substs, :graph(self));
	%!variables{$name} = $entries;
}

method from-hash(%input) {
	my %seen := %input<seen>.Set;
	my $ret = self.bless(:%seen);
	for %input<nodes>.kv -> $target, %value {
		my Node:U $class = ::(%value<type>.tclc);
		$ret!set-node($target, $class.new(|%value, :$target, :graph($ret)));
	}
	for %input<variables>.keys -> $name {
		$ret!load-variables(%input<variables>, $name);
	}
	for @( %input<plugins> ) -> %plugin {
		$ret.load-plugin(%plugin<module>, |%plugin);
	}
	return $ret;
}

method load-plugin(Str:D $name, *%options) {
	require ::($name);
	my $plugin = ::($name).new(|%options, :$name, :graph(self), :counter($!counter++));
	die "Plugin collision: {$plugin.name} already exists" if %!plugins{$plugin.name};
	%!plugins{$plugin.name} = $plugin;
	return $plugin;
}

my role Node {
	has Build::Graph:D $.graph is required;
	has Str:D $.target is required;
	has Str:D @.dependencies;
	has Str:D @.action;
	submethod BUILD(:$!graph, :$!target, :@!dependencies, :@!action) { }

	method add-dependencies(@new-deps) {
		@!dependencies.append(@new-deps);
		return;
	}
	method has-to-run() {
		return True;
	}
	method run(%more) {
		if self.has-to-run {
			my %options = (:$!target, :@!dependencies, :source(@!dependencies[0]), |%more);
			my ($command, Str @arguments) = $!graph.expand(%options, @!action);

			my ($plugin-name, $subcommand) = $command.split('/', 2);
			my $plugin = $!graph.lookup-plugin($plugin-name);
			return $plugin.run-command($subcommand, @arguments);
		}
	}
	method to-hash() {
		my %ret = (type => self.WHAT.^name.split('::')[*-1].lc);
		%ret<dependencies> = @!dependencies if @!dependencies;
		%ret<action> = @!action if @!action;
		return %ret;
	}
}

my class Phony does Node {
}

my class File does Node {
	method has-to-run {
		if $!target.IO.e {
			my @files = $.dependencies.grep({ $!graph!Build::Graph::get-node($^dep) ~~ $?CLASS or $^dep.IO.e });
			my $age = $.target.IO.modified;
			return False unless @files.grep({ $^entry.IO.modified > $age && !$^entry.IO.d });
		}
		return True;
	}
}

my role Variable {
	has Build::Graph:D $!graph is required;
	has Str @.entries;
	has Subst @.substs;

	method add-subst(Variable $subst) {
		@!substs.push: $subst;
		for @!entries -> $entry {
			$subst.process($entry);
		}
		return;
	}
	method !add-entry(*@entries) {
		for @entries -> $entry {
			@!entries.push($entry);
			for @!substs -> $subst {
				$subst.process($entry);
			}
		}
		return;
	}
	method to-hash() {
		my %ret = (type => self.WHAT.^name.split('::')[*-1].lc);
		%ret<entries> = @!entries if @!entries;
		%ret<substs> = @!substs.map(*.name) if @!substs;
		return %ret;
	}
}

my class Wildcard does Variable {
	has Regex $.pattern;
	has @!dir;
	submethod BUILD (:$!graph, :@!entries, :@!substs, :$pattern, :$dir) {
		use MONKEY-SEE-NO-EVAL;
		$!pattern = $pattern ~~ Regex ?? $pattern !! EVAL $pattern;
		@!dir = $dir ~~ Positional ?? @($dir) !! $*SPEC.splitdir($dir);
	}
	
	method !match-dir($filename) {
		my ($dirs, $file) = $*SPEC.splitpath($filename)[1,2];
		my @dirs = $*SPEC.splitdir($dirs);
		return if @dirs < @!dir;
		return @dirs.join('/') eq @!dir.join('/');
	}
	method match(Str $filename) {
		if self!match-dir($filename) && $filename.IO.basename ~~  $!pattern {
			self!add-entry($filename);
		}
		return;
	}
	method to-hash {
		my %ret = self.Variable::to-hash();
		%ret<dir> = @!dir;
		%ret<pattern> = $!pattern.perl;
		return %ret;
	}
}

my class Subst does Variable {
	has Str:D $.name is required;
	has Str:D @.trans is required;
	has Str:D @.action is required;
	has Str:D @.dependencies;
	submethod BUILD(:$!name, :$!graph, :@!entries, :@!substs, :@!trans, :@!action, :@!dependencies) { }

	method process(Str $source) {
		my ($command, Str @arguments) = $!graph.expand({ :$source }, @!trans);
		my ($plugin-name, $subcommand) = $command.split('/', 2);
		my $plugin = $!graph.lookup-plugin($plugin-name);
		my $target = $plugin.run-trans($subcommand, @arguments) // die "No such transformation $subcommand in plugin $plugin-name";
		die if $target eq $source;
		$!graph.add-file($target, :dependencies($source, |@!dependencies), :@!action);
		self!add-entry($target);
		return;
	}
	method to-hash() {
		my %ret = self.Variable::to-hash();
		%ret<name> = $!name;
		%ret<trans> = @!trans;
		%ret<action> = @!action;
		%ret<dependencies> = @!dependencies if @!dependencies;
		return %ret;
	}

}

my class Free does Variable {
	submethod BUILD(Build::Graph :$!graph, :@!entries, *@entries) {
		self.add-entry(@entries) if @entries;
	}
}

my role Plugin {
	has Build::Graph:D $.graph is required handles <add-variable add-wildcard>;
	has Str:D $.name is required;
	has Int $.counter is required;

	method run-command(Str $command, Str @arguments) {
		my ($plugin, $subcommand) = $command ~~ / ^ (<[^/]>+) \/ (.*) / ?? ($!graph.lookup-plugin($1), $2) !! (self, $command);
		my &callback = $plugin.get-command($subcommand) or die "No such command $subcommand in {$plugin.name}";
		return callback(|@arguments);
	}
	method run-trans(Str $trans, Str @arguments) {
		my ($plugin, $subtrans) = $trans ~~ / ^ (<[^/]>+) \/ (.*) / ?? ($!graph.lookup-plugin($1), $2) !! (self, $trans);
		my &callback = $plugin.get-trans($subtrans) or die "No such trans $subtrans in {$plugin.name}";
		return callback(|@arguments);
	}

	my multi rel-to-abs(Str $name, $value) {
		return $value if not $value.defined or $value[0] ~~ / \/ /;
		return ( $name ~ '/' ~ $value[0], $value[1 .. *] );
	}

	method get-command(Str $command) {
		...
	}
	method get-trans(Str $trans) {
		...
	}

	method add-file(Str $name, *%args) {
		%args<action> = rel-to-abs($!name, %args<action>);
		$!graph.add-file($name, |%args);
	}
	method add-phony(Str $name, *%args) {
		%args<action> = rel-to-abs($!name, %args<action>);
		$!graph.add-phony($name, |%args);
	}
	method add-subst(Str $sink, Str $source, *%args) {
		%args<trans> = rel-to-abs($!name, %args<trans>);
		%args<action> = rel-to-abs($!name, %args<action>);
		$!graph.add-subst($sink, $source, |%args);
	}
	method to-hash() {
		return {
			module => self.WHAT.^name,
			name   => $!name,
		}
	}

}
