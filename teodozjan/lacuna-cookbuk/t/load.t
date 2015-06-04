use v6;
use Test;


plan 1;

use LacunaCookbuk::Client;

lives-ok {LacunaCookbuk::Client.new}; 
