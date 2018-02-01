use v6;
use Result;

class Result::OK does Result {

  has $!type;
  has $!value;

  submethod BUILD(:$!value is required, :$!type) {}

  # Type safe return of our value
  method value() {
    if $!value ~~ $!type {
      $!value
    }
    else {
      # make into type exception
      die "Value returned by OK failed type constraint. Expected { $!type.WHAT.perl } but recieved { $!value.WHAT.perl }";
    }
  }

  method ok(Str $) {
    self.value;
  }

  method is-ok( --> Bool) {
    True
  }

  method is-err(--> Bool) {
    False
  }
}
