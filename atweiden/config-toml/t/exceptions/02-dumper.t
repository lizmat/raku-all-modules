use v6;
use lib 'lib';
use Config::TOML;
use Test;

plan 3;

# check keys for validity
subtest
{
    my Int %g{Buf} = Buf.new => 1;
    throws-like {to-toml(%g)}, X::Config::TOML::Dumper::BadKey,
        :message('Sorry, Buf types cannot be represented as TOML keypair key'),
        'Raise exception when key is not of type Str';

    my Int %h{List} = qw<a b c> => 1;
    throws-like {to-toml(%h)}, X::Config::TOML::Dumper::BadKey,
        :message('Sorry, List types cannot be represented as TOML keypair key'),
        'Raise exception when key is not of type Str';

    my WhateverCode $wecode = *-1;
    my Int %i{WhateverCode} = $wecode => -1;
    throws-like {to-toml(%i)}, X::Config::TOML::Dumper::BadKey,
        :message(
            'Sorry, WhateverCode types cannot be represented as TOML keypair key'
        ),
        'Raise exception when key is not of type Str';
}

# check values for validity
subtest
{
    my Any $any = Any.new;
    my Buf $buf = Buf.new;
    my Complex $complex = 2i;
    my Match $match = Config::TOML::Parser::Grammar.parse("i = 1\n");
    my Range $range = 1..10;
    my Regex $regex = /abc/;
    my Signature $signature = :(@prefix, Bool :$extra-brackets);
    my Version $version = v1.0.0;
    my WhateverCode $wecode = *-1;

    my Any %a = :a($any);
    my Buf %b = :b($buf);
    my Complex %c = :c($complex);
    my Match %d = :d($match);
    my Range %e = :e($range);
    my Regex %f = :f($regex);
    my Signature %g = :g($signature);
    my Version %h = :h($version);
    my WhateverCode %i = :i($wecode);

    throws-like {to-toml(%a)}, X::Config::TOML::Dumper::BadValue,
        :message(
            'Sorry, Any types cannot be represented as TOML keypair value'
        ),
        'Raise exception when value is invalid';
    throws-like {to-toml(%b)}, X::Config::TOML::Dumper::BadValue,
        :message(
            'Sorry, Buf types cannot be represented as TOML keypair value'
        ),
        'Raise exception when value is invalid';
    throws-like {to-toml(%c)}, X::Config::TOML::Dumper::BadValue,
        :message(
            'Sorry, Complex types cannot be represented as TOML keypair value'
        ),
        'Raise exception when value is invalid';
    throws-like {to-toml(%d)}, X::Config::TOML::Dumper::BadValue,
        :message(
            'Sorry, Match types cannot be represented as TOML keypair value'
        ),
        'Raise exception when value is invalid';
    throws-like {to-toml(%e)}, X::Config::TOML::Dumper::BadValue,
        :message(
            'Sorry, Range types cannot be represented as TOML keypair value'
        ),
        'Raise exception when value is invalid';
    throws-like {to-toml(%f)}, X::Config::TOML::Dumper::BadValue,
        :message(
            'Sorry, Regex types cannot be represented as TOML keypair value'
        ),
        'Raise exception when value is invalid';
    throws-like {to-toml(%g)}, X::Config::TOML::Dumper::BadValue,
        :message(
            'Sorry, Signature types cannot be represented as TOML keypair value'
        ),
        'Raise exception when value is invalid';
    throws-like {to-toml(%h)}, X::Config::TOML::Dumper::BadValue,
        :message(
            'Sorry, Version types cannot be represented as TOML keypair value'
        ),
        'Raise exception when value is invalid';
    throws-like {to-toml(%i)}, X::Config::TOML::Dumper::BadValue,
        :message(
            'Sorry, WhateverCode types cannot be represented as TOML keypair value'
        ),
        'Raise exception when value is invalid';
}

# check arrays for validity
subtest
{
    my (%valid, %invalid);

    # no mixing integers with floats in the same array
    my @a-valid = 1, 2, 3;
    my @a-invalid = 1.0, 2, 3;
    %valid<valid> = @a-valid;
    %invalid<invalid> = @a-invalid;
    lives-ok {to-toml(%valid)}, 'Valid array is valid';
    throws-like {to-toml(%invalid)}, X::Config::TOML::Dumper::BadArray,
        :message(/'Sorry, invalid TOML array.'/),
        'Raise exception when array contains more than one TOML type';
    (%valid, %invalid) = Empty;

    # no mixing strings with non-strings in the same array
    my @b-valid = qw<a b c>;
    my @b-invalid = |qw<a b c>, 1;
    %valid<valid> = @b-valid;
    %invalid<invalid> = @b-invalid;
    lives-ok {to-toml(%valid)}, 'Valid array is valid';
    throws-like {to-toml(%invalid)}, X::Config::TOML::Dumper::BadArray,
        :message(/'Sorry, invalid TOML array.'/),
        'Raise exception when array contains more than one TOML type';
    (%valid, %invalid) = Empty;

    # Dates and DateTimes may be mixed in the same array
    my $d = Date.new(now);
    my $dt1 = DateTime.now;
    my $dt2 = DateTime.now;
    my @c-valid = $d, $dt1, $dt2;
    my @c-invalid = $d, $dt1, $dt2, 'hello';
    %valid<valid> = @c-valid;
    %invalid<invalid> = @c-invalid;
    lives-ok {to-toml(%valid)}, 'Valid array is valid';
    throws-like {to-toml(%invalid)}, X::Config::TOML::Dumper::BadArray,
        :message(/'Sorry, invalid TOML array.'/),
        'Raise exception when array contains more than one TOML type';
    (%valid, %invalid) = Empty;

    # no mixing Associatives with non-Associatives in the same array
    my @d-valid =
        {:a<alpha>,:b<bravo>,:c<charlie>},
        {:d<delta>,:e<echo>,:f<foxtrot>},
        {:g<golf>,:h<hotel>,:i<india>};
    my @d-invalid =
        {:a<alpha>,:b<bravo>,:c<charlie>},
        [1, 2, 3],
        {:g<golf>,:h<hotel>,:i<india>};
    %valid<valid> = @d-valid;
    %invalid<invalid> = @d-invalid;
    lives-ok {to-toml(%valid)}, 'Valid array is valid';
    throws-like {to-toml(%invalid)}, X::Config::TOML::Dumper::BadArray,
        :message(/'Sorry, invalid TOML array.'/),
        'Raise exception when array contains more than one TOML type';
    (%valid, %invalid) = Empty;

    # no mixing Lists with non-Lists in the same array
    my @e-valid = [0, 1, 2], [3, 4, 5], [6, 7, 8];
    my @e-invalid = [0, 1, 2], {:a<alpha>}, [3, 4, 5];
    %valid<valid> = @e-valid;
    %invalid<invalid> = @e-invalid;
    lives-ok {to-toml(%valid)}, 'Valid array is valid';
    throws-like {to-toml(%invalid)}, X::Config::TOML::Dumper::BadArray,
        :message(/'Sorry, invalid TOML array.'/),
        'Raise exception when array contains more than one TOML type';
    (%valid, %invalid) = Empty;

    my @f-valid = '', '', '';
    my @f-invalid = Str, Str, Str;
    %valid<valid> = @f-valid;
    %invalid<invalid> = @f-invalid;
    lives-ok {to-toml(%valid)}, 'Valid array is valid';
    throws-like {to-toml(%invalid)}, X::Config::TOML::Dumper::BadArray,
        :message(/'Sorry, invalid TOML array.'/),
        'Raise exception when array contains undefined values';
    (%valid, %invalid) = Empty;

    my @g-valid = 0, 0, 0;
    my @g-invalid = Int, Int, Int;
    %valid<valid> = @g-valid;
    %invalid<invalid> = @g-invalid;
    lives-ok {to-toml(%valid)}, 'Valid array is valid';
    throws-like {to-toml(%invalid)}, X::Config::TOML::Dumper::BadArray,
        :message(/'Sorry, invalid TOML array.'/),
        'Raise exception when array contains undefined values';
    (%valid, %invalid) = Empty;

    my @h-valid = 0.0, 0.0, 0.0;
    my @h-invalid = Real, Real, Real;
    %valid<valid> = @h-valid;
    %invalid<invalid> = @h-invalid;
    lives-ok {to-toml(%valid)}, 'Valid array is valid';
    throws-like {to-toml(%invalid)}, X::Config::TOML::Dumper::BadArray,
        :message(/'Sorry, invalid TOML array.'/),
        'Raise exception when array contains undefined values';
    (%valid, %invalid) = Empty;

    my @i-valid = False, False, False;
    my @i-invalid = Bool, Bool, Bool;
    %valid<valid> = @i-valid;
    %invalid<invalid> = @i-invalid;
    lives-ok {to-toml(%valid)}, 'Valid array is valid';
    throws-like {to-toml(%invalid)}, X::Config::TOML::Dumper::BadValue,
        :message('Sorry, undefined Bool types cannot be represented as TOML keypair value'),
        'Raise exception when array contains undefined values';
    (%valid, %invalid) = Empty;

    my @j-valid = Date.new('0000-01-01'), Date.new('0000-01-01'), Date.new('0000-01-01');
    my @j-invalid = Date, Date, Date;
    %valid<valid> = @j-valid;
    %invalid<invalid> = @j-invalid;
    lives-ok {to-toml(%valid)}, 'Valid array is valid';
    throws-like {to-toml(%invalid)}, X::Config::TOML::Dumper::BadArray,
        :message(/'Sorry, invalid TOML array.'/),
        'Raise exception when array contains undefined values';
    (%valid, %invalid) = Empty;

    my @k-valid = DateTime.new(0), DateTime.new(0), DateTime.new(0);
    my @k-invalid = DateTime, DateTime, DateTime;
    %valid<valid> = @k-valid;
    %invalid<invalid> = @k-invalid;
    lives-ok {to-toml(%valid)}, 'Valid array is valid';
    throws-like {to-toml(%invalid)}, X::Config::TOML::Dumper::BadArray,
        :message(/'Sorry, invalid TOML array.'/),
        'Raise exception when array contains undefined values';
    (%valid, %invalid) = Empty;

    my @l-valid = (), (), ();
    my @l-invalid = List, List, List;
    %valid<valid> = @l-valid;
    %invalid<invalid> = @l-invalid;
    lives-ok {to-toml(%valid)}, 'Valid array is valid';
    throws-like {to-toml(%invalid)}, X::Config::TOML::Dumper::BadArray,
        :message(/'Sorry, invalid TOML array.'/),
        'Raise exception when array contains undefined values';
    (%valid, %invalid) = Empty;

    my @m-valid = {}, {}, {};
    my @m-invalid = Associative, Associative, Associative;
    %valid<valid> = @m-valid;
    %invalid<invalid> = @m-invalid;
    lives-ok {to-toml(%valid)}, 'Valid array is valid';
    throws-like {to-toml(%invalid)}, X::Config::TOML::Dumper::BadArray,
        :message(/'Sorry, invalid TOML array.'/),
        'Raise exception when array contains undefined values';
    (%valid, %invalid) = Empty;

    my @n-valid = 1, 1, 1;
    my @n-invalid = Any, Any, Any;
    %valid<valid> = @n-valid;
    %invalid<invalid> = @n-invalid;
    lives-ok {to-toml(%valid)}, 'Valid array is valid';
    throws-like {to-toml(%invalid)}, X::Config::TOML::Dumper::BadArray,
        :message(/'Sorry, invalid TOML array.'/),
        'Raise exception when array contains undefined values';
    (%valid, %invalid) = Empty;
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
