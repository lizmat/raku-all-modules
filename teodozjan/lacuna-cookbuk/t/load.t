use v6;
use Test;


plan 1;

use LacunaCookbuk::Client;

lives-ok {LacunaCookbuk::Client.new}; 

=begin pod

Even though it may seem it is not doing anything. It gives some info about code errors

=end pod
