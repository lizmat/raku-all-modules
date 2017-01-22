#!/usr/bin/env perl6

use v6;
use Getopt::Kinoko;
use Readline;
use Terminal::WCWidth;

#`(
------------------------
 !! use Proc::Async
------------------------
/var/lib/startss
| -- $config/
|	  | -- softlink to bin
|     | -- softlink to config
|     | -- logfile
|
| -- ...
------------------------
create
list
ls
start
stop
kill
env
quit
help
version
log
)

class InstanceManager	{ ... };
class Instance 			{ ... };

my %env = %{
	version 	=> '0.0.2',
	ssbinpath	=> '/usr/bin/ss-server',
	varlibpath	=> '/var/lib/startss',
	configpath 	=> '/opt/ssconfig',
	prefix		=> 'config_',
	postfix		=> 'json';
};

my $g-manager = InstanceManager.new(varp => %env<varlibpath>);

&mainLoop();

sub mainLoop() {
	my @promises;
	my @outputs;
	my ($readline, $flag) = (Readline.new, True);

	signal(SIGINT).tap({
		note "\nreceive CTRL+C clean and quit.";
		getManager().clean();
		exit 0;
	});
	$readline.using-history;
	while $flag {
		if $readline.readline("♫|{$*USER.Str}|>") -> $line {
			if $line.trim -> $line {
				$readline.add-history($line);
				try {
					my $getopt = &initializeGetopt();
					my @command = $line.split(/\s+/, :skip-empty);

					$getopt.parse(@command);
					CATCH {
						default {
							note "Unrecognize command: {@command}.";
							say .Str;
							...
						}
					}
				}
			}
		}
	}
}

sub getManager() {
	$g-manager;
}

sub formatTable(@table, $ident) {
	my @width 	= [];
	my @max 	= [];
	my @ret 	= [];

	return [] if +@table == 0;
	for @table -> $line {
		@width.push(@$line.map({wcswidth($_.Str)}));
	}
	@max = 0 xx +@(@table[0]);
	for @width -> $line {
		for ^+@$line -> \col {
			@max[col] = $line.[col] if $line.[col] > @max[col];
		}
	}
	@max = @max.map: { $_ +  $ident };
	for @width Z @table -> ($widths, $line) {
		my @t;
		for ^(+@$line - 1) Z @max[0 .. * - 2] -> (\col, \width) {
			@t.push($line.[col] ~ (" " x (width - $widths.[col])));
		}
		@t.push($line.[* - 1]);
		@ret.push(@t);
	}
	@ret;
}

sub initializeGetopt() {
	my $opts 	= OptionSet.new().insert-normal("h|help=b");
	my $getopt 	= Getopt.new;

	sub gcheck (@names) {
		return sub ($arg) {
			X::Kinoko::Fail.new().throw if $arg.value !(elem) @names;
		}
	}
	sub printHelp($name, $opts, $arg = "") {
		note "Usage:\n {$name}" ~ $opts.usage() ~ " {$arg}\n";
		for $opts.comment(4) -> $line {
			note " {@$line.join("")}\n";
		}
	}
	$opts.set-comment('h', 'print this help message');
	$getopt.push(|[-> @name, $opts {
		my $operator = $opts.deep-clone;
		$operator.insert-front(&gcheck(@name));
		$operator.push-option(
			"c|config=b",
			comment => "list process by config name."
		);
		$operator.push-option(
			"t|table=b",
			comment => "list process in table format.",
		);
		$operator.insert-all(->@args, $opts {
			my $manager = &getManager();

			if $opts<h> {
				printHelp(@args[0].value, $opts, "[id|config-name]*");
			} else {
				@args.shift;
				my @table;
				my &callback = -> $server {@table.push($[ $server.id, $server.bin.abspath,
					$server.config.dirname, $server.config.basename,
					$server.started ?? "RUNNING" !! "READY",
					$server.started ?? $server.status !! "NONE"
				])};

				@table.push($[ "ID", "BIN", "CONFIG", "NAME", "STATUS", "RUN" ]);
				if +@args == 0 {
					$opts<t> ?? $manager.ls(&callback) !! $manager.ls();
				}
				else {
					for @args -> $arg {
						$opts<t> ?? $manager.ls($opts<c> ?? $arg.value.Str !! $arg.value.Int)
						!! $manager.ls($opts<c> ?? $arg.value.Str !! $arg.value.Int);
					}
				}
				if +@table > 1 {
					note "{.join('')}" for formatTable(@table, 2);
					note "";
				}
			}
		});
		@name[0], $operator;
	}(['list', 'ls'], $opts)]);
	$getopt.push(|[-> @name, $opts {
		my $operator = $opts.deep-clone;
		$operator.insert-front(&gcheck(@name));
		$operator.push-option(
			"c|config=b",
			comment => "create process by config path."
		);
		$operator.push-option(
			"b|begin=i",
			comment => "config name begin from <begin>.",
		);
		$operator.insert-all(-> @args, $opts {
			my $manager = &getManager();

			if $opts<h> || +@args == 1 {
				printHelp(@args[0].value, $opts, " [count|config-path]+");
			}
			else {
				@args.shift;
				$opts<c> ?? { $manager.create(%env<ssbinpath>, $_.value.Str) for @args }
				!! $manager.create(@args[0].value.Int, $opts.has-value('b') ?? $opts<b> !! 0);
			}
		});
		(@name[0], $operator);
	}(['create'], $opts)]);
	$getopt.push(|[-> @name, $opts {
		my $operator = $opts.deep-clone;
		$operator.insert-front(&gcheck(@name));
		$operator.push-option(
			"c|config=b",
			comment => "start by config name.",
		);
		$operator.insert-all(-> @args, $opts {
			my $manager = &getManager();

			if $opts<h> {
				printHelp(@args[0].value, $opts, "[id|config-name]*");
			}
			else {
				+@args > 1 ?? { $manager.start($opts<c> ?? .value.Str !! .value.Int) for @args }
				!! $manager.start();
			}
		});
		(@name[0], $operator);
	}(['start'], $opts)]);
	$getopt.push(|[-> @name, $opts {
		my $operator = $opts.deep-clone;
		$operator.insert-front(&gcheck(@name));
		$operator.push-option(
			"c|config=b",
			comment => "stop|kill process by config name.",
		);
		$operator.insert-all(-> @args, $opts {
			my $manager = &getManager();

			if $opts<h> {
				printHelp(@args[0].value, $opts, "[id|config-name]*");
			}
			else {
				+@args == 1 ?? $manager.kill()
				!! { $manager.kill($opts<c> ?? .value.Str !! .value.Int) for @args };
			}
		});
		(@name[0], $operator);
	}(['stop', 'kill'], $opts)]);
	$getopt.push(|[-> @name, $opts {
		my $operator = $opts.deep-clone;
		$operator.insert-front(&gcheck(@name));
		$operator.insert-all(-> @args, $opts {
			my @table;

			if $opts<h> {
				printHelp(@args[0].value, $opts);
			} else {
				@table.push($["key", "value"]);
				for %env.sort>>.kv -> (\key, \value) {
					@table.push($[key, value]);
				}
				note "{.join('')}" for formatTable(@table, 2);
				note "";
			}
		});
		(@name[0], $operator);
	}(['env'], $opts)]);
	$getopt.push(|[-> @name, $opts {
		my $operator = $opts.deep-clone;
		$operator.insert-front(&gcheck(@name));
		$operator.insert-all(-> @args, $opts {
			if $opts<h> {
				printHelp(@args[0].value, $opts);
			} else {
				note "clean and bye!\n";
				getManager().clean();
				exit 0;
			}
		});
		(@name[0], $operator);
	}(['quit'], $opts)]);
	$getopt.push(|[-> @name, $opts {
		my $operator = $opts.deep-clone;
		$operator.insert-front(&gcheck(@name));
		$operator.insert-all(-> @args, $opts {
			if $opts<h> {
				printHelp(@args[0].value, $opts, "[operator]*");
			} else {
				@args.shift;
				my @all = < create list ls start stop kill env quit help version log>;
				if +@args == 0 {
					note @all.join(" ");
				} else {
					for @args -> $arg {
						if $arg.value (elem) @all {
								printHelp($arg.value, $getopt{
									do given $arg.value {
										when "ls" { "list" }
										when "kill" { "stop" }
										default { $arg.value }
									}
								});
						} else {
							note "NOT FOUND";
						}
					}
				}
			}
		});
		(@name[0], $operator);
	}(['help'], $opts)]);
	$getopt.push(|[-> @name, $opts {
		my $operator = $opts.deep-clone;
		$operator.insert-front(&gcheck(@name));
		$operator.insert-all(-> @args, $opts {
			if $opts<h> {
				printHelp(@args[0].value, $opts);
			} else {
				note %env<version>;
			}
		});
		(@name[0], $operator);
	}(['version'], $opts)]);
	$getopt.push(|[-> @name, $opts {
		my $operator = $opts.deep-clone;
		$operator.insert-front(&gcheck(@name));
		$operator.push-option(
			"c|config=b",
			comment => "cat process log by config name.",
		);
		$operator.insert-all(-> @args, $opts {
			if $opts<h> || +@args == 1 {
				printHelp(@args[0].value, $opts, "[id|config-name]");
			} else {
				@args.shift;
				getManager().log($opts<c> ?? @args[0].value.Str !! @args[0].value.Int);
			}
		});
		(@name[0], $operator);
	}(['log'], $opts)]);
	$getopt;
}

class Instance {
	has $.root;		# directory
	has $.config;	# config file
	has $.bin;		# binary file
	has $.log;		# log file
	has @.args;
	has $.id;
	has $!proc;		# proc
	has $!log-fh;
	has $!promise;

	submethod BUILD(:$root, :$config, :$bin, :$log, :$!id, :@!args) {
		$!root = $root.IO;
		$!config = $config.IO;
		$!bin = $bin.IO;
		$!log = $log.IO;
	}

	method createRunInfo() {
		try {
			$!root.mkdir();
			"{$!root.abspath}/{$!config.basename}".IO.symlink($!config.abspath);
			"{$!root.abspath}/{$!bin.basename}".IO.symlink($!bin.abspath);
			$!log.open(:w);
			CATCH {
				default {
					note .Str;
					.resume;
				}
			}
		}
	}

	method createProc() {
		self.createRunInfo();
		unless $!log-fh {
			$!log-fh = $!log.open(:w);
		}
		$!proc = Proc::Async.new($!bin, @!args);
		$!proc.stdout.tap(
			-> $str 	{ $!log-fh.print("STDOUT\@{time}:\n" ~ $str); },
			done 	=>	{ $!log-fh.print("STDOUT\@{time}: SERVER DONE.\n")  ; },
			quit 	=>	{ $!log-fh.print("STDOUT\@{time}: SERVER QUIT.\n")  ; },
			closing =>	{ $!log-fh.print("STDOUT\@{time}: CLOSING ??\n")  ; }
		);
		$!proc.stderr.tap(
			-> $str 	{ $!log-fh.print("STDERR\@{time}:\n" ~ $str); },
			done 	=>	{ $!log-fh.print("STDERR\@{time}: SERVER DONE.\n")  ; },
			quit 	=>	{ $!log-fh.print("STDERR\@{time}: SERVER QUIT.\n")  ; },
			closing =>	{ $!log-fh.print("STDERR\@{time}: CLOSING ??\n")  ; }
		);
		self;
	}

	method run() {
		$!promise = $!proc.start();
		self;
	}

	method promise() {
		$!promise;
	}

	method kill() {
		$!proc.kill(Signal::SIGKILL);
	}

	method status() {
		$!promise.status();
	}

	method started() {
		$!proc.started();
	}

	method clean() {
		try {
			"{$!root.abspath}/{$!config.basename}".IO.unlink();
			"{$!root.abspath}/{$!bin.basename}".IO.unlink();
			$!log.unlink();
			$!root.rmdir();
			CATCH {
				default {
					note .Str;
					...
				}
			}
		}
	}
}

class InstanceManager {
	has $.varp;
	has $!id-counter = 0;
	has @!servers;

	method !getEnv($strname) {
		%env{$strname};
	}

	multi method create(Int $count, Int $beg, @args = []) {
		my ($configp, $prefix) = (self!getEnv('configpath'), self!getEnv('prefix'));
		for ^$count -> $n {
			my ($rootdir, $config) = (
				"{$!varp}/{$prefix}{$beg + $n}",
				"{$configp}/{$prefix}{$beg + $n}.{self!getEnv('postfix')}"
			);
			@!servers.push(Instance.new(
				root 	=> $rootdir,
				config 	=> $config,
				bin 	=> self!getEnv('ssbinpath'),
				log 	=> "{$rootdir}/default.log",
				id 		=> $!id-counter++,
				args 	=> ['-c', $config, | @args]
			).createProc());
		}
	}

	multi method create(Str $bin, Str $config, @args = []) {
		my $rootdir = "{$!varp}/{$config.IO.basename}";

		@!servers.push(Instance.new(
			root 	=> $rootdir,
			config 	=> $config,
			bin 	=> $bin,
			log 	=> "{$rootdir}/default.log",
			id 		=> $!id-counter++,
			args 	=> ['-c', $config, | @args]
		).createProc());
	}

	multi method start() {
		note "NOTHING!" if +@!servers == 0;
		for @!servers -> $server {
			unless $server.started {
				note "START: {$server.id}\@{$server.config.abspath}";
				$server.run();
			}
		}
	}

	multi method start(Int $id) {
		note "NOTHING!" if +@!servers == 0;
		for @!servers -> $server {
			if $server.id == $id && !$server.started {
				note "START: {$server.id}\@{$server.config.abspath}";
				$server.run();
				last;
			}
		}
	}

	multi method start(Str $config) {
		note "NOTHING!" if +@!servers == 0;
		for @!servers -> $server {
			if $server.config.basename eq $config && !$server.started {
				note "START: {$server.id}\@{$server.config.abspath}";
				$server.run();
				last;
			}
		}
	}

	multi method kill() {
		note "NOTHING!" if +@!servers == 0;
		for @!servers -> $server {
			if $server.started {
				note "KILL: {$server.id}\@{$server.config.abspath}";
				$server.kill();
			}
		}
	}

	multi method kill(Str $config) {
		note "NOTHING!" if +@!servers == 0;
		for @!servers -> $server {
			if $server.config.basename eq $config && $server.started {
				note "KILL: {$server.id}\@{$server.config.abspath}";
				$server.kill();
				last;
			}
		}
	}

	multi method kill(Int $id) {
		note "NOTHING!" if +@!servers == 0;
		for @!servers -> $server {
			if $server.id == $id && $server.started {
				note "KILL: {$server.id}\@{$server.config.abspath}";
				$server.kill();
				last;
			}
		}
	}

	multi method ls() {
		note "NOTHING!" if +@!servers == 0;
		for @!servers -> $server {
			note "ID:     {$server.id}";
			note "BIN:    {$server.bin.abspath}";
			note "CONFIG: {$server.config.dirname}/";
			note "NAME:   {$server.config.basename}";
			note "STATUS: {$server.started ?? 'RUNNING' !! 'READY'}";
			note "RUN:    {$server.started ?? $server.status !! 'NONE'}";
			note "";
		}
	}

	multi method ls(Int $id) {
		note "NOTHING!" if +@!servers == 0;
		for @!servers -> $server {
			if $server.id == $id {
				note "ID:     {$server.id}";
				note "BIN:    {$server.bin.abspath}";
				note "CONFIG: {$server.config.dirname}/";
				note "NAME:   {$server.config.basename}";
				note "STATUS: {$server.started ?? 'RUNNING' !! 'READY'}";
				note "RUN:    {$server.started ?? $server.status !! 'NONE'}";
				note "";
				last;
			}
		}
	}

	multi method ls(Int $id, &print-func) {
		note "NOTHING!" if +@!servers == 0;
		for @!servers -> $server {
			if $server.id == $id {
				&print-func($server);
				last;
			}
		}
	}

	multi method ls(Str $config) {
		note "NOTHING!" if +@!servers == 0;
		for @!servers -> $server {
			if $server.config.basename == $config {
				note "ID:     {$server.id}";
				note "BIN:    {$server.bin.abspath}";
				note "CONFIG: {$server.config.dirname}/";
				note "NAME:   {$server.config.basename}";
				note "STATUS: {$server.started ?? 'RUNNING' !! 'READY'}";
				note "RUN:    {$server.started ?? $server.status !! 'NONE'}";
				note "";
				last;
			}
		}
	}

	multi method ls(Str $config, &print-func) {
		note "NOTHING!" if +@!servers == 0;
		for @!servers -> $server {
			if $server.config.basename == $config {
				&print-func($server);
				last;
			}
		}
	}

	multi method ls(&print-func) {
		note "NOTHING!" if +@!servers == 0;
		for @!servers -> $server {
			&print-func($server);
		}
	}

	multi method log(Int $id) {
		note "NOTHING!" if +@!servers == 0;
		for @!servers -> $server {
			if $server.id == $id && $server.started {
				print $server.log.slurp;
				last;
			}
		}
	}

	multi method log(Int $id, &print-func) {
		note "NOTHING!" if +@!servers == 0;
		for @!servers -> $server {
			if $server.id == $id && $server.started {
				&print-func($server.log.slurp);
				last;
			}
		}
	}

	multi method log(Str $config) {
		note "NOTHING!" if +@!servers == 0;
		for @!servers -> $server {
			if $server.config.basename eq $config && $server.started {
				print $server.log.slurp;
				last;
			}
		}
	}

	multi method log(Str $config, &print-func) {
		note "NOTHING!" if +@!servers == 0;
		for @!servers -> $server {
			if $server.config.basename eq $config && $server.started {
				&print-func($server.log.slurp);
				last;
			}
		}
	}

	method clean() {
		for @!servers -> $server {
			$server.kill() if $server.started;
			$server.clean();
		}
	}
}
