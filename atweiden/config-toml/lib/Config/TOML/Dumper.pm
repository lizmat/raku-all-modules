use v6;
use Config::TOML::Parser::Grammar;
use X::Config::TOML;
unit class Config::TOML::Dumper;

has Str $!toml = '';

method dump(%h) returns Str
{
    self!visit(%h);
    $!toml.trim;
}

# credit: https://github.com/emancu/toml-rb
method !visit(%h, :@prefix, Bool :$extra-brackets)
{
    my List ($simple-pairs, $nested-pairs, $table-array-pairs) = sort-pairs(%h);

    self!print-prefix(@prefix, :$extra-brackets)
        if @prefix && ($simple-pairs || %h.elems == 0);

    self!dump-pairs(
        :$simple-pairs,
        :$nested-pairs,
        :$table-array-pairs,
        :@prefix
    );
}

sub sort-pairs(%h) returns List
{
    my Hash (@simple-pairs, @nested-pairs, @table-array-pairs);

    for %h.kv -> $key, $val
    {
        unless is-valid-key($key)
        {
            die X::Config::TOML::Dumper::BadKey.new(:$key);
        }

        if $val ~~ Associative
        {
            push @nested-pairs, %($key => $val);
        }
        elsif $val ~~ List && $val[0] ~~ Associative
        {
            unless is-valid-array($val)
            {
                die X::Config::TOML::Dumper::BadArray.new(:array($val));
            }
            push @table-array-pairs, %($key => $val);
        }
        else
        {
            push @simple-pairs, %($key => $val);
        }
    }

    @simple-pairs .= sort;
    @nested-pairs .= sort;
    @table-array-pairs .= sort;

    (@simple-pairs, @nested-pairs, @table-array-pairs);
}

method !dump-pairs(
    Hash :@simple-pairs!,
    Hash :@nested-pairs!,
    Hash :@table-array-pairs!,
    :@prefix = ()
)
{
    self!dump-simple-pairs(@simple-pairs);
    self!dump-nested-pairs(@nested-pairs, @prefix);
    self!dump-table-array-pairs(@table-array-pairs, @prefix);
}


method !dump-simple-pairs(Hash @simple-pairs)
{
    @simple-pairs.map({
        my Str $key = is-bare-key(.keys[0]) ?? .keys[0] !! .keys[0].perl;
        $!toml ~= "$key = {to-toml(.values[0])}\n";
    });
}

method !dump-nested-pairs(Hash @nested-pairs, @prefix)
{
    @nested-pairs.map({
        my Str $key = is-bare-key(.keys[0]) ?? .keys[0] !! .keys[0].perl;
        self!visit(.values[0], :prefix(|@prefix, $key), :!extra-brackets);
    });
}

method !dump-table-array-pairs(Hash @table-array-pairs, @prefix)
{
    for @table-array-pairs -> %table-array-pair
    {
        my Str $key = is-bare-key(%table-array-pair.keys[0])
            ?? %table-array-pair.keys[0]
            !! %table-array-pair.keys[0].perl;

        my @aux-prefix = |@prefix, $key;

        for %table-array-pair.values[0].flat -> %p
        {
            self!print-prefix(@aux-prefix, :extra-brackets);
            my List ($simple-pairs, $nested-pairs, $table-array-pairs) =
                sort-pairs(%p);
            self!dump-pairs(
                :$simple-pairs,
                :$nested-pairs,
                :$table-array-pairs,
                :prefix(@aux-prefix)
            );
        }
    }
}

method !print-prefix(@prefix, Bool :$extra-brackets)
{
    my Str $new-prefix = @prefix.join('.');
    $new-prefix = '[' ~ $new-prefix ~ ']' if $extra-brackets;
    $!toml ~= '[' ~ $new-prefix ~ "]\n";
}

sub is-bare-key($key) returns Bool
{
    Config::TOML::Parser::Grammar.parse($key, :rule<keypair-key:bare>).so;
}

multi sub is-valid-key(Str:D $key) returns Bool
{
    is-bare-key($key)
        || Config::TOML::Parser::Grammar.parse($key.perl, :rule<keypair-key>).so;
}

multi sub is-valid-key($key) returns Bool
{
    False;
}

multi sub is-valid-array(@ where {.grep(Str:D).elems == .elems}) returns Bool
{
    True;
}

multi sub is-valid-array(@ where {.grep(Int:D).elems == .elems}) returns Bool
{
    True;
}

# if the above Int-only signature test fails, Perl6 will test each array
# element against Real. Int ~~ Real, so we grep for Ints
multi sub is-valid-array(
    @ where {.grep(Int).not && .grep(Real:D).elems == .elems}
) returns Bool
{
    True;
}

multi sub is-valid-array(@ where {.grep(Bool:D).elems == .elems}) returns Bool
{
    True;
}

multi sub is-valid-array(
    @ where {.grep(Dateish:D).elems == .elems}
) returns Bool
{
    True;
}

multi sub is-valid-array(@ where {.grep(List:D).elems == .elems}) returns Bool
{
    True;
}

multi sub is-valid-array(
    @ where {.grep(Associative:D).elems == .elems}
) returns Bool
{
    True;
}

multi sub is-valid-array(@) returns Bool
{
    False;
}

multi sub to-toml(Str:D $s) returns Str
{
    $s.perl;
}

multi sub to-toml(Str:U $s) returns Str
{
    die X::Config::TOML::Dumper::BadValue.new(:value($s));
}

multi sub to-toml(Real:D $r) returns Str
{
    ~$r;
}

multi sub to-toml(Real:U $r) returns Str
{
    die X::Config::TOML::Dumper::BadValue.new(:value($r));
}

multi sub to-toml(Bool:D $b) returns Str
{
    ~$b.lc;
}

multi sub to-toml(Bool:U $b) returns Str
{
    die X::Config::TOML::Dumper::BadValue.new(:value($b));
}

multi sub to-toml(Dateish:D $d) returns Str
{
    ~$d;
}

multi sub to-toml(Dateish:U $d) returns Str
{
    die X::Config::TOML::Dumper::BadValue.new(:value($d));
}

multi sub to-toml(Associative:D $a) returns Str
{
    my Str @keypairs;
    $a.map({
        push @keypairs,
            is-bare-key(.key) ?? .key !! .key.perl
            ~ ' = '
            ~ to-toml(.value)
    });
    '{ ' ~ @keypairs.join(', ') ~ ' }';
}

multi sub to-toml(Associative:U $a) returns Str
{
    die X::Config::TOML::Dumper::BadValue.new(:value($a));
}

multi sub to-toml(List:D $l) returns Str
{
    unless is-valid-array($l)
    {
        die X::Config::TOML::Dumper::BadArray.new(:array($l));
    }

    my Str @elements;
    $l.map({ push @elements, to-toml($_) });
    '[ ' ~ @elements.join(', ') ~ ' ]';
}

multi sub to-toml(List:U $l) returns Str
{
    die X::Config::TOML::Dumper::BadValue.new(:value($l));
}

multi sub to-toml($value)
{
    die X::Config::TOML::Dumper::BadValue.new(:$value);
}

# vim: ft=perl6 fdm=marker fdl=0 nowrap
