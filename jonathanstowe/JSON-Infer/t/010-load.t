#!perl6
use v6;

use Test;

use-ok( 'JSON::Infer', 'JSON::Infer' );
use-ok('JSON::Infer::Class', 'JSON::Infer::Class');
use-ok('JSON::Infer::Attribute','JSON::Infer::Attribute');

use-ok('JSON::Infer::Type', 'JSON::Infer::Type');

use-ok('JSON::Infer::Role::Classes', 'JSON::Infer::Role::Classes');
use-ok('JSON::Infer::Role::Types', 'JSON::Infer::Role::Types');
use-ok('JSON::Infer::Exception', 'JSON::Infer::Exception');

done-testing();
# vim: expandtab shiftwidth=4 ft=perl6
