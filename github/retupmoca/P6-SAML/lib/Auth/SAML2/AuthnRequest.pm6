use XML;
use UUID;
use XML::Signature;

unit class Auth::SAML2::AuthnRequest;

has $.issuer;

has $.signed;
has $.signature-valid;
has $.signature-cert;
has $.signature-key;

multi method new(Str $xml) {
    my $s = self.bless();
    $s.parse-xml(from-xml($xml).root);
    return $s;
}

multi method new(XML::Document $xml) {
    my $s = self.bless();
    $s.parse-xml($xml.root);
    return $s;
}

multi method new(XML::Element $xml) {
    my $s = self.bless();
    $s.parse-xml($xml);
    return $s;
}

method parse-xml($xml) {
    my $prefix = $xml.nsPrefix('urn:oasis:names:tc:SAML:2.0:protocol');
    $prefix ~= ':' if $prefix;

    die "Not an AuthnRequest" unless $xml.name eq $prefix~'AuthnRequest';

    my $sprefix = $xml.nsPrefix('urn:oasis:names:tc:SAML:2.0:assertion');
    $sprefix ~= ':' if $sprefix;
    $!issuer = $xml.elements(:TAG($sprefix~'Issuer'), :SINGLE).contents.join;

    for $xml.elements {
        my $sig-prefix = .nsPrefix('http://www.w3.org/2000/09/xmldsig#');
        $sig-prefix ~= ':' if $sig-prefix;
        when .name eq $sig-prefix~'Signature' {
            $!signed = True;
            $!signature-valid = verify($_);
            my $key-info = .elements(:TAG($sig-prefix ~ 'KeyInfo'), :SINGLE)\
                           .elements(:TAG($sig-prefix ~ 'X509Data'), :SINGLE)\
                           .elements(:TAG($sig-prefix ~ 'X509Certificate'), :SINGLE)\
                           .contents.join;
            $!signature-cert = $key-info;
        }
    }
}

method Str {
    my $id = '_' ~ UUID.new.Str;
    my $elem = make-xml('samlp:AuthnRequest', :ID($id), :Version('2.0'), :IssueInstant(DateTime.now.utc.Str),
                        make-xml('saml:Issuer', $.issuer),
                        make-xml('samlp:NameIDPolicy', :AllowCreate('true'), :Format('urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified')));
    $elem.setNamespace('urn:oasis:names:tc:SAML:2.0:protocol', 'samlp');
    $elem.setNamespace('urn:oasis:names:tc:SAML:2.0:assertion', 'saml');

    my $xml = from-xml($elem.Str);

    if $.signed && $.signature-cert && $.signature-key {
        sign($xml.root, :private-pem($.signature-key), :x509-pem($.signature-cert), :enveloped($xml.root.elements(:TAG('samlp:NameIDPolicy'), :SINGLE)));
    }

    return $xml.Str;
}
