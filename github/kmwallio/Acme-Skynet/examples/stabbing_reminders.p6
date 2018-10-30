use v6;
use lib 'lib';
use Acme::Skynet;
my $robotOverlord = Intent.new();

my $time = sub () {
    my $time = DateTime.now();
    say sprintf "It is currently %d:%02d", $time.hour, $time.minute;
}

# Route commands to actions.
$robotOverlord.add($time, "what time is it");
$robotOverlord.add($time, "current time");
$robotOverlord.add($time, "time please");

my $stab = sub (@args) {
    say "Stabbed @args[0]";
}

# Basic support for commands with arguments
$robotOverlord.add($stab, "stab john", "john");
$robotOverlord.add($stab, "stab mike", "mike");
$robotOverlord.addKnowledge("stuart deserves to be stabbed -> stuart", $stab);
$robotOverlord.addKnowledge("stuart should get stabbed -> stuart", $stab);

my $reminders = sub (@args) {
  say "Will remind you to '" ~ @args[1] ~ "' at '" ~ @args[0] ~ "'";
}

$robotOverlord.add($reminders, "remind me at 7 to strech", "7", "strech");
$robotOverlord.add($reminders, "at 6 pm remind me to shower", "6 pm", "shower");
$robotOverlord.addKnowledge("remind me to run at the robot apocalypse -> the robot apocalypse, run", $reminders);

# Perform some training and learning
$robotOverlord.meditate();

# Provide some input
$robotOverlord.hears("stab miles"); # Expected output: "Stabbed carlos"
$robotOverlord.hears("what is the time"); # Expected output: the time
$robotOverlord.hears("please remind me to hide at the zombie apocalypse");
$robotOverlord.hears("please remind me at the zombie apocalypse to hide");
