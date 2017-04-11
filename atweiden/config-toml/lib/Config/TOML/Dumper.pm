use v6;
use Config::TOML::Parser::Grammar;
use X::Config::TOML;
unit class Config::TOML::Dumper;

has Str:D $!toml = '';

method dump(%h --> Str:D)
{
    self!visit(%h);
    $!toml.trim;
}

# credit: https://github.com/emancu/toml-rb
method !visit(%h, :@prefix, Bool :$extra-brackets)
{
    my List:D ($simple-pairs, $nested-pairs, $table-array-pairs) =
        sort-pairs(%h);

    self!print-prefix(@prefix, :$extra-brackets)
        if @prefix && ($simple-pairs || %h.elems == 0);

    self!dump-pairs(
        :$simple-pairs,
        :$nested-pairs,
        :$table-array-pairs,
        :@prefix
    );
}

sub sort-pairs(%h --> List:D)
{
    my Hash:D (@simple-pairs, @nested-pairs, @table-array-pairs);

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
    Hash:D :@simple-pairs!,
    Hash:D :@nested-pairs!,
    Hash:D :@table-array-pairs!,
    :@prefix = ()
)
{
    self!dump-simple-pairs(@simple-pairs);
    self!dump-nested-pairs(@nested-pairs, @prefix);
    self!dump-table-array-pairs(@table-array-pairs, @prefix);
}


method !dump-simple-pairs(Hash:D @simple-pairs)
{
    @simple-pairs.map({
        my Str:D $key = is-bare-key(.keys[0]) ?? .keys[0] !! .keys[0].perl;
        $!toml ~= "$key = {to-toml(.values[0])}\n";
    });
}

method !dump-nested-pairs(Hash:D @nested-pairs, @prefix)
{
    @nested-pairs.map({
        my Str:D $key = is-bare-key(.keys[0]) ?? .keys[0] !! .keys[0].perl;
        self!visit(.values[0], :prefix(|@prefix, $key), :!extra-brackets);
    });
}

method !dump-table-array-pairs(Hash:D @table-array-pairs, @prefix)
{
    for @table-array-pairs -> %table-array-pair
    {
        my Str:D $key = is-bare-key(%table-array-pair.keys[0])
            ?? %table-array-pair.keys[0]
            !! %table-array-pair.keys[0].perl;

        my @aux-prefix = |@prefix, $key;

        for %table-array-pair.values[0].flat -> %p
        {
            self!print-prefix(@aux-prefix, :extra-brackets);
            my List:D ($simple-pairs, $nested-pairs, $table-array-pairs) =
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
    my Str:D $new-prefix = @prefix.join('.');
    $new-prefix = '[' ~ $new-prefix ~ ']' if $extra-brackets;
    $!toml ~= '[' ~ $new-prefix ~ "]\n";
}

sub is-bare-key($key --> Bool:D)
{
    Config::TOML::Parser::Grammar.parse($key, :rule<keypair-key:bare>).so;
}

multi sub is-valid-key(Str:D $key --> Bool:D)
{
    is-bare-key($key)
        || Config::TOML::Parser::Grammar.parse($key.perl, :rule<keypair-key>).so;
}

multi sub is-valid-key($key --> Bool:D)
{
    False;
}

multi sub is-valid-array(@ where {.grep(Str:D).elems == .elems} --> Bool:D)
{
    True;
}

multi sub is-valid-array(@ where {.grep(Int:D).elems == .elems} --> Bool:D)
{
    True;
}

# if the above Int-only signature test fails, Perl6 will test each array
# element against Real. Int ~~ Real, so we grep for Ints
multi sub is-valid-array(
    @ where {.grep(Int).not && .grep(Real:D).elems == .elems}
    --> Bool:D
)
{
    True;
}

multi sub is-valid-array(@ where {.grep(Bool:D).elems == .elems} --> Bool:D)
{
    True;
}

multi sub is-valid-array(
    @ where {.grep(Dateish:D).elems == .elems}
    --> Bool:D
)
{
    True;
}

multi sub is-valid-array(@ where {.grep(List:D).elems == .elems} --> Bool:D)
{
    True;
}

multi sub is-valid-array(
    @ where {.grep(Associative:D).elems == .elems}
    --> Bool:D
)
{
    True;
}

multi sub is-valid-array(@ --> Bool:D)
{
    False;
}

multi sub to-toml(Str:D $s --> Str:D)
{
    $s.perl;
}

multi sub to-toml(Str:U $s)
{
    die X::Config::TOML::Dumper::BadValue.new(:value($s));
}

multi sub to-toml(Real:D $r --> Str:D)
{
    ~$r;
}

multi sub to-toml(Real:U $r)
{
    die X::Config::TOML::Dumper::BadValue.new(:value($r));
}

multi sub to-toml(Bool:D $b --> Str:D)
{
    ~$b.lc;
}

multi sub to-toml(Bool:U $b)
{
    die X::Config::TOML::Dumper::BadValue.new(:value($b));
}

multi sub to-toml(Dateish:D $d --> Str:D)
{
    ~$d;
}

multi sub to-toml(Dateish:U $d)
{
    die X::Config::TOML::Dumper::BadValue.new(:value($d));
}

multi sub to-toml(Associative:D $a --> Str:D)
{
    my Str:D @keypairs;
    $a.map({
        push @keypairs,
            is-bare-key(.key) ?? .key !! .key.perl
            ~ ' = '
            ~ to-toml(.value)
    });
    '{ ' ~ @keypairs.join(', ') ~ ' }';
}

multi sub to-toml(Associative:U $a)
{
    die X::Config::TOML::Dumper::BadValue.new(:value($a));
}

multi sub to-toml(List:D $l --> Str:D)
{
    unless is-valid-array($l)
    {
        die X::Config::TOML::Dumper::BadArray.new(:array($l));
    }

    my Str:D @elements;
    $l.map({ push @elements, to-toml($_) });
    '[ ' ~ @elements.join(', ') ~ ' ]';
}

multi sub to-toml(List:U $l)
{
    die X::Config::TOML::Dumper::BadValue.new(:value($l));
}

multi sub to-toml($value)
{
    die X::Config::TOML::Dumper::BadValue.new(:$value);
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
