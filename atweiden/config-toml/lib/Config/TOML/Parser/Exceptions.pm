use v6;
unit class Config::TOML::Parser::Exceptions;

class X::Config::TOML::AOH::DuplicateKeys is Exception
{
    has Str $.aoh_text;
    has Str @.keys_seen;

    method message()
    {
        say "Sorry, arraytable contains duplicate keys.";
        print '-' x 72, "\n";
        say "Array table:";
        say $.aoh_text;
        print '-' x 72, "\n";
        say "Keys seen:";
        .say for @.keys_seen.sort».subst(
            /(.*)/,
            -> $/
            {
                state Int $i = 1;
                my Str $replacement = "$i.「$0」";
                $i++;
                $replacement;
            }
        );
        print '-' x 72, "\n";
        say "Keys seen (unique):";
        .say for @.keys_seen.unique.sort».subst(
            /(.*)/,
            -> $/
            {
                state Int $i = 1;
                my Str $replacement = "$i.「$0」";
                $i++;
                $replacement;
            }
        );
    }
}

class X::Config::TOML::HOH::DuplicateKeys is Exception
{
    has Str $.hoh_text;
    has Str @.keys_seen;

    method message()
    {
        say "Sorry, table contains duplicate keys.";
        print '-' x 72, "\n";
        say "Table:";
        say $.hoh_text;
        print '-' x 72, "\n";
        say "Keys seen:";
        .say for @.keys_seen.sort».subst(
            /(.*)/,
            -> $/
            {
                state Int $i = 1;
                my Str $replacement = "$i.「$0」";
                $i++;
                $replacement;
            }
        );
        print '-' x 72, "\n";
        say "Keys seen (unique):";
        .say for @.keys_seen.unique.sort».subst(
            /(.*)/,
            -> $/
            {
                state Int $i = 1;
                my Str $replacement = "$i.「$0」";
                $i++;
                $replacement;
            }
        );
    }
}

class X::Config::TOML::InlineTable::DuplicateKeys is Exception
{
    has Str $.table_inline_text;
    has Str @.keys_seen;

    method message()
    {
        say "Sorry, inline table contains duplicate keys.";
        print '-' x 72, "\n";
        say "Inline table:";
        say $.table_inline_text;
        print '-' x 72, "\n";
        say "Keys seen:";
        .say for @.keys_seen.sort».subst(
            /(.*)/,
            -> $/
            {
                state Int $i = 1;
                my Str $replacement = "$i.「$0」";
                $i++;
                $replacement;
            }
        );
        print '-' x 72, "\n";
        say "Keys seen (unique):";
        .say for @.keys_seen.unique.sort».subst(
            /(.*)/,
            -> $/
            {
                state Int $i = 1;
                my Str $replacement = "$i.「$0」";
                $i++;
                $replacement;
            }
        );
    }
}

class X::Config::TOML::KeypairLine::DuplicateKeys is Exception
{
    has Str $.keypair_line_text;
    has Str @.keypath;

    method message()
    {
        say "Sorry, keypair line contains duplicate key.";
        print '-' x 72, "\n";
        say "Keypair line:";
        say $.keypair_line_text;
        print '-' x 72, "\n";
        say "The key 「{@.keypath.join('.')}」 has already been seen";
    }
}

class X::Config::TOML::AOH is Exception
{
    has Str $.aoh_text;
    has Str @.keypath;

    method message()
    {
        say qq:to/EOF/;
        Sorry, arraytable keypath 「{@.keypath.join('.')}」 trodden.

        In arraytable:

        {$.aoh_text}
        EOF
    }
}

class X::Config::TOML::AOH::OverwritesHOH is X::Config::TOML::AOH
{
    has Str $.aoh_header_text;

    method message()
    {
        say qq:to/EOF/;
        Sorry, arraytable 「$.aoh_header_text」 has been declared previously
        as regular table in TOML document.

        In arraytable:

        {$.aoh_text}
        EOF
    }
}

class X::Config::TOML::AOH::OverwritesKey is X::Config::TOML::AOH
{
    has Str $.aoh_header_text;

    method message()
    {
        say qq:to/EOF/;
        Sorry, arraytable 「$.aoh_header_text」 overwrites existing key in
        TOML document.

        In arraytable:

        {$.aoh_text}
        EOF
    }
}

class X::Config::TOML::HOH is Exception
{
    has Str $.hoh_text;
    has Str @.keypath;

    method message()
    {
        say qq:to/EOF/;
        Sorry, table keypath 「{@.keypath.join('.')}」 trodden.

        In table:

        {$.hoh_text}
        EOF
    }
}

class X::Config::TOML::HOH::Seen is X::Config::TOML::HOH
{
    has Str $.hoh_header_text;

    method message()
    {
        say qq:to/EOF/;
        Sorry, table 「$.hoh_header_text」 has been declared previously in TOML document.

        In table:

        {$.hoh_text}
        EOF
    }
}

class X::Config::TOML::HOH::Seen::AOH is X::Config::TOML::HOH::Seen {*}

class X::Config::TOML::HOH::Seen::Key is X::Config::TOML::HOH
{
    method message()
    {
        say qq:to/EOF/;
        Sorry, table keypath 「{@.keypath.join('.')}」 overwrites existing key.

        In table:

        {$.hoh_text}
        EOF
    }
}

class X::Config::TOML::Keypath is Exception
{
    has Str @.keypath;

    method message()
    {
        say qq:to/EOF/;
        「{@.keypath.join('.')}」
        EOF
    }
}

class X::Config::TOML::Keypath::AOH is X::Config::TOML::AOH {*}
class X::Config::TOML::Keypath::HOH is X::Config::TOML::HOH {*}

class X::Config::TOML::BadKeypath::ArrayNotAOH is Exception {*}

# vim: ft=perl6
