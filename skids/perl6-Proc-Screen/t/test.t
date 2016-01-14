use v6;
use lib <blib/lib lib>;
use Test::Screen;
use Test;
plan 1;
$test-screen-shell = [$*EXECUTABLE,
                      $*SPEC.catdir($*PROGRAM-NAME.IO.dirname, "args.t"),
                      "arg1", "arg2"];
start-screens;
sleep 4; # TODO ipc to speed this up.
row-matches 0, "arg1 arg2", 'single $test-screen-shell, start-screens and row-matches work.';
