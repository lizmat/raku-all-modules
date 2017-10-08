use v6;
use Test;
use lib 'lib';

plan 3;

use-ok 'Crust::Builder', 'load dependency Crust::Builder';
use-ok 'Crust::Middleware::Session', 'load dependency Crust::Middleware::Session';
use-ok 'Crust::Middleware::Session::Store::DBIish', 'load module Crust::Middleware::Session::Store::DBIish';

