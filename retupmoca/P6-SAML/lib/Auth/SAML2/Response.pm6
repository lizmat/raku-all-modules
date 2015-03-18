use XML;
use XML::Signature;
use UUID;

use Auth::SAML2::Assertion;

class Auth::SAML2::Response;

has $.issuer;
has $.status;
has $.assertion;

has $.signed = False;
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

method parse-xml(XML::Element $xml) {
    $xml.ownerDocument.root.idattr = 'ID';

    my $samlp-prefix = $xml.nsPrefix('urn:oasis:names:tc:SAML:2.0:protocol');
    $samlp-prefix ~= ':' if $samlp-prefix.chars;

    die 'Not a response' unless $xml.name eq $samlp-prefix~'Response';

    for $xml.elements {
        my $saml-prefix = .nsPrefix('urn:oasis:names:tc:SAML:2.0:assertion') || '';
        $saml-prefix ~= ':' if $saml-prefix.chars;
        when .name eq $saml-prefix ~ 'Assertion' {
            $!assertion = Auth::SAML2::Assertion.new;
            $!assertion.parse-xml($_);
        }

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
    my $issuer = make-xml('saml:Issuer', $.issuer);
    $issuer.setNamespace('urn:oasis:names:tc:SAML:2.0:assertion', 'saml');
    my $elem = make-xml('samlp:Response', :ID($id), :Version('2.0'), :IssueInstant(DateTime.now.utc.Str), $issuer);
    $elem.setNamespace('urn:oasis:names:tc:SAML:2.0:protocol', 'samlp');

    $elem.append($.assertion.XML.root);

    my $str = $elem.Str;
    my $xml = from-xml($str);

    if $.signed && $.signature-cert && $.signature-key {
        sign($xml.root, :private-pem($.signature-key), :x509-pem($.signature-cert), :enveloped($xml.root.elements(:TAG('saml:Assertion'), :SINGLE)));
    }

    return $xml.Str;
}
