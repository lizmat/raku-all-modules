unit class SOAP::Client::WSDL;

use LWP::Simple;
use XML;

has $.namespace;
has %.types;
has %.messages;
has %.porttypes;
has %.bindings;
has %.services;

method parse-file($file) {
    self.parse(slurp $file);
}

method parse-url($url) {
    my $xml = LWP::Simple.get($url);
    self.parse($xml);
}

method parse($xml) {
    my $document = from-xml($xml);
    
    my $wsdl-prefix = $document.nsPrefix('http://schemas.xmlsoap.org/wsdl/').Str // '';
    $wsdl-prefix = $wsdl-prefix ~ ":" if $wsdl-prefix && $wsdl-prefix.chars;
    
    $!namespace = $document.attribs<targetNamespace>;
    
    #types
    %!types<types><string> = Str;
    %!types<types><double> = Numeric;
    my @elements = $document.elements(:TAG($wsdl-prefix~'types'));
    for @elements -> $xml-types {
        my $schema-prefix = $xml-types.nsPrefix('http://www.w3.org/2001/XMLSchema').Str ~ ':';
        
        my @schema-elements = $xml-types.elements(:TAG($schema-prefix~'schema'));
        for @schema-elements -> $xml-schema {
            my @element-elems = $xml-schema.elements(:TAG($schema-prefix~'element'));
            while @element-elems.shift -> $xml-element {
                my $name = $xml-element.attribs<name>;
                my $type = $xml-element.attribs<type>;
                $type ~~ s/^.+\:// if $type;
                
                if $type {
                    %!types<elements>{$name} = { :$type };
                    next;
                }
                
                my $complex = $xml-element.elements(:TAG($schema-prefix~'complexType'), :SINGLE);
                my $xml-sequence = $complex.elements(:TAG($schema-prefix~'sequence'), :SINGLE);
                my @inner-elements = $xml-sequence.elements(:TAG($schema-prefix~'element'));
                my @seq;
                for @inner-elements -> $xml-elem {
                    my $element = $xml-elem.attribs<name>;
                    my $min-occurs = $xml-elem.attribs<minOccurs>;
                    my $max-occurs = $xml-elem.attribs<maxOccurs>;
                    @seq.push({ :$element, :$min-occurs, :$max-occurs });
                    
                    @element-elems.push($xml-elem);
                }
                %!types<elements>{$name} = { sequence => @seq };
            }
            
            my @type-elems = $xml-schema.elements(:TAG($schema-prefix~'simpleType'));
            for @type-elems -> $xml-type {
                my $type = $xml-type.attribs<type>;
                unless $type {
                    my $restriction = $xml-type.elements(:TAG($schema-prefix~'restriction'), :SINGLE);
                    if $restriction {
                        $type = $restriction.attribs<base>;
                    }
                }
                $type ~~ s/^.+\://;
                
                %!types<types>{$xml-type.attribs<name>} = $type;
            }
            
            while %!types<types>.values.grep(*.defined) {
                for %!types<types>.kv -> $type, $value is rw {
                    if $value.defined {
                        $value = %!types<types>{$value};
                    }
                }
            }
        }
    }
    
    #messages
    @elements = $document.elements(:TAG($wsdl-prefix~'message'));
    for @elements -> $xml-message {
        my $name = $xml-message.attribs<name>;
        my @parts;
        for $xml-message.elements -> $xml-part {
            my $name = $xml-part.attribs<name>;
            my $type = $xml-part.attribs<type>;
            $type ~~ s/^.+\:// if $type;
            my $element = $xml-part.attribs<element>;
            $element ~~ s/^.+\:// if $element;
            @parts.push({ :$name, :$type, :$element });
        }
        
        %!messages{$name} = { parts => @parts };
    }
    
    #porttypes
    @elements = $document.elements(:TAG($wsdl-prefix~'portType'));
    for @elements -> $xml-porttype {
        my @operation-elements = $xml-porttype.elements(:TAG($wsdl-prefix~'operation'));
        my %operations;
        for @operation-elements -> $xml-operation {
            my $xml-input = $xml-operation.elements(:TAG($wsdl-prefix~'input'), :SINGLE);
            my $xml-output = $xml-operation.elements(:TAG($wsdl-prefix~'output'), :SINGLE);
            
            %operations{$xml-operation.attribs<name>} =
                { input  => $xml-input.attribs<message>.subst(/^.+\:/, ''),
                  output => $xml-output.attribs<message>.subst(/^.+\:/, '') };
        }
        %!porttypes{$xml-porttype.attribs<name>} = { operations => %operations };
    }
    
    #bindings
    @elements = $document.elements(:TAG($wsdl-prefix~'binding'));
    for @elements -> $xml-binding {
        my $soap-prefix = $xml-binding.nsPrefix('http://schemas.xmlsoap.org/wsdl/soap/');
        
        my $name = $xml-binding.attribs<name>;
        my $porttype = $xml-binding.attribs<type>.subst(/^.+\:/, '');
        
        my $type = 'soap';
        my $binding-elem = $xml-binding.elements(:TAG($soap-prefix~':binding'), :SINGLE);
        unless $binding-elem {
            $soap-prefix = $xml-binding.nsPrefix('http://schemas.xmlsoap.org/wsdl/soap12/');
            $type = 'soap12';
            $binding-elem = $xml-binding.elements(:TAG($soap-prefix~':binding'), :SINGLE);
        }
        next unless $binding-elem;
        my $style = $binding-elem.attribs<style>;
        my $transport = $binding-elem.attribs<transport>;
        
        my %operations;
        my @operation-elements = $xml-binding.elements(:TAG($wsdl-prefix~'operation'));
        for @operation-elements -> $xml-operation {
            my $name = $xml-operation.attribs<name>;
            my $style = $xml-operation.elements(:TAG($soap-prefix~':operation'), :SINGLE).attribs<style>;
            my $soap-action = $xml-operation.elements(:TAG($soap-prefix~':operation'), :SINGLE).attribs<soapAction>;
            
            %operations{$name} = { :$soap-action, :$style };
        }
        
        %!bindings{$name} = {:$porttype, :$style, :$transport, :%operations, :$type};
    }
    
    #services
    @elements = $document.elements(:TAG($wsdl-prefix~'service'));
    for @elements -> $xml-service {
        
        my $name = $xml-service.attribs<name>;
        try my $documentation = $xml-service.elements(:TAG<documentation>, :SINGLE).contents.join;
        
        my %ports;
        my @port-elements = $xml-service.elements(:TAG($wsdl-prefix~'port'));
        for @port-elements -> $xml-port {
            my $soap-prefix = $xml-service.nsPrefix('http://schemas.xmlsoap.org/wsdl/soap/');
            my $name = $xml-port.attribs<name>;
            my $binding = $xml-port.attribs<binding>.subst(/^.+\:/, '');
            
            my $type = 'soap';
            my $address-elem = $xml-port.elements(:TAG($soap-prefix~':address'), :SINGLE);
            unless $address-elem {
                $soap-prefix = $xml-service.nsPrefix('http://schemas.xmlsoap.org/wsdl/soap12/');
                $type = 'soap12';
                $address-elem = $xml-port.elements(:TAG($soap-prefix~':address'), :SINGLE);
            }
            next unless $address-elem;
            my $location = $address-elem.attribs<location>;
            
            %ports{$name} = { :$binding, :$location, :$type };
        }
        
        %!services{$name} = { :$documentation, :%ports };
    }
}
