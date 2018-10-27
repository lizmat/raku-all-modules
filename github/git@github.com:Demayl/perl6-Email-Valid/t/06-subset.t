use v6;
use Test;
use Email::Valid;

plan 1;

my Email $email = 'test@valid.com';

ok 'test@valid.com', $email;
