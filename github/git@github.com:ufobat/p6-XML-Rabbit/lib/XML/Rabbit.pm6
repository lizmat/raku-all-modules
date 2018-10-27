unit module XML::Rabbit;
no precompilation;

our role XML::Rabbit::Node {
    use XML::XPath;
    use XML;

    has $.context is rw;
    has $.xpath is rw;

    submethod TWEAK(:$file) {
        if $file {
            $!xpath   = XML::XPath.new(:$file);
            $!context = $!xpath.document;
        }
    }
}

my role XmlRabbitAttribute {
    has Str $.xpath-expression is rw;
    has Str $.xpath-key-expression is rw;
    has Str $.xpath-class-name is rw;
}

my class X::Usage is Exception {
    has Str $.message is rw;
}

my class X::XmlRabbitNodeException is Exception {
    has Str $.message is rw;
}

my role XmlRabbitAttributeHOW {
    use XML;

    method compose(Mu \type) {
        for type.^attributes.grep(XmlRabbitAttribute) -> $attr {
            my $method-name = $attr.name.substr(2);
            # exists key $attr.base-name in method_table
            if type.^method_table{$method-name}:exists {
                X::Usage.new(
                    message =>"A method '{$method-name}' already exists, can't create lazy accessor '\$.{$method-name}'"
                ).throw();
            }
            for type.^roles_to_compose -> $r {
                if $r.new.^method_table{$method-name}:exists {
                    X::Usage.new(
                        message =>"A method '{$method-name}' is provided by role '{$r.WHAT.^name}', can't create lazy accessor '\$.{$method-name}'"
                    ).throw();
                }
            }

            type.^add_method(
                $method-name,
                method (Mu:D:) {
                    my $val = $attr.get_value( self );
                    unless $val.defined {
                        unless self.context.defined {
                            X::XmlRabbitNodeException.new(message => "This Class doesn't have an XML Context").throw();
                        }
                        unless self.xpath.defined {
                            X::XmlRabbitNodeException.new(message => "This Class doesn't have an XML Xpath Expression").throw();
                        }
                        my &convert-node-to-text = sub ($val) {
                            return $val ~~ XML::Node ?? join '', $val.contents>>.text !! $val;
                        };
                        my &convert-node-to-rabbit = sub ($val) {
                            unless $val ~~ XML::Node {
                                X::XmlRabbitNodeException.new(
                                    message => "The xpath expression {$attr.xpath-expression} must return a XML::Node in order create a XML::Rabbit::Node"
                                ).throw();
                            }
                            my $object      = ::($attr.xpath-class-name).new();
                            $object.xpath   = self.xpath;
                            $object.context = $val;
                            return $object;
                        }

                        my &result-converter = sub ($result is rw, &node-converter) {
                            if $result ~~ Array {
                                for $result.values {
                                    $_ = &node-converter($_);
                                }
                            } else {
                                $result = &node-converter($result);
                            }
                            return $result;
                        };

                        my $values = self.xpath.find($attr.xpath-expression, start => self.context);
                        my $keys   = $attr.xpath-key-expression.defined
                        ?? self.xpath.find($attr.xpath-key-expression, start => self.context)
                        !! Str:U;

                        $values = &result-converter($values,
                                                    $attr.xpath-class-name
                                                     ?? &convert-node-to-rabbit
                                                     !! &convert-node-to-text);
                        $keys = &result-converter($keys, &convert-node-to-text);

                        # for ($values, $keys) {
                        #     if $_ ~~ Array {
                        #         for $_.values {
                        #             $_ = &node-converter($_);
                        #         }
                        #     } else {
                        #         $_ = &node-converter($_);
                        #     }
                        # }
                        if $keys.defined {
                            $val{ $keys.values } = $values.values;
                        } else {
                            $val = $values;
                        }
                        $attr.set_value( self, $val );
                    }
                    return $val;
                });
        }
        callsame;
    }
}

multi trait_mod:<is>(Attribute:D $attr, :$xpath-object!) is export {
    my $class := $attr.package;
    $attr does XmlRabbitAttribute;
    if $xpath-object ~~ List && $xpath-object.elems == 2 && $xpath-object[1] ~~ Pair {
        $attr.xpath-class-name     = $xpath-object[0];
        $attr.xpath-key-expression = $xpath-object[1].key;
        $attr.xpath-expression     = $xpath-object[1].value;
    } elsif $xpath-object ~~ List && $xpath-object.elems == 2 && $xpath-object[1] ~~ Str {
        $attr.xpath-class-name     = $xpath-object[0];
        $attr.xpath-expression     = $xpath-object[1];
        $attr.xpath-key-expression = Nil;
    } else {
        X::Usage.new(message => "invalid 'is xpath-object(...)' expression. Expecting 'is xpath-object('Your::Object', '/xpath/expression')' or similar").throw();
    }
    unless $class.HOW ~~ XmlRabbitAttributeHOW {
        $class.HOW does XmlRabbitAttributeHOW
    }
}

multi trait_mod:<is>(Attribute:D $attr, :$xpath! ) is export {
    my $class := $attr.package;
    $attr does XmlRabbitAttribute;
    if $xpath ~~ Pair {
        $attr.xpath-class-name     = Nil;
        $attr.xpath-key-expression = $xpath.key;
        $attr.xpath-expression     = $xpath.value;
    } elsif $xpath ~~ Str {
        $attr.xpath-class-name     = Nil;
        $attr.xpath-expression     = $xpath;
        $attr.xpath-key-expression = Nil;
    } else {
        X::Usage.new(message => "invalid 'is xpath(...)' expression").throw();
    }
    unless $class.HOW ~~ XmlRabbitAttributeHOW {
        $class.HOW does XmlRabbitAttributeHOW
    }
}
