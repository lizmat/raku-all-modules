#!/usr/bin/env perl6
use Test;

my @modules = «Query Rcon 'Version:ver<1.*>' 'Version:ver<2+>'»;

plan +@modules;

for @modules {
    use-ok "Net::Minecraft::$_", $_ or die "Bail out! Can't load $_";
}
