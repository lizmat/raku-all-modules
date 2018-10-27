use v6;
use Test;
use lib 'lib';

plan 6;

use Avro; pass "Import Avro";
use Avro::Schema; pass "Import Avro::Schema";
use Avro::Encode; pass "Import Avro::Encode";
use Avro::Decode; pass "Import Avro::Decode";
use Avro::Auxiliary; pass "Import Avro::Auxiliary";
use Avro::DataFile; pass "Import Avro::DataFile";

