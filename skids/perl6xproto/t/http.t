use v6;
use lib './lib';

use Test;

plan 6;

use X::Protocol::HTTP;
ok(1,'We use X::Protocol::HTTP and we are still alive');
lives-ok { X::Protocol::HTTP.new(:404status) }, "Can create an X::Protocol::HTTP";
is X::Protocol::HTTP.new(:404status).message, "HTTP error: 404 -- Not Found", "Simple one-shot has correct message";
is X::Protocol::HTTP.new(:404status).gist, "HTTP error: 404 -- Not Found", "Simple one-shot has correct gist";
is X::Protocol::HTTP.new(:404status :human<Oops>).message, "HTTP error: 404 -- Oops", "One-shot can override human text";
is X::Protocol::HTTP.new(:404status :human<Oops>).Str, "404", "One-shot Str method is just .status";
