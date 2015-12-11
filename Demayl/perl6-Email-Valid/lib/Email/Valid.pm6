use v6;
unit class Email::Valid;

use Net::DNS;
#use Net::SMTP;

has Bool $.mx_check  = False;
has Bool $.tld_check = False;
has Bool $.allow_tags= False;
has Bool $.simple    = True; # Try only simple regex validation. Usefull in mose cases. You must explicit set it to False to use other tests
has Str  $.ns_server = '8.8.8.8'; # TODO Allow multiple NS servers
has Int  $.ns_server_timeout where 3 <= * <= 250 = 5;

has $!regex_parsed = {}; # Hold regex parse results here. Wait for "is cached" trait and remove this var
has $!resolver;          # One resolver per instance


# TODO allow quoted local parts
# TODO allow ip address parts ?
# TODO implement Punycode to convert for IDN
my Int $max_length = 254;
my Int $mailbox_max_length = 64;
my %domain_mx;                     # Cache MX records for domains, its cached in class, not instance. One instance can handle multiple checks


# grammar got exported in the GLOBAL namespace ... wtf ?
# Use tokens, not rules !
# Difference between token & rule is that rule enables :sigspace modifier ( match literally a space )
my grammar Email::Valid::Tokens {
    token TOP     { ^ <email> $}
    token email   { <mailbox><?{$/<mailbox>.codes <= $mailbox_max_length}> '@' <domain><?{$/<domain>.codes <= $max_length - $mailbox_max_length - 1}>  }
    token mailbox { <:alpha +digit> [\w|'.'|'%'|'+'|'-']+<!after < . % + - >> } # we can extend allowed characters or allow quoted mailboxes
    token tld     { [ 'xn--' <:alpha +digit> ** 2..* | <:alpha> ** 2..15 ] }
    token domain  { ([ <!before '-'> [ 'xn--' <:alpha +digit> ** 2..* | [\w | '-']+ ] <!after '-'> '.' ]) ** 1..4 <?{ all($0.flat) ~~ /^. ** 2..64$/ }>
         <tld>
    }
}

my grammar Email::Valid::Ripper is Email::Valid::Tokens {
    token TOP { ^ .*? [.*? [<.after \W>|^] (<email>) [\W|$] .*?]+ .*? $ }
}

# Wait for "is cached" trait to remove $!regex_parsed
method !parse_regex(Str $email!) {
    $!regex_parsed{$email} //= Email::Valid::Tokens.parse($email) // False;

    return $!regex_parsed{$email};
}

method !mx_lookup( Str $domain! ) {

    $!resolver    //= Net::DNS.new( $.ns_server );

    if not %domain_mx{$domain}.defined {
        my Promise $promise   = start { %domain_mx{$domain} =  $!resolver.lookup('MX', $domain) // False };

        # TODO remove warning and put it in exception
        # Simple hack - start 2 async promises and wait only 1 to finish, when the empty launches in X seconds - its a failure
        await Promise.anyof( Promise.in( $.ns_server_timeout ).then({ warn "Failed to make MX lookup to '$domain'" }), $promise );
    }

    return %domain_mx{$domain};
}

# Net::DNS cannot handle timeouts & UDP connections for now. Check it later
# So use async promise to handle NS lookup timeout.
# You must validate domain to get the mx records, so this function is required
method !validate_domain(Str $domain!) {

    return so self!mx_lookup( $domain );
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
method parse(Str $email!) {
    return  self!parse_regex($email);
}

# Extract emails from text
# TODO documentation
method extract( Str $text!, Bool :$matchs = False, Bool :$validate = False ){
    my @mails = Email::Valid::Ripper.parse($text)[0];

    return Nil if !@mails.elems || @mails[0] !~~ Match;

    if $validate {
        @mails.=grep({ 
            self.validate: $^a.Str
        });
    }

    return @mails if $matchs;
    return @mails.map: *<email>.Str;
}

method mx_validate(Str $email!) {
    my Str $domain = self!parse_regex($email)<email><domain>.Str;

    return self!validate_domain( $domain );
}


# '0_O';


