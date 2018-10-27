use v6;
use Test;
use lib '.';
use t::Util;

plan 4;

ok test_encode_decode({
    desc  => 'simple',
    input => {
        claims => { foo => 'bar' },
        secret => 'secret',
    },
});

ok test_encode_decode({
    desc  => 'with algorithm: HS256',
    input => {
        claims    => { foo => 'bar' },
        secret    => 'secret',
        algorithm => 'HS256',
    },
});

=begin comment
test_encode_decode(
    desc  => 'with algorithm: HS384',
    input => {
        claims    => { foo => 'bar' },
        secret    => 'secret',
        algorithm => 'HS384',
    },
);

test_encode_decode(
    desc  => 'with algorithm: HS512',
    input => {
        claims    => { foo => 'bar' },
        secret    => 'secret',
        algorithm => 'HS512',
    },
);

test_encode_decode(
    desc  => 'with header_fields',
    input => {
        claims       => { foo => 'bar' },
        secret        => 'secret',
        algorithm     => 'XXXXXX',
        header_fields => {
            alg => 'HS256',
        },
    },
);
=end comment
