use v6;
use lib 'lib';
use Test;
use Acme::Skynet;
my $robotOverlord = Intent.new();

plan 10;

class Wanted {
  has $.route;
  has @.args;

  method new($route, @args) {
    self.bless(:$route, :@args);
  }
}

my $callCount = 0;
my $unique = sub () {
  $callCount++;
  ok $callCount == 1, "Unique should only be called once";
}

$robotOverlord.addKnowledge("unique", $unique);

my $time = sub ($context) {
    ok $context.route eq "time", "Wanted time, got time";
}

# Route commands to actions.
$robotOverlord.addKnowledge("what time is it", $time);
$robotOverlord.addKnowledge("current time", $time);
$robotOverlord.addKnowledge("time please", $time);

my $stab = sub (@args, $context) {
    ok $context.route eq "stab", "Wanted stab, got stab";
    for @args Z $context.args -> ($got, $expected) {
      ok $got eq $expected, $got ~ " should equal " ~ $expected;
    }
}

# Basic support for commands with arguments
$robotOverlord.addKnowledge("stab john -> john", $stab);
$robotOverlord.addKnowledge("stab mike -> mike", $stab);
$robotOverlord.addKnowledge("stuart deserves to be stabbed -> stuart", $stab);
$robotOverlord.addKnowledge("stuart should get stabbed -> stuart", $stab);

my $reminders = sub (@args, $context) {
    ok $context.route eq "reminders", "Wanted reminders, got reminders";
    for @args Z $context.args -> ($got, $expected) {
      ok $got eq $expected, $got ~ " should equal " ~ $expected;
    }
}

$robotOverlord.addKnowledge("remind me at 7 to strech -> 7, strech", $reminders);
$robotOverlord.addKnowledge("at 6 pm remind me to shower -> 6 pm, shower", $reminders);
$robotOverlord.addKnowledge("remind me to run at the robot apocalypse -> the robot apocalypse, run", $reminders);

# Perform some training and learning
$robotOverlord.meditate();

# Provide some input
$robotOverlord.hears("unique");
my $stabVictim = Wanted.new("stab", ("miles",));
$robotOverlord.hears("stab miles", $stabVictim);
my $timeVictim = Wanted.new("time", ());
$robotOverlord.hears("what is the time", $timeVictim);
my $remindersVictim = Wanted.new("reminders", ("the zombie apobalypse","hide"));
$robotOverlord.hears("please remind me to hide at the zombie apobalypse", $remindersVictim);
$robotOverlord.hears("please remind me at the zombie apobalypse to hide", $remindersVictim);

done-testing;
