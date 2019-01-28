use v6;
unit class Email::Address:ver<0.2>:auth<github:zostay>;

use Email::Address::Group;
use Email::Address::Mailbox;
use Email::Address::Parser :parse-email-address;

class GLOBAL::X::Email::Address is Exception { }

class GLOBAL::X::Email::Address::AdHoc is X::Email::Address {
    has $!message;

    multi method new(Str:D $message) {
        self.bless(:$message);
    }
}

class GLOBAL::X::Email::Address::Syntax is X::Email::Address {
    has $.part;
    has $.input;

    method message(--> Str) {
        qq[Syntax error in string "{$!input.trans('"' => '\"')}" while parsing $!part];
    }
}

my sub build-addr-spec(
    %spec,
    :$addr-spec-class = AddrSpec::Parsed,
) {
    $addr-spec-class.new(
        local-part => .<local-part>,
        domain     => .<domain>,
        original   => .<original>,
    ) with %spec;
}

my sub build-mailbox(
    %spec,
    :$mailbox-class = Mailbox::Parsed,
    :$addr-spec-class = AddrSpec::Parsed,
) {
    $mailbox-class.new(
        display-name => .<display-name>,
        address      => build-addr-spec(.<address>, :$addr-spec-class),
        comment      => .<comment> // Str,
        original     => .<original>,
    ) given %spec;
}

my sub build-group(
    %spec,
    :$group-class = Group::Parsed,
    :$mailbox-class = Mailbox::Parsed,
    :$addr-spec-class = AddrSpec::Parsed,
) {
    $group-class.new(
        display-name => .<display-name>,
        mailbox-list => .<mailbox-list>.map({ build-mailbox($_, :$mailbox-class, :$addr-spec-class) }),
        original     => .<original>,
    ) with %spec;
}

multi method parse(::?CLASS:U: Str $str, :$mailboxes!, :$parser = RFC5322-Parser, :$actions = RFC5322-Actions --> Seq) {
    gather for parse-email-address($str, :$parser, :$actions, :rule<mailbox-list>) {
        take build-mailbox($_);
    }
}

multi method parse(::?CLASS:U: Str $str, :$groups!, :$parser = RFC5322-Parser, :$actions = RFC5322-Actions --> Seq) {
    gather for parse-email-address($str, :$parser, :$actions, :rule<group-list>) {
        take build-group($_);
    }
}

multi method parse(::?CLASS:U: Str $str, :$addresses!, :$parser = RFC5322-Parser, :$actions = RFC5322-Actions --> Seq) {
    gather for parse-email-address($str, :$parser, :$actions, :rule<address-list>) {
        when so .<type> eq 'mailbox' { take build-mailbox($_) }
        when so .<type> eq 'group' { take build-group($_) }
    }
}

multi method parse-one(::?CLASS:U: Str $str, :$mailbox!, :$parser = RFC5322-Parser, :$actions = RFC5322-Actions --> Mailbox) {
    build-mailbox($_)
        given parse-email-address($str, :$parser, :$actions, :rule<mailbox>);
}

multi method parse-one(::?CLASS:U: Str $str, :$group!, :$parser = RFC5322-Parser, :$actions = RFC5322-Actions --> Group) {
    build-group($_)
        given parse-email-address($str, :$parser, :$actions, :rule<group>);
}

multi method parse-one(::?CLASS:U: Str $str, :$address!, :$parser = RFC5322-Parser, :$actions = RFC5322-Actions --> Any) {
    given parse-email-address($str, :$parser, :$actions, :rule<address>) {
        when so .<type> eq 'mailbox' { take build-mailbox($_) }
        when so .<type> eq 'group' { take build-group($_) }
    }
}

multi method parse-one(::?CLASS:U: Str $str, :$addr-spec!, :$parser = RFC5322-Parser, :$actions = RFC5322-Actions --> AddrSpec) {
    build-addr-spec($_)
        given parse-email-address($str, :$parser, :$actions, :rule<addr-spec>);
}

method format(::?CLASS:U: *@addresses --> Str) {
    join ', ', gather for @addresses -> $_ is copy {
        when Format { take .format }
        when Callable { $_ = .arity == 1 ?? .(Nil) !! .(); proceed }
        when Pair {
            my ($display-name, @mailboxes) = .kv;
            take Group.new(:$display-name, :@mailboxes);
        }
        when Str {
            take self.parse-one($_, :address);
        }
        default {
            X::Email::Address::AdHoc.new('unknown object sent to .format()');
        }
    }
}

multi method compose(::?CLASS:U: Str $local-part, Str $domain --> Str) {
    AddrSpec.new(:$local-part, :$domain).format
}

multi method split(::?CLASS:U: Str $address, :$parser = RFC5322-Parser, :$actions = RFC5322-Actions --> List) {
    (.<local-part>, .<domain>)
        given parse-email-address($address, :$parser, :$actions, :rule<addr-spec>);
}

=begin pod

=head1 NAME

Email::Address - parse and format RFC 5322 email addresses and groups

=head1 SYNOPSIS

    use Email::Address;

    my $to-header = q:to/END_OF_TO/;
    Presidents: "Peyton Randalf" <peyton
     .randalf@example.com> (Virginia House of
     Burgesses), Henry <henry@example.com>;,
     adams <a.adams@example.com>
    END_OF_TO

    my @to = Email::Address.parse($to-header, :addresses);
    for @to {
        when Email::Address::Group {
            say "Group: ", .display-name;
        }
        when Email::Address::Mailbox {
            say "Mailbox: ", .display-name;
        }
    }

    say Email::Address.format(@to);

    my $email-address = '"John Jay" <john.jay@example.com>';
    my Email::Address::Mailbox $john-jay
        = Email::Address.parse-one($email-address, :mailbox);

    say Email::Address.format(
        'Presidents' => (
            '"Peyton Randalf" <peyton.randalf@example.com> (Virginia House of Burgesses)',
            $john-jay,
        ),
        'Henry <henry@example.com>',
    );

=head1 DESCRIPTION

This is an implementation of the L<RFC 5322|https://tools.ietf.org/html/rfc5322>
parser and formatter of email addresses and groups. It can parse  an input
string from email headers which contain a list of email addresses or a string
from email headers which contain a list of email addresses and groups of email
addresses (like From, To, Cc, Bcc, Reply-To, Sender, etc.). Also it can generate
a string value for those headers from a list of email address objects. This is
backwards compatible with RFC 2822 and RFC 822.

This code has some parts that are ported from Perl's Email::Address::XS, but the parser is built directly from the grammar in RFC 5322. This does not adhere in any way to the API in Email::Address or Email::Address::XS of Perl 5 as there were some legacy oddities I felt it best to leave behind.

This class is generally used without constructing an instance, but you can construct an instance too if you prefer. There's no real advantage to doing that though.

When parsing, please note that an RFC 5322 email is the assumed context. This means that folding whitespace will be ignored and automatically unfolded as part of parsing. For most use cases, this probably won't matter, but you should be aware of it.

B<Which parsing method should be used?> This is an important decision to consider when using this module. You should take care to use the one that makes sense for your particular use case. The documentation below highlights the headers for which each parser is intended to be used. However, this module may be useful in other situations.

Anything that looks like a To or similar header should use <method parse> with C<:addresses> mode. Anything that looks like a From should use C<method parse> with C<:mailboxes> or C<method parse-one> with C<:mailbox> depending on whether you want exactly one or more than one From address (the RFC allows for multiple From addresses).

And most other situations where you are asking the user to enter an email address, the mostly like choice is C<method parse-one> with C<:addr-spec>, which just parses the address itself with none of the extra bits.

=head1 METHODS

=head2 method parse

    multi method parse(Str $str, :$mailboxes!, :$parser, :$actions --> Seq)
    multi method parse(Str $str, :$groups! :$parser, :$actions --> Seq)
    multi method parse(Str $str, :$addresses!, :$parser, :$actions --> Seq)

The parse methods take a string and return zero or more email address objects. When calling the parse method, you must provide an adverb to specify the kind of parsing to perform:

=defn C<:mailboxes>
The parser will parse this as a list of mailboxes and return a sequence of C<Email::Address::Mailbox> objects. When parsing an email message, this method should be used with the From and Resent-From headers.

=defn C<:groups>
The parser will parse this as a list of groups and return a sequence of C<Email::Address::Group> objects.

=defn C<:addresses>
The parser will parse this as an address list, which may contain a combination of mailboxes and groups. The sequence returned may contain C<Email::Address::Group> and C<Email::Address::Mailbox> objects. When parsing email, this method should be used with the Reply-To, To, Cc, Bcc, Resent-To, Resent-Cc, and Resent-Bcc headers. This is the most accepting and generic parsing method for other cases when you want to be able to accept 0 or more email addresses.

If the given string cannot be parsed, an C<X::Email::Address> exception will be thrown.

=head2 method parse-one

    multi method parse-one(Str $str, :$mailbox!, :$parser, :$actions --> Email::Address::Mailbox)
    multi method parse-one(Str $str, :$group! :$parser, :$actions --> Email::Address::Group)
    multi method parse-one(Str $str, :$address!, :$parser, :$actions --> Any)
    multi method parse-one(Str $str, :$addr-spec!, :$parser, :$actions --> Email::Address::AddrSpec)

The parse-one methods take a string and return exactly one email address object. When calling this method, you must provide an adverb to specify the kind of parsing to perform:

=defn C<:mailbox>
The parser will parse this as a single mailbox and return a C<Email::Address::Mailbox>. When parsing an email message, this is the parser to use with the Sender and Resent-Sender headers.

=defn C<:group>
The parser will parse this as a single group and return a C<Email::Address::Group>.

=defn C<:address>
The parser will parse this as a single email address or group and will return either a C<Email::Address::Group> or C<Email::Address::Mailbox>.

=defn C<:addr-spec>
The parser will parse this as just the email address part and return a C<Email::Address::AddrSpec>. This would be just the "user@example.com" part without extra details like comments and display name you find with C<:mailbox>.

If the given string does not match a single email address, an C<X::Email::Address> exception will be thrown.

=head2 method format

    method format(*@addresses --> Str)

Given a list of arguments, this method will return a string suitable for inserting into an RFC 5322 formatted email header. Each item passed may be an C<Email::Address::Mailbox>, C<Email::Address::AddrSpec>, C<Email::Address::Group>, C<Pair>, or a C<Str>.

The email address objects will be formatted using their C<.format> method.

Pairs will be treated as lightweight groups. The key will be treated as the group display-name and the value may be a list of zero or more addresses to put into the group. (Internally, this will create a group, which is formatted.) The values may be passed as either mailbox objects or strings. When given as strings, they will be parsed as mailboxes, which can trigger a C<X::Email::Address> exception if a mailbox cannot parsed.

Sometimes, it is nice to pass everything as a list of pairs, but you still want to have some mailbox addresses outside of a group. This can be done by using Whatever as the key in the pair. For example.

    my Str $addresses = Email::Address.format:
        'Presidents' => ($peyton's, $henry's),
        *            => ($andrew's,),
    );

The values set in the last pair will be output outside of any group.

Strings will be treated as email addresses. They will be parsed and then formatted. If parsing occurs and the email addresses given are not valid, the method will thrown an C<X::Email::Address> exception.

Other objects passed will trigger an exception.

=head2 method compose

    method compose(Str $local-part, Str $domain --> Str)

This is a quick helper for combinging a local-part and domain part into a "local-part@domain" string.

=head2 method split

    method split(Str $address, :$parser, :$actions --> List)

This method takes an addr-spec (bare email address) and returns the local-part and domain part. For example:

    my ($local-part, $domain) = Email::Address.split("foo@example.com");
    say $local-part; #> foo
    say $domain;     #> example.com

This is aimed at convenience, not an optimization and does perform a full parse of the addr-spec (though, it skips the object construction step always performed by C<method parse> and C<method parse-one>).

=end pod
