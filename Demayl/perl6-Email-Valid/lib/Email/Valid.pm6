use v6;
unit class Email::Valid;

use Net::DNS;

has Bool $.mx_check  = False;
has Bool $.tld_check = False;
has Bool $.allow_tags= False;
has Bool $.simple    = True; # Try only simple regex validation. Usefull in mose cases. You must explicit set it to False to use other tests
has Str  $.ns_server = '8.8.8.8'; # TODO Allow multiple NS servers
has Int  $.ns_server_timeout where 3 <= * <= 250 = 5;

has $!regex_parsed = {}; # Hold regex parse results here. Wait for "is cached" trait and remove this var

# TODO allow quoted local parts
# TODO allow ip address parts ?
# TODO implement Punycode to convert for IDN
my Int $max_length = 254;
my Int $mailbox_max_length = 64;


# grammar got exported in the GLOBAL namespace ... wtf ?
my grammar Email::Valid::Tokens {
    token TOP     { ^ (<mailbox>)<?{$0.codes <= $mailbox_max_length}> '@' (<domain>)<?{$1.codes <= $max_length - $mailbox_max_length - 1}> $ }
    token mailbox { <:alpha +digit> [\w|'.'|'%'|'+'|'-']+<!after < . % + - >> } # we can extend allowed characters or allow quoted mailboxes
    token tld     { [ 'xn--' <:alpha +digit> ** 2..* | <:alpha> ** 2..15 ] }
    token domain  { ([ <!before '-'> [ 'xn--' <:alpha +digit> ** 2..* | [\w | '-']+ ] <!after '-'> '.' ]) ** 1..4 <?{ all($0.flat) ~~ /^. ** 2..64$/ }>
         (<tld>)
    }
}


# Wait for "is cached" trait to remove $!regex_parsed
method !parse_regex(Str $email!) {
    $!regex_parsed{$email} //= Email::Valid::Tokens.parse($email) // False;

    return $!regex_parsed{$email};
}

# Net::DNS cannot handle timeouts & UDP connections for now. Check it later
# So use async promise to handle NS lookup timeout.
method !validate_domain(Str $domain!) {
    my $resolver = Net::DNS.new( $.ns_server );
    my $result   = Nil;
    my Promise $promise   = start { $result = so $resolver.lookup('MX', $domain) };

    # TODO remove warning and put it in exception
    # Simple hack - start 2 async promises and wait only 1 to finish, when the empty launches in X seconds - its a failure
    await Promise.anyof( Promise.in( $.ns_server_timeout ).then({ warn "Failed to make MX lookup to '$domain'" }), $promise );

    return so $result; # Force Bool context
}

# Allow multiple email validations from single instance
# Currently only simple regex validation implemented
method validate(Str $email!) returns Bool {

    my Bool $valid_email = so self!parse_regex($email);
    my Bool @checks;

    # When :simple is True - check only against regex
    if so $.simple {
        return $valid_email;
    }

    return False if !$valid_email ;

    if $.mx_check {
        @checks.push: self.mx_validate($email);
    }

    return all(@checks) ~~ :so; # :so is for smartmatch that forces Bool context ( if we use True it will always match )
}

# 0 -> mailbox
# 1 -> domain -> [subdomain1, subdomain2 ], tld --> Str $full_domain
# Returns Nil on fail
method parse(Str $email!) returns Match {
    return  self!parse_regex($email);
}

method mx_validate(Str $email!) {
    my Str $domain = self!parse_regex($email)[1].Str;
    return self!validate_domain( $domain );
}


# '0_O';


