
use v6;

our $PROGRAM-NAME is export	= 'finderror';
our $ISWIN32 is export = $*DISTRO ~~ /mswin32/;

sub getTempFilename() returns Str is export {
	my $filename = $*PID ~ '-' ~ time ~ '-' ~ (rand * 100).floor;

	if $ISWIN32 {
		return "./" ~ $filename;
	}
	else {
		return "/tmp/" ~ $filename;
	}
}

multi sub shellExec(Str $bin, *@args) is export {
	my $proc = run $bin, @args, :out, :err;
	my $output = $proc.out.slurp-rest;
	my $errmsg = $proc.err.slurp-rest;

	return $output ~ "\n" ~ $errmsg;
}

multi sub shellExec(Str $command) is export {
	my $proc = shell $command, :out, :err;
	my $outmsg = $proc.out.slurp-rest;
	my $errmsg = $proc.err.slurp-rest;

	return $outmsg ~ "\n" ~ $errmsg;
}

multi sub shellExec(Str $command, :$quite) is export {
	shell $command ~ " 2>&1 >/dev/null";
}

sub printProgress(Str $prompt, Channel $channel, Str $endflag) is export {
	while True {
		my $obj = $channel.receive();

		if $obj ne $endflag {
			sleep 0.01;
			print "{$prompt}: [" ~ '=' x +$obj ~ "]{+$obj}%\r";
		}
		else {
			print "{$prompt}: [" ~ '=' x 100 ~ "]100% Complete!\n";
			last;
		}
	}
}
