use v6;
unit module X::Config::TOML;

# X::Config::TOML::DuplicateKeys {{{

class DuplicateKeys is Exception
{
    has @.keys-seen is required;
    has Str:D $.subject is required;
    has Str:D $.text is required;

    method message(--> Str:D)
    {
        qq:to/EOF/.trim;
        Sorry, $.subject contains duplicate keys.
        {'-' x 72}
        {$.subject.tc}:
        $.text
        {'-' x 72}
        Keys seen:
        {
            @.keys-seen.sort».subst(
                /(.*)/,
                -> $/
                {
                    state Int:D $i = 1;
                    my Str:D $replacement = "$i.「$0」 \n";
                    $i++;
                    $replacement;
                }
            );
        }
        {'-' x 72}
        Keys seen (unique):
        {
            @.keys-seen.unique.sort».subst(
                /(.*)/,
                -> $/
                {
                    state Int:D $i = 1;
                    my Str:D $replacement = "$i.「$0」 \n";
                    $i++;
                    $replacement;
                }
            );
        }
        EOF
    }
}

# end X::Config::TOML::DuplicateKeys }}}

# X::Config::TOML::AOH::DuplicateKeys {{{

class AOH::DuplicateKeys is DuplicateKeys {*}

# end X::Config::TOML::AOH::DuplicateKeys }}}

# X::Config::TOML::HOH::DuplicateKeys {{{

class HOH::DuplicateKeys is DuplicateKeys {*}

# end X::Config::TOML::HOH::DuplicateKeys }}}

# X::Config::TOML::InlineTable::DuplicateKeys {{{

class InlineTable::DuplicateKeys is DuplicateKeys {*}

# end X::Config::TOML::InlineTable::DuplicateKeys }}}

# X::Config::TOML::KeypairLine::DuplicateKeys {{{

class KeypairLine::DuplicateKeys is Exception
{
    has Str $.keypair-line-text;
    has @.path;

    method message(--> Str:D)
    {
        qq:to/EOF/.trim;
        Sorry, keypair line contains duplicate key.
        {'-' x 72}
        Keypair line:
        $.keypair-line-text
        {'-' x 72}
        The key at path「{@.path.join(', ')}」 has already been seen
        EOF
    }
}

# end X::Config::TOML::KeypairLine::DuplicateKeys }}}

# X::Config::TOML::AOH {{{

class AOH is Exception
{
    has Str $.aoh-text;
    has @.path;

    method message(--> Str:D)
    {
        qq:to/EOF/.trim;
        Sorry, arraytable keypath 「{@.path.join(', ')}」 trodden.

        In arraytable:

        {$.aoh-text}
        EOF
    }
}

# end X::Config::TOML::AOH }}}

# X::Config::TOML::AOH::OverwritesHOH {{{

class AOH::OverwritesHOH is AOH
{
    has Str $.aoh-header-text;

    method message(--> Str:D)
    {
        qq:to/EOF/.trim;
        Sorry, arraytable 「$.aoh-header-text」 has been declared previously
        as regular table in TOML document.

        In arraytable:

        {$.aoh-text}
        EOF
    }
}

# end X::Config::TOML::AOH::OverwritesHOH }}}

# X::Config::TOML::AOH::OverwritesKey {{{

class AOH::OverwritesKey is AOH
{
    has Str $.aoh-header-text;

    method message(--> Str:D)
    {
        qq:to/EOF/.trim;
        Sorry, arraytable 「$.aoh-header-text」 overwrites existing key in
        TOML document.

        In arraytable:

        {$.aoh-text}
        EOF
    }
}

# end X::Config::TOML::AOH::OverwritesKey }}}

# X::Config::TOML::HOH {{{

class HOH is Exception
{
    has Str $.hoh-text;
    has @.path;

    method message(--> Str:D)
    {
        qq:to/EOF/.trim;
        Sorry, table keypath 「{@.path.join(', ')}」 trodden.

        In table:

        {$.hoh-text}
        EOF
    }
}

# end X::Config::TOML::HOH }}}

# X::Config::TOML::HOH::Seen {{{

class HOH::Seen is HOH
{
    has Str $.hoh-header-text;

    method message(--> Str:D)
    {
        qq:to/EOF/.trim;
        Sorry, table 「$.hoh-header-text」 has been declared previously in TOML document.

        In table:

        {$.hoh-text}
        EOF
    }
}

# end X::Config::TOML::HOH::Seen }}}

# X::Config::TOML::HOH::Seen::AOH {{{

class HOH::Seen::AOH is HOH::Seen {*}

# end X::Config::TOML::HOH::Seen::AOH }}}

# X::Config::TOML::HOH::Seen::Key {{{

class HOH::Seen::Key is HOH
{
    method message(--> Str:D)
    {
        qq:to/EOF/.trim;
        Sorry, table keypath 「{@.path.join(', ')}」 overwrites existing key.

        In table:

        {$.hoh-text}
        EOF
    }
}

# end X::Config::TOML::HOH::Seen::Key }}}

# X::Config::TOML::Keypath {{{

class Keypath is Exception
{
    has @.path;

    method message(--> Str:D)
    {
        qq:to/EOF/.trim;
        「{@.path.join(', ')}」
        EOF
    }
}

# end X::Config::TOML::Keypath }}}

# X::Config::TOML::Keypath::AOH {{{

class Keypath::AOH is AOH {*}

# end X::Config::TOML::Keypath::AOH }}}

# X::Config::TOML::Keypath::HOH {{{

class Keypath::HOH is HOH {*}

# end X::Config::TOML::Keypath::HOH }}}

# X::Config::TOML::BadKeypath::ArrayNotAOH {{{

class BadKeypath::ArrayNotAOH is Exception {*}

# end X::Config::TOML::BadKeypath::ArrayNotAOH }}}

# X::Config::TOML::ParseFailed {{{

class ParseFailed is Exception
{
    has Str:D $.content is required;
    method message(--> Str:D)
    {
        "Invalid TOML:\n「$.content」";
    }
}

# end X::Config::TOML::ParseFailed }}}

# X::Config::TOML::ParsefileFailed {{{

class ParsefileFailed is Exception
{
    has Str:D $.file is required;
    method message(--> Str:D)
    {
        "Invalid TOML in file 「$.file」";
    }
}

# end X::Config::TOML::ParsefileFailed }}}

# X::Config::TOML::Dumper::BadKey {{{

class Dumper::BadKey is Exception
{
    has $.key is required;
    method message(--> Str:D)
    {
        'Sorry, '
            ~ $.key.^name
            ~ ' types cannot be represented as TOML keypair key';
    }
}

# end X::Config::TOML::Dumper::BadKey }}}

# X::Config::TOML::Dumper::BadValue {{{

class Dumper::BadValue is Exception
{
    has $.value is required;
    method message(--> Str:D)
    {
        my Str:D $message = 'Sorry, ';
        $message ~= 'undefined ' unless $.value.defined;
        $message ~= $.value.^name;
        $message ~= ' types cannot be represented as TOML keypair value';
        $message;
    }
}

# end X::Config::TOML::Dumper::BadValue }}}

# X::Config::TOML::Dumper::BadArray {{{

class Dumper::BadArray is Exception
{
    has Positional:D $.array is required;
    method message(--> Str:D)
    {
        qq:to/EOF/.trim;
        Sorry, invalid TOML array.

        Got: {$.array.perl}
        EOF
    }
}

# end X::Config::TOML::Dumper::BadArray }}}

# X::Config::TOML::String::EscapeSequence {{{

class String::EscapeSequence is Exception
{
    has Str:D $.esc is required;

    method message(--> Str:D)
    {
        "Sorry, found bad string escape sequence 「$.esc」";
    }
}

# end X::Config::TOML::String::EscapeSequence }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
