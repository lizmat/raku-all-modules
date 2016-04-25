use v6;
unit module X::Config::TOML;

# X::Config::TOML::DuplicateKeys {{{

class DuplicateKeys is Exception
{
    has @.keys-seen is required;
    has Str $.subject is required;
    has Str $.text is required;

    method message() returns Str
    {
        my Str $help-text = qq:to/EOF/;
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
                    state Int $i = 1;
                    my Str $replacement = "$i.「$0」 \n";
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
                    state Int $i = 1;
                    my Str $replacement = "$i.「$0」 \n";
                    $i++;
                    $replacement;
                }
            );
        }
        EOF
        $help-text.trim;
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

    method message() returns Str
    {
        my Str $help-text = qq:to/EOF/;
        Sorry, keypair line contains duplicate key.
        {'-' x 72}
        Keypair line:
        $.keypair-line-text
        {'-' x 72}
        The key at path「{@.path.join(', ')}」 has already been seen
        EOF
        $help-text.trim;
    }
}

# end X::Config::TOML::KeypairLine::DuplicateKeys }}}

# X::Config::TOML::AOH {{{

class AOH is Exception
{
    has Str $.aoh-text;
    has @.path;

    method message() returns Str
    {
        my Str $help-text = qq:to/EOF/;
        Sorry, arraytable keypath 「{@.path.join(', ')}」 trodden.

        In arraytable:

        {$.aoh-text}
        EOF
        $help-text.trim;
    }
}

# end X::Config::TOML::AOH }}}

# X::Config::TOML::AOH::OverwritesHOH {{{

class AOH::OverwritesHOH is AOH
{
    has Str $.aoh-header-text;

    method message() returns Str
    {
        my Str $help-text = qq:to/EOF/;
        Sorry, arraytable 「$.aoh-header-text」 has been declared previously
        as regular table in TOML document.

        In arraytable:

        {$.aoh-text}
        EOF
        $help-text.trim;
    }
}

# end X::Config::TOML::AOH::OverwritesHOH }}}

# X::Config::TOML::AOH::OverwritesKey {{{

class AOH::OverwritesKey is AOH
{
    has Str $.aoh-header-text;

    method message() returns Str
    {
        my Str $help-text = qq:to/EOF/;
        Sorry, arraytable 「$.aoh-header-text」 overwrites existing key in
        TOML document.

        In arraytable:

        {$.aoh-text}
        EOF
        $help-text.trim;
    }
}

# end X::Config::TOML::AOH::OverwritesKey }}}

# X::Config::TOML::HOH {{{

class HOH is Exception
{
    has Str $.hoh-text;
    has @.path;

    method message() returns Str
    {
        my Str $help-text = qq:to/EOF/;
        Sorry, table keypath 「{@.path.join(', ')}」 trodden.

        In table:

        {$.hoh-text}
        EOF
        $help-text.trim;
    }
}

# end X::Config::TOML::HOH }}}

# X::Config::TOML::HOH::Seen {{{

class HOH::Seen is HOH
{
    has Str $.hoh-header-text;

    method message() returns Str
    {
        my Str $help-text = qq:to/EOF/;
        Sorry, table 「$.hoh-header-text」 has been declared previously in TOML document.

        In table:

        {$.hoh-text}
        EOF
        $help-text.trim;
    }
}

# end X::Config::TOML::HOH::Seen }}}

# X::Config::TOML::HOH::Seen::AOH {{{

class HOH::Seen::AOH is HOH::Seen {*}

# end X::Config::TOML::HOH::Seen::AOH }}}

# X::Config::TOML::HOH::Seen::Key {{{

class HOH::Seen::Key is HOH
{
    method message() returns Str
    {
        my Str $help-text = qq:to/EOF/;
        Sorry, table keypath 「{@.path.join(', ')}」 overwrites existing key.

        In table:

        {$.hoh-text}
        EOF
        $help-text.trim;
    }
}

# end X::Config::TOML::HOH::Seen::Key }}}

# X::Config::TOML::Keypath {{{

class Keypath is Exception
{
    has @.path;

    method message() returns Str
    {
        my Str $help-text = qq:to/EOF/;
        「{@.path.join(', ')}」
        EOF
        $help-text.trim;
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

# vim: ft=perl6 fdm=marker fdl=0
