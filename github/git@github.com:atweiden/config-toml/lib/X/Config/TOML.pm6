use v6;

# X::Config::TOML::DuplicateKeys {{{

class X::Config::TOML::DuplicateKeys
{
    also is Exception;

    has Str:D $.subject is required;
    has Str:D $.text is required;

    method message(::?CLASS:D: --> Str:D)
    {
        my Str:D $message = qq:to/EOF/.trim;
        Sorry, $.subject contains duplicate keys.
        {'-' x 72}
        {$.subject.tc}:
        $.text
        {'-' x 72}
        EOF
    }
}

# end X::Config::TOML::DuplicateKeys }}}
# X::Config::TOML::AOH::DuplicateKeys {{{

class X::Config::TOML::AOH::DuplicateKeys
{
    also is X::Config::TOML::DuplicateKeys;
}

# end X::Config::TOML::AOH::DuplicateKeys }}}
# X::Config::TOML::HOH::DuplicateKeys {{{

class X::Config::TOML::HOH::DuplicateKeys
{
    also is X::Config::TOML::DuplicateKeys;
}

# end X::Config::TOML::HOH::DuplicateKeys }}}
# X::Config::TOML::InlineTable::DuplicateKeys {{{

class X::Config::TOML::InlineTable::DuplicateKeys
{
    also is X::Config::TOML::DuplicateKeys;
}

# end X::Config::TOML::InlineTable::DuplicateKeys }}}
# X::Config::TOML::KeypairLine::DuplicateKeys {{{

class X::Config::TOML::KeypairLine::DuplicateKeys
{
    also is Exception;

    has Str:D $.keypair-line-text is required;
    has @.path is required;

    method message(::?CLASS:D: --> Str:D)
    {
        my Str:D $message = qq:to/EOF/.trim;
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

class X::Config::TOML::AOH
{
    also is Exception;

    has Str:D $.aoh-text is required;
    has @.path is required;

    method message(::?CLASS:D: --> Str:D)
    {
        my Str:D $message = qq:to/EOF/.trim;
        Sorry, arraytable keypath 「{@.path.join(', ')}」 trodden.

        In arraytable:

        {$.aoh-text}
        EOF
    }
}

# end X::Config::TOML::AOH }}}
# X::Config::TOML::AOH::OverwritesHOH {{{

class X::Config::TOML::AOH::OverwritesHOH
{
    also is X::Config::TOML::AOH;

    has Str:D $.aoh-header-text is required;

    method message(::?CLASS:D: --> Str:D)
    {
        my Str:D $message = qq:to/EOF/.trim;
        Sorry, arraytable 「$.aoh-header-text」 has been declared previously
        as regular table in TOML document.

        In arraytable:

        {$.aoh-text}
        EOF
    }
}

# end X::Config::TOML::AOH::OverwritesHOH }}}
# X::Config::TOML::AOH::OverwritesKey {{{

class X::Config::TOML::AOH::OverwritesKey
{
    also is X::Config::TOML::AOH;

    has Str:D $.aoh-header-text is required;

    method message(::?CLASS:D: --> Str:D)
    {
        my Str:D $message = qq:to/EOF/.trim;
        Sorry, arraytable 「$.aoh-header-text」 overwrites existing key in
        TOML document.

        In arraytable:

        {$.aoh-text}
        EOF
    }
}

# end X::Config::TOML::AOH::OverwritesKey }}}
# X::Config::TOML::HOH {{{

class X::Config::TOML::HOH
{
    also is Exception;

    has Str:D $.hoh-text is required;
    has @.path is required;

    method message(::?CLASS:D: --> Str:D)
    {
        my Str:D $message = qq:to/EOF/.trim;
        Sorry, table keypath 「{@.path.join(', ')}」 trodden.

        In table:

        {$.hoh-text}
        EOF
    }
}

# end X::Config::TOML::HOH }}}
# X::Config::TOML::HOH::Seen {{{

class X::Config::TOML::HOH::Seen
{
    also is X::Config::TOML::HOH;

    has Str:D $.hoh-header-text is required;

    method message(::?CLASS:D: --> Str:D)
    {
        my Str:D $message = qq:to/EOF/.trim;
        Sorry, table 「$.hoh-header-text」 has been declared previously in TOML document.

        In table:

        {$.hoh-text}
        EOF
    }
}

# end X::Config::TOML::HOH::Seen }}}
# X::Config::TOML::HOH::Seen::AOH {{{

class X::Config::TOML::HOH::Seen::AOH
{
    also is X::Config::TOML::HOH::Seen;
}

# end X::Config::TOML::HOH::Seen::AOH }}}
# X::Config::TOML::HOH::Seen::Key {{{

class X::Config::TOML::HOH::Seen::Key
{
    also is X::Config::TOML::HOH;

    method message(::?CLASS:D: --> Str:D)
    {
        my Str:D $message = qq:to/EOF/.trim;
        Sorry, table keypath 「{@.path.join(', ')}」 overwrites existing key.

        In table:

        {$.hoh-text}
        EOF
    }
}

# end X::Config::TOML::HOH::Seen::Key }}}
# X::Config::TOML::Keypath {{{

class X::Config::TOML::Keypath
{
    also is Exception;

    has @.path is required;

    method message(::?CLASS:D: --> Str:D)
    {
        my Str:D $message = qq:to/EOF/.trim;
        「{@.path.join(', ')}」
        EOF
    }
}

# end X::Config::TOML::Keypath }}}
# X::Config::TOML::Keypath::AOH {{{

class X::Config::TOML::Keypath::AOH
{
    also is X::Config::TOML::AOH;
}

# end X::Config::TOML::Keypath::AOH }}}
# X::Config::TOML::Keypath::HOH {{{

class X::Config::TOML::Keypath::HOH
{
    also is X::Config::TOML::HOH;
}

# end X::Config::TOML::Keypath::HOH }}}
# X::Config::TOML::BadKeypath::ArrayNotAOH {{{

class X::Config::TOML::BadKeypath::ArrayNotAOH
{
    also is Exception;
}

# end X::Config::TOML::BadKeypath::ArrayNotAOH }}}
# X::Config::TOML::ParseFailed {{{

class X::Config::TOML::ParseFailed
{
    also is Exception;

    has Str:D $.content is required;

    method message(::?CLASS:D: --> Str:D)
    {
        my Str:D $message = qq:to/EOF/.trim;
        Sorry, encountered invalid TOML:

        「{$.content.trim}」
        EOF
    }
}

# end X::Config::TOML::ParseFailed }}}
# X::Config::TOML::ParsefileFailed {{{

class X::Config::TOML::ParsefileFailed
{
    also is Exception;

    has Str:D $.file is required;

    method message(::?CLASS:D: --> Str:D)
    {
        my Str:D $message =
            "Sorry, encountered invalid TOML in file 「$.file」";
    }
}

# end X::Config::TOML::ParsefileFailed }}}
# X::Config::TOML::Dumper::BadKey {{{

class X::Config::TOML::Dumper::BadKey
{
    also is Exception;

    has $.key is required;

    method message(::?CLASS:D: --> Str:D)
    {
        my Str:D $message = 'Sorry, ';
        $message ~= $.key.^name;
        $message ~= ' types cannot be represented as TOML keypair key';
        $message;
    }
}

# end X::Config::TOML::Dumper::BadKey }}}
# X::Config::TOML::Dumper::BadValue {{{

class X::Config::TOML::Dumper::BadValue
{
    also is Exception;

    has $.value is required;

    method message(::?CLASS:D: --> Str:D)
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

class X::Config::TOML::Dumper::BadArray
{
    also is Exception;

    has Positional:D $.array is required;

    method message(::?CLASS:D: --> Str:D)
    {
        my Str:D $message = qq:to/EOF/.trim;
        Sorry, invalid TOML array.

        Got: {$.array.perl}
        EOF
    }
}

# end X::Config::TOML::Dumper::BadArray }}}
# X::Config::TOML::String::EscapeSequence {{{

class X::Config::TOML::String::EscapeSequence
{
    also is Exception;

    has Str:D $.esc is required;

    method message(::?CLASS:D: --> Str:D)
    {
        my Str:D $message = "Sorry, found bad string escape sequence 「$.esc」";
    }
}

# end X::Config::TOML::String::EscapeSequence }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
