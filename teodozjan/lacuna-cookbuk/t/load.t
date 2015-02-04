use v6;
use Test;


plan 1;

use LacunaCookbuk::Client;

lives_ok {LacunaCookbuk::Client.new}; 
