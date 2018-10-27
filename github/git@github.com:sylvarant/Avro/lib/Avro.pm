=begin pod
=head1 Avro
C<Avro> is a minimalistic module that encodes and decodes Avro.
It supports aims to support Binary and JSON decoding/encoding.
=end pod

use v6;
use JSON::Tiny;
use Avro::Schema;
use Avro::DataFile;

module Avro:ver<0.1.1> {

  #======================================
  # Schema parser interface
  #======================================

  proto parse-schema($) is export {*}

  multi sub parse-schema(Str $text) {
    my Avro::Schema $s = parse(from-json($text)); 
    CATCH {
      when X::JSON::Tiny::Invalid  {
        # For reasons beyond my comprehension 
        # Perl JSON doesn't accept JSON strings as input
       return parse($text); 
      }

      default { $_.throw();}
    }
    return $s;
  }

  multi sub parse-schema(Associative $hash) {
    return parse($hash);
  }

  multi sub parse-schema(Positional $array) {
    return parse($array);
  }

}

