use XML;
use XML::Signature;
use UUID;

unit class Auth::SAML2::Assertion;

has $.issuer;
has $.subject;
has $.conditions;
has $.authnstatement;
has %.attributes;

has $.signed = False;
has $.signature-valid = False;
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

    my $saml-prefix = $xml.nsPrefix('urn:oasis:names:tc:SAML:2.0:assertion');
    $saml-prefix ~= ':' if $saml-prefix.chars;

    die 'Not an assertion' unless $xml.name eq $saml-prefix~'Assertion';

    for $xml.elements {
        when .name eq $saml-prefix~'Issuer' {
            $!issuer = .contents.join;
        }
        when .name eq $saml-prefix~'Subject' {
            $!subject<NameID> = .elements(:TAG($saml-prefix~'NameID'), :SINGLE).contents.join;
        }
        when .name eq $saml-prefix~'Conditions' {
            $!conditions<NotBefore> = DateTime.new($_.attribs<NotBefore>.subst(/\.\d+Z?$/, ''));
            $!conditions<NotOnOrAfter> = DateTime.new($_.attribs<NotOnOrAfter>.subst(/\.\d+Z?$/, ''));
        }
        when .name eq $saml-prefix~'AuthnStatement' {
            $!authnstatement<AuthnInstant> = .attribs<AuthnInstant>;
        }
        when .name eq $saml-prefix~'AttributeStatement' {
            for .elements(:TAG($saml-prefix~'Attribute')) -> $attribute {
                for $attribute.elements(:TAG($saml-prefix~'AttributeValue')) -> $val {
                    %!attributes{$attribute.attribs<FriendlyName> || $attribute.attribs<Name>}.push: $val.contents.join;
                }
            }
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

method XML {
    my $id = '_' ~ UUID.new.Str;
    my $elem = make-xml('saml:Assertion', :ID($id), :Version('2.0'), :IssueInstant(DateTime.now.utc.Str), make-xml('saml:Issuer', $.issuer));
    $elem.setNamespace('urn:oasis:names:tc:SAML:2.0:assertion', 'saml');

    $elem.append(make-xml('saml:Subject', make-xml('saml:NameID', $.subject<NameID>)));
    $elem.append(make-xml('saml:AuthnStatement', :AuthInstant(DateTime.now.utc.Str), :SessionIndex($id)));

    my $attrib-statement = make-xml('saml:AttributeStatement');
    for %.attributes.kv -> $k, $v {
        my $attrib = make-xml('saml:Attribute', :Name($k));
        for $v.list -> $rv {
            $attrib.append(make-xml('saml:AttributeValue', ~$rv));
        }
        $attrib-statement.append($attrib);
    }
    $elem.append($attrib-statement);

    my $xml = from-xml($elem.Str);

    if $.signed && $.signature-cert && $.signature-key {
        sign($xml.root, :private-pem($.signature-key), :x509-pem($.signature-cert), :enveloped($xml.root.elements(:TAG('saml:Subject'), :SINGLE)));
    }

    return $xml;
}

method Str {
    return $.XML.Str;
}
