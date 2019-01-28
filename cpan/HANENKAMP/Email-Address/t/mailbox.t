#!/usr/bin/env perl6
use v6;

use Test;
use Email::Address;

my Email::Address::Mailbox $email .= new(
    'Peyton Randalf',
    'peyton.randalf@example.com',
    'Virginia House of Burgesses',
);

does-ok $email, Email::Address::Mailbox;
is $email.display-name, 'Peyton Randalf';
is $email.address.local-part, 'peyton.randalf';
is $email.address.domain, 'example.com';
is $email.comment, 'Virginia House of Burgesses';
is $email.gist, '"Peyton Randalf" <peyton.randalf@example.com> (Virginia House of Burgesses)';

done-testing;
