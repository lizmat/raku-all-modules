# Perl6 binding for Notmuchmail


Notmuchmail ( https://notmuchmail.org/ ) is a mail indexation tool. This Perl6 module provides
binding for a limited subset of its API.

## Example

    use v6;
    use Email::Notmuch;
    my $database = Database.new('/home/goneri/Maildir');
    my $query = Query.new($database, 'tag:todo');
    my $messages = $query.search_messages();
    for $messages.all() -> $message {
        say $message.get_header('from');
        $message.add_tag('seen');
        say $message.get_tags().all();
    }

## License

The project uses the GPLv3 or greater and is Copyright 2015-2016 Gonéri Le Bouder <goneri@lebouder.net>
