use v6;
use lib <blib/lib lib>;

use Test;

plan 12;

use X::Protocol;
ok(1,'We use X::Protocol and we are still alive');
lives-ok { X::Protocol.new(:404status :protocol<HTTP>) }, "Can create a simple one-off";
dies-ok { X::Protocol.new(:404status) }, "Cannot create a one-off without :protocol()";
is X::Protocol.new(:404status :protocol<HTTP>).message, "HTTP error: 404", "Simple one-shot has correct message";
is X::Protocol.new(:404status :protocol<HTTP>).gist, "HTTP error: 404", "Simple one-shot has correct gist";
is X::Protocol.new(:404status :protocol<HTTP> :human<Oops>).message, "HTTP error: 404 -- Oops", "One-shot use supports human text";
is X::Protocol.new(:404status :protocol<HTTP> :human<Oops>).Str, "404", "One-shot Str method is just .status";
is X::Protocol.new(:404status :protocol<HTTP> :human<Oops>).Numeric, 404, "One-shot Numeric method is .status";
is X::Protocol.new(:404status :protocol<HTTP>).severity, "error", "Default severity is 'error'";
throws-like { X::Protocol.new(:404status :protocol<HTTP>).throw }, X::Protocol, :status(404), :protocol<HTTP>, :severity<error>, :message('HTTP error: 404');
throws-like { X::Protocol.new(:404status :protocol<HTTP>).toss }, X::Protocol, :status(404), :protocol<HTTP>, :severity<error>, :message('HTTP error: 404');
class C is X::Protocol {
    method protocol { "foo" }
    method severity { "failure" }
}
lives-ok { C.new(:404status) }, "Instantiate subclass without providing :protocol";
