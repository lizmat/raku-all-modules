#!/usr/bin/env perl6
use v6;

use Test;
use Email::Address;

my $str = q[Brotherhood: "Winston Smith" <winston.smith@recdep.minitrue> (Records Department), Julia <julia@ficdep.minitrue>;, user <user@oceania>];

my @email = Email::Address.parse($str, :addresses);

is @email.elems, 2;
does-ok @email[0], Email::Address::Group;
is @email[0].display-name, 'Brotherhood';
is @email[0].mailbox-list.elems, 2;
does-ok @email[0].mailbox-list[0], Email::Address::Mailbox;
is @email[0].mailbox-list[0].display-name, 'Winston Smith';
is @email[0].mailbox-list[0].address.local-part, 'winston.smith';
is @email[0].mailbox-list[0].address.domain, 'recdep.minitrue';
is @email[0].mailbox-list[0].comment, 'Records Department';
does-ok @email[0].mailbox-list[1], Email::Address::Mailbox;
is @email[0].mailbox-list[1].display-name, 'Julia';
is @email[0].mailbox-list[1].address.local-part, 'julia';
is @email[0].mailbox-list[1].address.domain, 'ficdep.minitrue';
is @email[0].mailbox-list[1].comment, Str;
does-ok @email[1], Email::Address::Mailbox;
is @email[1].display-name, 'user';
is @email[1].address.local-part, 'user';
is @email[1].address.domain, 'oceania';
is @email[1].comment, Str;

is Email::Address.format(@email), $str;

done-testing;
