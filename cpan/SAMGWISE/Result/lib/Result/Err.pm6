use v6;
use Result;

class Result::Err is Failure does Result {

  method ok(Str:D $local-message) {
    warn ($local-message);
    self.exception.throw;
  }

  method is-ok( --> Bool) {
    False
  }

  method is-err(--> Bool) {
    True
  }
}
