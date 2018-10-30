use v6;
use Encode;

use Test;

plan 1;

throws-like 'Encode::decode("nyi-encoding", buf8.new(97))', X::Encode::Unknown, message => 'Unknown encoding nyi-encoding.';
