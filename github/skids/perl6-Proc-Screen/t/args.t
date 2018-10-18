use v6;
use lib <blib/lib lib>;
#use Test;  # Recently this started hanging when run by t/test.t

# If we are run directly by testing, pass.
unless +@*ARGS {
#  plan 1;
#  is 1, 1, "Indirect test file args.t parses";
  print Q:to<EOFAKETEST>;
  1..1
  ok 1 - Indirect test file args.t parses
  EOFAKETEST

  exit;
}

# Echo the commandline arguments and then remain running

say @*ARGS.join(" ");

loop {
  sleep 60;
}
