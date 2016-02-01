use v6;

# for Actions.entry verify entry is limited to one entity
class X::TXN::Parser::Entry::MultipleEntities is Exception
{
    has Str $.entry-text;
    has Int $.number-entities;

    method message()
    {
        say qq:to/EOF/;
        Sorry, only one entity per journal entry allowed, but found
        $.number-entities entities.

        In entry:

        「$.entry-text」
        EOF
    }
}

class X::TXN::Parser::Include is Exception
{
    has Str $.filename;

    method message()
    {
        say qq:to/EOF/;
        Sorry, could not load transaction journal to include at

            「$.filename」

        Transaction journal not found or not readable.
        EOF
    }
}

class X::TXN::Parser::Extends is Exception
{
    has Str $.journalname;

    method message()
    {
        say qq:to/EOF/;
        Sorry, could not locate transaction journal to extend

            「$.journalname」
        EOF
    }
}

# vim: ft=perl6
