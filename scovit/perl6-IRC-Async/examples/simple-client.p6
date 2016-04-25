#!perl6

use IRC::Async;

my $channel = "#channel";
my $a = IRC::Async.new(
    :host<127.0.0.1>
    :channels($channel)
);

# my $stdinput = $*IN.Supply;
# Workaround for MoarVM/issues/165
my $stdinput = {my $insupplier=Supplier.new;use Readline;start {my $rl = Readline.new;while my $msg = $rl.readline("") {$insupplier.emit($msg);}}; $insupplier.Supply; }();

await $a.connect.then(
    {
	my $chat     = .result;
	my $text     = $chat.Supply.grep({ $_ ~~ :command("PRIVMSG") });

	react {
	    whenever $text     -> $e {
		say "{$e<who><nick>}: {$e<params>[1]}";
	    }
	    whenever $stdinput -> $e {
                if ($e eq "\\quit") {
                   await $chat.print("QUIT :My job is done\n");
                   $chat.close;
                   exit;
                };
		$chat.privmsg($channel, $e);
	    }
	}
    });
