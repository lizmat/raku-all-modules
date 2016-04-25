use v6;
use Test;
use lib '.';
use t::Util;
use JSON::WebToken;

plan 1;

class Foo {
  method sign ($algorithm, $message, $key) {
    return 'H*';
    #return pack 'H*' => join \(0), $algorithm, $message, $key;
  }

  method verify ($algorithm, $message, $key, $signature) {
    $signature eq self.sign($algorithm, $message, $key);
  }
}

add_signing_algorithm(Foo.new);

test_encode_decode({
  desc  => 'using custom crypt class Foo',
  input => {
    claims    => { foo => 'bar' },
    secret    => 'secret',
    algorithm => 'Foo',
  },
});
