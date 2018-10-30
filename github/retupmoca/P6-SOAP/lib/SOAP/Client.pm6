unit class SOAP::Client;

use SOAP::Client::WSDL;
use LWP::Simple;
use XML;

has $.wsdl;

method new($from) {
    my $wsdl;
    if $from ~~ SOAP::Client::WSDL {
        $wsdl = $from;
    }
    elsif $from ~~ /^\s+\</ {
        $wsdl = SOAP::Client::WSDL.new;
        $wsdl.parse($from);
    }
    elsif $from ~~ /^https?\:\/\// {
        $wsdl = SOAP::Client::WSDL.new;
        $wsdl.parse-url($from);
    }
    else {
        $wsdl = SOAP::Client::WSDL.new;
        $wsdl.parse-file($from);
    }
    self.bless(:$wsdl);
}

method call($name, *%params) {
    my $namespace = $.wsdl.namespace;
    my $in-message;
    my $out-message;
    my $location;
    my $soapaction;
    my $type;

    # find the porttypes for the operation
    for $.wsdl.services.kv -> $service, $sdata {
        for $sdata<ports>.kv -> $port, $pdata {
            if $.wsdl.bindings{$pdata<binding>}<operations>{$name} {
                $type = $.wsdl.bindings{$pdata<binding>}<type>;
                $soapaction = $.wsdl.bindings{$pdata<binding>}<operations>{$name}<soap-action>;
                $location = $pdata<location>;
                $in-message = $.wsdl.messages{$.wsdl.porttypes{$.wsdl.bindings{$pdata<binding>}<porttype>}<operations>{$name}<input>};
                $out-message = $.wsdl.messages{$.wsdl.porttypes{$.wsdl.bindings{$pdata<binding>}<porttype>}<operations>{$name}<output>};
            }
        }
    }

    # build in-message
    # to do this properly, we really need XML::Schema
    # but for now, just assume the passed parameters are ok
    # and just convert to XML blindly
    # (Cheating is fun!)
    my $part = $in-message<parts>[0];
    my $in = make-xml($part<element>, :xmlns($namespace), p6-to-xml(%params));

    # build soap request
    my $body = make-xml("soap:Body", $in);
    my $request = make-xml("soap:Envelope",
                            $body);
    $request.setNamespace('http://schemas.xmlsoap.org/soap/envelope/', 'soap');

    $request = '<?xml version="1.0" encoding="utf-8"?>' ~ $request;

    # send to location
    my %headers = ('Content-Type' => 'text/xml');
    if $type eq 'soap' {
        %headers<SOAPAction> = $soapaction;
    }
    my $response = LWP::Simple.post($location, %headers, $request);

    my $r-xml = from-xml($response);

    my $soap-prefix = $r-xml.nsPrefix('http://schemas.xmlsoap.org/soap/envelope/');

    my $rbody = $r-xml.elements(:TAG($soap-prefix~':Body'), :SINGLE);

    # Cheat!
    #return $rbody.elements[0][0].contents;

    # still cheat, just a little less blatently
    my %ret;
    for $rbody.elements -> $body-elem {
        for $body-elem.elements -> $leaf {
            %ret{$leaf.name} = $leaf.contents;
        }
    }

    return %ret;
}

sub p6-to-xml($p6) {
    my @ret;
    for $p6.kv -> $k, $v {
        if $v ~~ List {
            for $v.list -> $vli {
                @ret.push: p6-to-xml({ $k => $vli }).list;
            }
        }
        elsif $v ~~ Hash {
            @ret.push(make-xml($k, p6-to-xml($v)));
        }
        else {
            @ret.push(make-xml($k, $v));
        }
    }
    return @ret;
}
