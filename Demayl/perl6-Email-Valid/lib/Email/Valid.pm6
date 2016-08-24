use v6;
unit class Email::Valid:ver<1.0.0>:auth<demayl>;

use Net::DNS; # Required only when :mx_check( True )
#use Net::SMTP;

has Bool $.mx_check     = False;
has Bool $.tld_check    = False;
has Bool $.allow_tags   = False;
has Bool $.allow-ip     = False;
has Bool $.allow-local  = False;
has Bool $.allow-quoted = False; # Not popular quoted mailboxes
has Bool $.simple       = True; # Try only simple regex validation. Usefull in mose cases. You must explicit set it to False to use other tests
has Str  $.ns_server    = '8.8.8.8'; # TODO Allow multiple NS servers
has Int  $.ns_server_timeout where 3 <= * <= 250 = 5;

has $!regex_parsed = {}; # Hold regex parse results here. Wait for "is cached" trait and remove this var
has $!resolver;          # One resolver per instance


# TODO allow quoted local parts
# TODO implement Punycode to convert for IDN
my Int $max_length = 254;
my Int $mailbox_max_length = 64;
my Int $max_subd_parts = 4;
my %domain_mx;                     # Cache MX records for domains, its cached in class, not instance. One instance can handle multiple checks

# Multicast & Experimental addresses are excluded
my grammar IPv4 {
    token octet      { (\d**1..3) <?{ $0 < 256 }> }
    token ipv4       { <!before 0>(<.octet>) \. (<.octet>) \. (<.octet>) \. (<.octet>) }
    token ipv4-host  { <!before [<multicast>||<experiment>]>[<ipv4-local>||<ipv4>] <!after 0> }
    token multicast  { (<.octet>)<?{ $0 ~~ 224..239}>\.<.octet> ** 3 % '.' }
    token experiment { (<.octet>)<?{ $0 ~~ 240..255}>\.<.octet> ** 3 % '.' }
    token ipv4-local {
        10\.<.octet> ** 3 % '.' ||
        172\.(<.octet>)<?{$0 ~~ 16..31}>\.<.octet>\.<.octet> ||
        192\.168\.<.octet>\.<.octet> ||
        127\.0\.0\.1
    }
}

# This grammar will ignore anycast addresses ( that ends with :: )
# In short variant :: can be used only once
my grammar IPv6 {
    token ipv6-host  { <ipv6-full> || <ipv6-short> || <ipv6-tiny> }
    token ipv6-full  { <ipv6-block> ** 8 % <.ipv6-sep> <!before ':'0+> }
    token ipv6-short { <ipv6-block> ** 1..6 % <.ipv6-sep> <.ipv6-sep>**2 <ipv6-block> ** 1..6 % <.ipv6-sep> <?{$/<ipv6-block>.elems < 8}> <!after ':'0+>  }
    token ipv6-tiny  { <.ipv6-sep> ** 2 <ipv6-block> <!after ':'0+> }
    token ipv6-sep   { ':' }
    token ipv6-block { :i <[ a..f 0..9 ]> ** 1..4 }
}


# Use tokens, not rules !
# Difference between token & rule is that rule enables :sigspace modifier ( match literally a space )
my grammar Email::Valid::Tokens is IPv4 is IPv6 {
    token TOP     { ^ <email> $}
    token email   { <mailbox><?{$/<mailbox>.codes <= $mailbox_max_length}> '@' <domain><?{$/<domain>.codes <= $max_length - $mailbox_max_length - 1}>  }
    token mailbox { <quoted> | <:alpha +digit> [\w|'.'|'%'|'+'|'-'|"'"]+<!after < . % + - >> } # we can extend allowed characters or allow quoted mailboxes. RFC5322 !#$%&'*+-/=?^_`{|}~
    regex quoted  { ('"'|"'")  [. <!after '='>]**{1..64} $0 }  #Any printable character ( execept = ) is valid in quoted email .... Add more quotation marks ?
    token tld     { [ 'xn--' <:alpha +digit> ** 2..* | <:alpha> ** 2..15 ] }
    token domain  { 
        ([ <!before '-'> [ 'xn--' <:alpha +digit> ** 2..* | [\w | '-']+ ] <!after '-'> '.' ]) ** {1..$max_subd_parts} <?{ all($0.flat) ~~ /^. ** 2..64$/ }>
         <tld> || \[<ipv4-host>\] || \[ < I i > < P p > < V v >6':'<ipv6-host>\]
    }
}

my grammar Email::Valid::Ripper is Email::Valid::Tokens {
    token TOP { ^ .*? [.*? [<.after \W>|^] (<email>) [\W|$] .*?]+ .*? $ }
}

# Wait for "is cached" trait to remove $!regex_parsed
# TODO add warnings when mix weird options
method !parse_regex(Str $email!) {
    if $!regex_parsed{$email}.defined.not {
        my $parsed  = Email::Valid::Tokens.parse($email) // False;

        if $parsed {
            my $ip      = $parsed<email><domain><ipv4-host> || $parsed<email><domain><ipv6-host>;

            if !$.allow-ip && so $ip { # IP's not allowed
                $parsed = False;
            }
            if $.allow-ip && !$.allow-local && so $ip<ipv4-local> { # IP's allowed but without private addresses
                $parsed = False;
            }

            if !$.allow-quoted && $parsed<email><mailbox><quoted> {
                $parsed = False;
            }
        }

        $!regex_parsed{$email} = $parsed;
    }


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
