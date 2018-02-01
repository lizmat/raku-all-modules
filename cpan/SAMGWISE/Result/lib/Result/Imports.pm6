use v6;
use Result::OK;
use Result::Err;

module Result::Imports {
  sub OK($value, :$type --> Result::OK)  is export {
    Result::OK.new( :$value :$type )
  }

  sub Error(Str $error --> Result::Err) is export {
    Result::Err.new($error);
  }
}

sub EXPORT() {
  %(
    'Result::OK'  => Result::OK,
    'Result::Err' => Result::Err,
  )
}
