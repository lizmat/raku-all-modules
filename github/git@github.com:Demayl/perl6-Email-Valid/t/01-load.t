use v6;
use Test;

plan 2;
use Email::Valid;
ok "Load", "Loaded";
ok Email::Valid.new, "Constructor works";
