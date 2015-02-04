use Test;
plan 1;

use Threads;

my @messages;

my $task = async {
    @messages.push("Work started");
    sleep 2;
    @messages.push("Work finished");
};

sleep 1;
$task.kill;
$task.join;

is +@messages, 1, "The second message never got there";
exit;
