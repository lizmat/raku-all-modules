#!/usr/bin/env perl6

use v6;
use lib './private';

use Errno;
use Parser;
use PubFunc;
use Formater;
use Downloader;
use ErrnoFinder;
use LocalConfig;
use Getopt::Kinoko;
use Getopt::Kinoko::Exception;

# ~~~~~
my $update;
my $list;
my $find;
my $local-config = LocalConfig.new();

# initialize OptionSet
my $optset = OptionSet.new();

# common
$optset.insert-normal("h|help=b;v|version=b;");
$optset.insert-radio("s|stdc-errno=b;l|win32-lasterror=b;");
$optset.insert-multi("socket-error-uri=s;system-error-uri=s;include-directory=s;errno-include=s");

# update
$update = $optset.deep-clone;
$update.insert-front(get-front("update"));
$update.insert-radio("use-wget=b;use-curl=b;use-lwp=b;command=s", :force);

# list and find common
$optset.insert-radio("system=b;socket=b;");
$optset.insert-multi("e|errno=b;n|number=b;c|comment=b;show-all=b");

$list = $optset.deep-clone;

# list
$list.insert-front(get-front("list"));
$list.append-options("start=i;end=i");
$list.set-value("start", 0);
$list.set-value("end", 0); # start and end only use for *list*
# find
$find = $optset;

# find
$find.append-options("r|regex=b;w|whole-word=b");
$find.insert-front(get-front("find"));

# call getopt
my $getopt = Getopt.new(:gnu-style);

$getopt.push("update", $update);
$getopt.push("list", $list);
$getopt.push("find", $find);
main($getopt.parse()); # different way from function interface [getopt]

# MAIN
sub main(@args) {
# @args => [operator { find | list | update }, ... args ...]
# [... args ...] => [hexadecimal decimal string]
	my $operator = $getopt.current();

	if $operator eq "" || $operator !~~ /find||list||update/ {
		print-help($getopt, "");
		exit 1;
	}

	my $optset = $getopt{$getopt.current()};

	if $optset<version> {
		print-version();
		exit(0) unless $optset<help>;
	}

	if $optset<help> {
		print-help($getopt, $operator);
		exit 0;
	}

	# ignore first argument
	@args.shift;

	synchronization-config($optset, $local-config);

	my $formater = Formater::Normal.new(optset => $optset);

	# executable operator
	given $operator {
		when /find|list/ {
			my @data = get-data($optset);

			if $operator eq "find" {
				if +@args == 0 {
					fail("Find operator need condition.");
				}
				-> {
					my Str @columns = [];

					@columns.push: "errno" if $optset<errno>;
					@columns.push: "number" if $optset<number>;
					@columns.push: "comment" if $optset<comment>;

					if +@columns == 0 {
						@columns.append: ["errno", "number", "comment"];
					}

					if $optset{'regex'} {
						for @data -> $errno {
							if matchRegex($errno, @columns, @args) {
								say $formater.format($errno);
							}
						}
					}
					elsif $optset{'whole-word'} {
						for @data -> $errno {
							# argument may be a number
							if $optset{'number'} {
								if matchNumber($errno, @args) {
									say $formater.format($errno);
									next;
								}
							}
							if matchWholeWord($errno, @columns, @args) {
								say $formater.format($errno);
							}
						}
					}
					else {
						for @data -> $errno {
							if matchFindpattern($errno, @columns, @args) {
								say $formater.format($errno);
							}
						}
					}
				}();
			}
			else {
				-> {
					my ($s, $e) = ($optset{'start'}, $optset{'end'});

					$s = 1 if $s == 0;
					$e = ($e == 0) ?? @data.end !! ($e > @data.end ?? @data.end !! $e);
					loop (my $i = $s;$i <= $e;$i++) {
						say $formater.format(@data[$i]);
					}
				}();
			}
		}
		when /update/ {
			update-data($optset);
		}
	}
}

# match function

sub matchRegex(Errno $errno, @columns, @patterns) {
	for @columns -> $column {
		my $string := $errno."$column"();

		for @patterns -> $pattern {
			if $string ~~ /"{$pattern}"/ {
				return True;
			}
		}
	}
	return False;
}

sub matchNumber(Errno $errno, @patterns) {
	for @patterns -> $pattern {
		try {
			my Int $value = $pattern.Int.base(10);

			if $value == $errno.number {
				return True;
			}
		}
	}
	return False;
}

sub matchWholeWord(Errno $errno, @columns, @patterns) {
	for @columns -> $column {
		my \string := $errno."$column"();

		for @patterns -> $pattern {
			if string eq $pattern {
				return True;
			}
		}
	}
	return False;
}

sub matchFindpattern(Errno $errno, @columns, @patterns) {
	for @columns -> $column {
		my \string := $errno."$column"();

		for @patterns -> $pattern {
			if string.index($pattern) {
				return True;
			}
		}
	}
	return False;
}


# front callback
sub get-front(Str $name) {
	sub check(Argument $arg) {
		if ~$arg.value ne $name {
			X::Kinoko::Fail.new().throw();
		}
 	}
	return &check;
}

# get downloader
sub get-downloader(OptionSet \optset) {
	if optset{'use-wget'} {
		return Downloader::Command.new(command => 'wget');
	}
	elsif optset{'use-curl'} {
		return Downloader::Command.new(command => 'curl');
	}
	elsif optset{'use-lwp'} {
		return Downloader::Module.new();
	}
	elsif optset.has-value('command') {
		return Downloader::Command.new(command => optset{'command'});
	}
	else {
		return Downloader.new();
	}
 }

 # synchronization config
 sub synchronization-config(OptionSet \optset, LocalConfig \local-config) {
	 my @table = [
		 'system-error-uri',
		 'socket-error-uri',
		 'errno-include',
		 'include-directory',
	 ];

	 local-config.read-config();

	 for @table -> $key {
		 if optset.has-value($key) {
			 local-config.hash-way-operator($key, optset{$key});
		 }
		 else {
			 optset.set-value($key, local-config.hash-way-operator($key));
		 }
	 }

	 # write back
	 local-config.update-config();
 }

# prepare data
sub get-data(OptionSet \optset) {
	my ($errno, $win32) = (optset{'stdc-errno'}, optset{'win32-lasterror'});

	if !$errno && !$win32 {
		$errno = $win32 = True;
	}

	my @ret = [];

	if $errno {
		@ret.append: get-errno-data(optset);
	}

	if $win32 {
		@ret.append: get-win32-error-data(optset);
	}

	return @ret;
}

sub update-data(OptionSet \optset) {
	my ($errno, $win32) = (optset{'stdc-errno'}, optset{'win32-lasterror'});

	if !$errno && !$win32 {
		$errno = $win32 = True;
	}

	if $errno {
		say "update errno data";
		update-errno-data(optset);
		say "update errno data ok";
	}

	if $win32 {
		#my ($need-system, $need-socket) = (optset{'system'}, optset{'socket'});
		say "update win32 data";
		update-win32-error-data(optset, :system, :socket);
		say "update win32 data ok";
	}
}

# prepare errno data
sub get-errno-data(OptionSet \optset) {
	my $epath = errnoCachePath();

	if $epath.IO ~~ :r {
		return Parser.parse(Downloader::Cache.get($epath));
	}
	else {
		note "Please update data first.";
		exit -1;
	}
}

sub update-errno-data(OptionSet \optset) {
	my $channel = Channel.new();

	start {
		$channel.send("0");
		my $ef = ErrnoFinder.new(path => optset{'include-directory'});

		$channel.send("5");
		$ef.find(optset{'errno-include'});

		$channel.send("50");
		writeCache(errnoCachePath(), $ef.result());
		$channel.send("100");
		$channel.send("end");
	}
	printProgress("\t", $channel, "end");
	$channel.close();
}

# prepare win32 error data
sub get-win32-error-data(OptionSet \optset) {
	my ($need-system, $need-socket) = (optset{'system'}, optset{'socket'});

	if !$need-system && !$need-socket {
		$need-system = $need-socket = True;
	}

	my @rets = [];

	if $need-system {
		my $spath = win32ErrorSystemCachePath();

		if $spath.IO ~~ :r {
			@rets.append: Parser.parse(Downloader::Cache.get($spath));
		}
		else {
			note "Please update data first.";
			exit -1;
		}
	}
	if $need-socket {
		my $spath = win32ErrorSocketCachePath();

		if $spath.IO ~~ :r {
			@rets.append: Parser.parse(Downloader::Cache.get($spath));
		}
		else {
			note "Please update data first.";
			exit -1;
		}
	}

	return @rets;
}

sub update-win32-error-data(OptionSet \optset, :$system, :$socket) {
	if ?$system {
		my $channel = Channel.new();
		my $progress = 0;
		my $downloader = get-downloader(optset);

		start {
			$channel.send("0");
			my @ret = Parser::Win32SystemUrl.parse($downloader.get(optset{'system-error-uri'}));
			my @ps = [];

			$progress = 5;
			$channel.send($progress);
			cleanCache(win32ErrorSystemCachePath());

			for @ret -> $mslink {
				@ps.push: start {
					writeCache(
						win32ErrorSystemCachePath(),
						Parser::Win32System.parse($downloader.get($mslink))
					);
					$progress += (95 / +@ret).floor;
					$channel.send($progress);
				};
			}
			await Promise.allof(@ps);
			$channel.send("100");
			$channel.send("end");
		}
		printProgress("\t", $channel, "end");
		$channel.close();
	}
	if ?$socket {
		my $channel = Channel.new();

		start {
			$channel.send("5");
			my @ret = Parser::Win32Socket.parse(get-downloader(optset).get(optset{'socket-error-uri'}));

			$channel.send("50");
			writeCache(win32ErrorSocketCachePath(), @ret);
			$channel.send("100");
			$channel.send("end");
		}
		printProgress("\t", $channel, "end");
		$channel.close();
	}
}

# help function
sub print-help(Getopt $getopt, $current) {
	my $help = "Usage:\n";

	for $getopt.keys -> $key {
		if $current eq $key || $current eq "" {
			$help ~= $*PROGRAM-NAME ~ " $key " ~ $getopt{$key}.usage ~ "\n";
		}
	}

	print $help;
}

sub print-version() {
	say "version 0.1.1, create by Loren.";
}
