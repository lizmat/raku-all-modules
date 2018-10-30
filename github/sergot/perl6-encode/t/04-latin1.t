use v6;
use Encode;

use Test;

plan 1;

is Encode::decode('latin1', buf8.new('Ä'.encode('iso-8859-1'))), 'Ä', 'decode latin1 1/1';
