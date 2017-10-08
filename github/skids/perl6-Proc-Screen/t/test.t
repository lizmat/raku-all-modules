use v6;
use lib <blib/lib lib>;
use Test::Screen;
use Test;

if qx{screen -version} ~~ /<!before [4\.0<[01]>|4\.1\D]><[4..9]>\./ {
  plan 1;
}
else {
  plan 1;
  ok 1, "Skipping tests since 'screen' not installed or not in path or < 4.02";
  exit;
}

$test-screen-shell = [$*EXECUTABLE,
                      $*SPEC.catdir($*PROGRAM-NAME.IO.dirname, "args.t"),
                      "arg1", "arg2"];
start-screens;
sleep 4; # TODO ipc to speed this up.
row-matches 0, "arg1 arg2", 'single $test-screen-shell, start-screens and row-matches work.';
