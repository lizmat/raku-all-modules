#! /usr/bin/env perl6
use v6;
use Test;

plan 17;

use PowerNap;

use-ok('PowerNap::Controller');
use PowerNap::Controller;

my PowerNap::Controller $controller .= new;
is $controller.so, True, "Create mock controller.";

is $controller.dispatch-verb(PowerNap::Verb::GET, %()).is-err, True, "Default controller returns from Get dispatch";
is $controller.dispatch-verb(PowerNap::Verb::GET, %()).code, 501, "Default controller error is 501";

class TestController does PowerNap::Controller {
  method verb-get(Int :$id is required --> PowerNap::Result) {
    if $id == 0 {
      result-ok 200, %(name =>'tester0', )
    }
    else {
      result-err 404, "No name found for the specified id.";
    }
  }
}

my TestController $names .= new;
is $names.so, True, "Created names controller";
# Good request
given $names.dispatch-verb( PowerNap::Verb::GET, %(id => 0) ) -> $r {
  is $r.is-ok, True, "Response OK";
  is $r.code, 200, "Response 200";
  is $r.ok("No error should be here"), %(name => 'tester0'), "ok monad method returns value";
}

# Good request, nothing exists
given $names.dispatch-verb( PowerNap::Verb::GET, %(id => 100) ) -> $r {
  is $r.is-err, True, "Response ERR";
  is $r.code, 404, "Response 404";
  dies-ok { $r.ok("I expect an errror"), "ok monad method dies" }
}

# Bad request, type error
given $names.dispatch-verb( PowerNap::Verb::GET, %(id => "One") ) -> $r {
  is $r.is-err, True, "Response ERR";
  is $r.code, 501, "Response 501";
  dies-ok { $r.ok("I expect an errror"), "ok monad method dies" }
}

# Bad request, signiture error
given $names.dispatch-verb( PowerNap::Verb::GET, %(not-id => 1) ) -> $r {
  is $r.is-err, True, "Response ERR";
  is $r.code, 501, "Response 501";
  dies-ok { $r.ok("I expect an errror"), "ok monad method dies" }
}
