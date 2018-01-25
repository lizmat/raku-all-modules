use v6;
use Test;

use Net::IP :ALL;

plan 3;

# domain reverse

# valid
is ip-reverse-domain('mail.example.domain'), 'domain.example.mail';
is ip-reverse-domain('mail.example.domain.tld'), 'tld.domain.example.mail';

# not valid, returns input
is ip-reverse-domain('mail:tld'), 'mail:tld';
