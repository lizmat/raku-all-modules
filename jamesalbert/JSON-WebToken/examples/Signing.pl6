use JSON::WebToken;

class Foo {
  method sign ($algorithm, $message, $key) {
    return 'H*'; # or whatever the heck your signature is
  }

  method verify ($algorithm, $message, $key, $signature) {
    $signature eq self.sign($algorithm, $message, $key);
  }
}

add_signing_algorithm Foo.new;
