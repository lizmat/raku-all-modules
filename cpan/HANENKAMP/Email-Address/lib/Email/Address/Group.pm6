use v6;
unit package Email::Address;

use Email::Address::Format :ALL;
use Email::Address::Mailbox;
use Email::Address::Parser :parse-email-address;

role Group does Email::Address::Format {
    has Str $.display-name is rw;
    has Email::Address::Mailbox @.mailbox-list;

    method !parse-if-needed(@addresses, :$parser, :$actions) {
        gather for @addresses {
            when Email::Address::Mailbox { .take }
            default {
                my $mailbox = parse-email-address(~$_, :$parser, :$actions, :rule<mailbox>);
                take Email::Address::Mailbox::Parsed.new(
                    display-name => $mailbox<display-name>,
                    address      => $mailbox<address>,
                    comment      => $mailbox<comment>,
                    original     => $_,
                );
            }
        }
    }

    multi method new(::?CLASS:U:
        Str $display-name,
        *@addresses,
        :$parser = Email::Address::RFC5322-Parser,
        :$actions = Email::Address::RFC5322-Actions,
    ) {
        self.bless:
            :$display-name,
            mailbox-list => self!parse-if-needed(@addresses, :$parser, :$actions),
            ;
    }

    method format(--> Str) {
        my $group = '';

        # quoting can't be used when =?...?...?= mime words are in the name,
        # use obsolete RFC822 display name instead in that case. Since we don't
        # make any effort to understand or decode these, we assume we'll
        # just encounter them as-is but do this one special thing for them
        if has-mime-word($!display-name) {
            $group ~= $!display-name;
        }
        else {
            $group ~= maybe-escape($!display-name);
        }

        $group ~= ': ';
        $group ~= @!mailbox-list.map(*.format).join(', ');
        $group ~= ';';
    }

    method Str(--> Str) { self.format }
    method gist(--> Str) { self.format }
}

my class Group::Parsed does Group {
    has Str $.original;
}

=begin pod

=head1 NAME

Email::Address::Group - representation of a named group of email addresses

=head1 SYNOPSIS

    use Email::Address;

    my $to-header = q:to/END_OF_TO/;
    Presidents: "Peyton Randalf" <peyton
     .randalf@example.com> (Virginia House of
     Burgesses), Henry <henry@example.com>;,
     undisclosed-recipients: ;,
     "More Presidents": adams <a.adams@example.com>;
    END_OF_TO

    my @groups = Email::Address.parse($to-header, :groups);
    for @groups {
        say .format;
    }
    #> Presidents: "Peyton Randalf" <petyon.randalf@example.com> (Virginia House of Burgesses), Henry <henry@example.com>;
    #> undisclosed-recipients: ;
    #> "More Presidents": adams <a.adams@example.com>;

    for @groups[0].mailbox-list {
        say .format;
    }
    #> "Peyton Randalf" <petyon.randalf@example.com> (Virginia House of Burgesses)
    #> Henry <henry@example.com>

    my $other-group = Email::Address::Group.new(
        'All', flat @groups.map({ .mailbox-list }),
    );
    say $other-group;
    #> All: "Peyton Randalf" <peyton.randalf@example.com> (Virginia House of Burgesses), Henry <henry@example.com>, adams <a.adams@example.com>;

=head1 DESCRIPTION

This class encapsulates the tools for storing and manipulating RFC 5322 email address groups.

=head1 METHODS

=head2 method display-name

    has Str $.display-name is rw

This is the name of the email address group.

=head2 method mailbox-list

    has Email::Address::Mailbox @.mailbox-list

This is the list of mailboxes in the group. Groups cannot be nested.

=head2 method format

    method format(--> Str)
    method Str(--> Str)
    method gist(--> Str)

This outputs the email address group with the name and all the mailboxes associated with it.

=head1 VARIANTS

=head2 Email::Address::Group::Parsed

When a group is parsed, this is the actual class returned and it also contains a reference to the original string that was parsed to create the group object.

=head3 method original

    has Str $.original

This is the original string that was parsed to create the email address group.

=end pod
