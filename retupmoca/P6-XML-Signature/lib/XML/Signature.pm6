use XML;
use XML::Canonical;
use OpenSSL;
use OpenSSL::RSATools;
use Digest::SHA;
use MIME::Base64;
use UUID;

unit module XML::Signature;

our sub sign(XML::Element $document is rw, :$private-pem!, :$x509-pem! is copy, :$enveloping, :$enveloped, :$detached) is export {
    $x509-pem ~~ s:g/\s+//;
    $x509-pem ~~ s/\-\-\-\-\-BEGINCERTIFICATE\-\-\-\-\-//;
    $x509-pem ~~ s/\-\-\-\-\-ENDCERTIFICATE\-\-\-\-\-//;
    # only does enveloped for now

    my $id;
    if $document.attribs<ID> {
        $id = $document.attribs<ID>;
    }
    else {
        $id = '_' ~ UUID.new.Str;
        $document.attribs<ID> = $id;
    }

    my $digest = MIME::Base64.encode(sha256(canonical($document, :exclusive)));
    my $signed-info = make-xml('ds:SignedInfo',
                               make-xml('ds:CanonicalizationMethod', :Algorithm('http://www.w3.org/2001/10/xml-exc-c14n#')),
                               make-xml('ds:SignatureMethod', :Algorithm('http://www.w3.org/2001/04/xmldsig-more#rsa-sha256')),
                               make-xml('ds:Reference', :URI('#'~$id),
                                        make-xml('ds:Transforms',
                                                 make-xml('ds:Transform', :Algorithm('http://www.w3.org/2000/09/xmldsig#enveloped-signature')),
                                                 make-xml('ds:Transform', :Algorithm('http://www.w3.org/2001/10/xml-exc-c14n#'))),
                                        make-xml('ds:DigestMethod', :Algorithm('http://www.w3.org/2001/04/xmlenc#sha256')),
                                        make-xml('ds:DigestValue', $digest)));
    my $signature = make-xml('ds:Signature', $signed-info);
    $signature.setNamespace('http://www.w3.org/2000/09/xmldsig#', 'ds');
    if $enveloped ~~ XML::Node {
        $document.before($enveloped, $signature);
    }
    elsif $enveloped {
        $document.append($signature);
    }
    else {
        die "Non-enveloped signature NYI!";
    }
    my $signed-info-canon = canonical($document, :exclusive, :subset($document.name~'/ds:Signature/ds:SignedInfo'));

    my $rsa = OpenSSL::RSAKey.new(:$private-pem);
    my $signed = MIME::Base64.encode($rsa.sign($signed-info-canon.encode, :sha256));
    $signed ~~ s:g/\n//;

    my $key-info = make-xml('ds:KeyInfo',
                            make-xml('ds:X509Data',
                                     make-xml('ds:X509Certificate', $x509-pem)));
    $signature.append($key-info);
    $signature.append(make-xml('ds:SignatureValue', $signed));

    $document;
}

our sub verify(XML::Element $signature) is export {
    my @name = $signature.name.split(/\:/);
    my $prefix = @name[0] ~ ':';
    $prefix = '' unless @name[1];

    die "Must pass a signature element!" unless (@name[1] || @name[0]) eq 'Signature';

    my $signed-info = $signature.elements(:TAG($prefix ~ 'SignedInfo'), :SINGLE);
    my @references = $signed-info.elements(:TAG($prefix ~ 'Reference'));

    for @references {
        fail "Reference failure" unless check_reference($_);
    }

    my $sign-data = MIME::Base64.decode($signature.elements(:TAG($prefix ~ 'SignatureValue'), :SINGLE).contents.join);

                 # this is a bit of a hack
    my @certs = ($signature.elements(:TAG($prefix ~ 'KeyInfo'), :SINGLE) || $signature.elements(:TAG('KeyInfo'), :SINGLE))\
                          .elements(:TAG($prefix ~ 'X509Data'), :SINGLE)\
                          .elements(:TAG($prefix ~ 'X509Certificate'));
    @certs .= map({ $_.contents.join });

    # fixup cert to look like PEM
    for @certs -> $cert is rw {
        $cert ~~ s:g/\s+//;
        my @lines;
        my $i = 0;
        while $cert.chars > ($i + 1)*64 {
            @lines.push($cert.substr($i*64, 64));
            $i++;
        }
        @lines.push($cert.substr($i*64));

        $cert = "-----BEGIN CERTIFICATE-----\n" ~ @lines.join("\n") ~ "\n-----END CERTIFICATE-----";
    }
    ##

    my $canonicalization-method = $signed-info.elements(:TAG($prefix ~ 'CanonicalizationMethod'), :SINGLE).attribs<Algorithm>;

    my @path = $signed-info.name;
    my $tmp = $signed-info;
    while $tmp = $tmp.parent {
        if $tmp ~~ XML::Document {
            last;
        }
        @path.unshift($tmp.name);
    }

    my $canon;
    if $canonicalization-method eq 'http://www.w3.org/TR/2001/REC-xml-c14n-20010315' {
        if @path.elems <= 1 {
            $canon = canonical($signature.ownerDocument);
        }
        else {
            $canon = canonical($signature.ownerDocument, :subset(@path.join('/')));
        }
    }
    elsif $canonicalization-method eq 'http://www.w3.org/2001/10/xml-exc-c14n#' {
        if @path.elems <= 1 {
            $canon = canonical($signature.ownerDocument, :exclusive);
        }
        else {
            $canon = canonical($signature.ownerDocument, :exclusive, :subset(@path.join('/')));
        }
    }
    else {
        fail "Unable to understand canonicalization method: $canonicalization-method";
    }

    my $signature-method = $signed-info.elements(:TAG($prefix ~ 'SignatureMethod'), :SINGLE).attribs<Algorithm>;

    my $good = False;
    for @certs {
        my $rsa = OpenSSL::RSAKey.new(:x509-pem($_));
        if $signature-method eq 'http://www.w3.org/2000/09/xmldsig#rsa-sha1' {
            $good = True if $rsa.verify($canon.encode, $sign-data);
        }
        elsif $signature-method eq 'http://www.w3.org/2001/04/xmldsig-more#rsa-sha256' {
            $good = True if $rsa.verify($canon.encode, $sign-data, :sha256);
        }
        else {
            fail "Unable to understand signature method: " ~ $signature-method;
        }
    }
    fail "Bad signature" unless $good;
    True;
}

sub check_reference(XML::Element $reference) {
    my @name = $reference.name.split(/\:/);
    my $prefix = @name[0] ~ ':';
    $prefix = '' unless @name[1];

    my $uri = $reference.attribs<URI>;

    my $data;
    if $uri ~~ /^\#/  || !$uri {
        if !$uri || (($reference.ownerDocument.root.attribs{$reference.ownerDocument.root.idattr} || '') eq $uri.substr(1)) {
            $data = $reference.ownerDocument.root;
        }
        else {
            $data = $reference.ownerDocument.root.getElementById($uri.substr(1));
        }
        fail "Unable to get data" unless $data;
    }
    else {
        fail "Unable to understand URI: $uri";
    }

    my $transform = $reference.elements(:TAG($prefix ~ 'Transforms'), :SINGLE);
    my @transforms;
    if $transform {
        @transforms = $transform.elements(:TAG($prefix ~ 'Transform'));
    }

    my $canonical = 1;
    for @transforms {
        if $_.attribs<Algorithm> eq 'http://www.w3.org/2000/09/xmldsig#enveloped-signature' {
            # enveloped signature
            # remove ourselves from the data

            # make a copy - we don't want to mess up the original document
            my $idattr = $data.ownerDocument.root.idattr;
            $data = $data.ownerDocument.&canonical.&from-xml;
            $data.root.idattr = $idattr;
            if !$uri || (($data.root.attribs{$idattr} || '') eq $uri.substr(1)) {
                $data = $data.root;
            }
            else {
                $data = $data.root.getElementById($uri.substr(1));
            }
            $data.elements(:TAG($prefix ~ 'Signature'))>>.remove;
        }
        elsif    $_.attribs<Algorithm> eq 'http://www.w3.org/2001/10/xml-exc-c14n#'
              || $_.attribs<Algorithm> eq 'http://www.w3.org/TR/2001/REC-xml-c14n-20010315' {
            $canonical = $_.attribs<Algorithm>;
        }
        else {
            fail "Unable to understand transform algorithm: " ~ $_.attribs<Algorithm>;
        }
    }

    if $canonical {
        # canonicalization
        my @path = $data.name;
        my $tmp = $data;
        while $tmp = $tmp.parent {
            if $tmp ~~ XML::Document {
                last;
            }
            @path.unshift($tmp.name);
        }

        if $canonical ~~ /exc/ {
            if @path.elems <= 1 {
                # no subset - we're canonicalizing the whole document
                $data = canonical($data.ownerDocument, :exclusive);
            }
            else {
                my @namespaces = $_.elements(:TAG('InclusiveNamespaces'), :SINGLE).attribs<PrefixList>.split(' ');
                $data = canonical($data.ownerDocument, :exclusive, :subset(@path.join('/')), :namespaces(@namespaces));
            }
        }
        else {
            if @path.elems <= 1 {
                # no subset - we're canonicalizing the whole document
                $data = canonical($data.ownerDocument);
            }
            else {
                $data = canonical($data.ownerDocument, :subset(@path.join('/')));
            }
        }
    }

    say $data;

    my $digest-method = $reference.elements(:TAG($prefix ~ 'DigestMethod'), :SINGLE).attribs<Algorithm>;

    my $digest;
    if $digest-method eq 'http://www.w3.org/2000/09/xmldsig#sha1' {
        $digest = sha1($data.Str.encode);
    }
    elsif $digest-method eq 'http://www.w3.org/2001/04/xmlenc#sha256' {
        $digest = sha256($data.Str.encode);
    }
    else {
        fail "Unable to understand digest method: " ~ $digest-method;
    }
    $digest = MIME::Base64.encode($digest);

    say $digest;

    if $digest eq $reference.elements(:TAG($prefix ~ 'DigestValue'), :SINGLE).contents.join {
        True;
    }
    else {
        False;
    }
}
