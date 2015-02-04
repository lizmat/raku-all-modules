use v6;
use Encode;

use Test;

plan 1;

is Encode::decode('latin1', buf8.new('A'.encode('ascii'))), 'A', 'decode ascii 1/1';
