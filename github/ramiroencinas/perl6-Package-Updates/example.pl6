use v6;
use Package::Updates;

my %updates = get-updates();

for %updates.sort(*.key)>>.kv -> ($name, $data) {
  say "Packet name: $name Current: $data<current> New: $data<new>";
}
