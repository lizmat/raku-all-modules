use v6;

# Basic BSON encoding and decoding tools. These exported subs process
# strings and integers.

package BSON {

  class X::BSON::Parse is Exception {
    has $.operation;                      # Operation method
    has $.error;                          # Parse error

    method message () {
      return "\n$!operation\() error: $!error\n";
    }
  }

  class X::BSON::Deprecated is Exception {
    has $.operation;                      # Operation encode, decode
    has $.type;                           # Type to encode/decode

    method message () {
      return "\n$!operation\() error: BSON type $!type is deprecated\n";
    }
  }

  class X::BSON::NYS is Exception {
    has $.operation;                      # Operation encode, decode
    has $.type;                           # Type to encode/decode

    method message () {
      return "\n$!operation\() error: BSON type '$!type' is not (yet) supported\n";
    }
  }

  class X::BSON::ImProperUse is Exception {
    has $.operation;                      # Operation encode, decode
    has $.type;                           # Type to encode/decode
    has $.emsg;                           # Extra message

    method message () {
      return "\n$!operation\() on $!type error: $!emsg";
    }
  }
}
