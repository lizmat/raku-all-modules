use v6;
use lib 'lib';
use Test;
use Acme::Skynet::ChainLabel;

plan 10;

use-ok 'Acme::Skynet::ChainLabel';

{
  my $reminders = ChainLabel.new();
  $reminders.add("remind me at 7 to strech -> 7, strech");
  $reminders.add("at 6 pm remind me to shower -> 6 pm, shower");
  $reminders.add("remind me to run at the robot apocalypse -> the robot apocalypse, run");
  $reminders.learn();

  my @ret = $reminders.get("at 6 pm remind me to let's shower");
  ok @ret[0] eq "6 pm", "Got time";
  ok @ret[1] eq "let's shower", "Got contracted phrase";

  @ret = $reminders.get("at lunch time remind me to feed my cats");
  ok @ret[0] eq "lunch time", "Got time";
  ok @ret[1] eq "feed my cats", "Got original plural phrase";

  @ret = $reminders.get("remind me to feed my cats at lunch time");
  ok @ret[0] eq "lunch time", "Got time";
  ok @ret[1] eq "feed my cats", "Got original plural phrase";
}

{
  my $stabbings = ChainLabel.new();
  $stabbings.add("stab john -> john");
  $stabbings.add("please stab john -> john");
  $stabbings.add("stab john please -> john");
  $stabbings.add("stuart deserves to be stabbed -> stuart");
  $stabbings.learn();

  my @victim = $stabbings.get("carlos deserved to be stabbed");
  ok @victim[0] eq "carlos", "Got Carlos on changed tense";
  @victim = $stabbings.get("stab julie");
  ok @victim[0] eq "julie", "Should exact match with different name";
  @victim = $stabbings.get("carlos deserves to get stabbed");
  ok @victim[0] eq "carlos", "Should be mildly okay with not exact matches";
}

done-testing;
