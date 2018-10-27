# Email::Valid
Email::Valid - perl6 library to validate/parse email addresses
## Synopsis
```perl6
use v6.c;
use Email::Valid;

my $email = Email::Valid.new(:simple(True)); # By default :simple( True )

if $email.validate("test@domain.tld") {
    say "test@domain.tld is valid";
}

say "Mailbox is: " ~ $email.parse('test@domain.tld')<email><mailbox>;
say "Domain is: "  ~ $email.parse('test@domain.tld')<email><domain>;
# Mailbox is: test
# Domain is: domain.tld

# Variant with custom type
my Email $str = 'test@test.com';
```

## Description
This module validates if given email is valid.
It's a validation only for "most" popular email types.
It allows IDN domains ( 'xn--' ) and IP address domains ( IPv4 + IPv6 ) disabled by default

## Methods
- validate( Str $email! --> Bool )
- parse( Str $email! --> Match ); # email => { 'mail@example.com' => { mailbox => 'mail', domain => {'example.com'=> [ example. ], tld => 'com' } } }
- mx_validate( Str $email! --> Bool ) # Just check if domain has MX record
- extract( Str $text!, Bool :$matchs = False, Bool :$validate = False --> List )

## Constructor
- Bool mx_check      = False    # MX test
- Bool allow-ip      = False    # Allow IPv4 & IPv6 as domain
- Bool allow-local   = False    # Allow IP private addresses in domain
- Bool allow-quoted  = False    # Allow quoted mailboxes ( "box"@domain.com )
- Bool simple        = True     # Perform only local tests ( w/o MX check for example )
- Str  ns_server     = '8.8.8.8'# Define NS server for MX test
- Int  ns_server_timeout = 5    # NS server timeout in seconds

## Examples
### Enable MX check
- 8.8.8.8 is the default DNS server
- 5 seconds is the default NS lookup timeout
```perl6
my $email = Email::Valid.new(:simple(False), :mx_check, :ns_server('8.8.8.8'), :ns_server_timeout(5) );

if !$email.validate("test@domain.tld") {
    say "test@domain.tld is NOT valid";
}
```

### Extract emails from text & validate them
```perl6
my $txt   = 'Some mails - <mail1@dont-exist.com,mail2@mail.com>'
my $email = Email::Valid.new(:simple(False), :mx_check );

$email.extract( $txt, :validate ) ; 
# (mail2@mail.com) because it has valid MX record
```

## TODO
- [x] Add MX Check
- [ ] Add "Hello" Callback verification ( test if mailbox exists on target server )
- [ ] Add TLD check ( create module Net::Domain::TLD )
- [ ] Add POD documentation ( Inline )
- [ ] Allow multiple NS servers for MX test
- [x] Allow quoted mailboxes
- [x] Allow ip addresses in domain part
- [ ] Fix ( Add ) IDN domain char limit
- [ ] Improve check when Net::DNS module supports timeout and remove hack here
