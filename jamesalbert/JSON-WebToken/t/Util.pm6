unit package t::Util;

use v6;
use Test;
use JSON::WebToken;


sub test_encode_decode is export {
  my %specs = @_;
  my ($desc, $input, $expects_exception) =
    %specs{qw/desc input expects_exception/};

  my ($claims, $secret, $public_key, $algorithm, $header_fields) =
    $input{qw/claims secret public_key algorithm header_fields/};
  $public_key ||= $secret;

  my $test = sub {
    my $jwt = encode_jwt $claims, $secret, $algorithm, $header_fields;
    return decode_jwt $jwt, $public_key, $algorithm;
  };
  # subtest $desc => sub {
  subtest {
    if (!$expects_exception) {
        my $got = $test();
        is-deeply $got, $claims;
    }
    else {
      {
        $test();
        CATCH {
          default {
            like $_.message, rx/$expects_exception/;
          }
        }
      };
    }
  };
}

=finish
