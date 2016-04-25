use v6.c;

=begin pod

=head1 NAME

XML::Class - Role to Serialize/De-Serialize a Perl 6 class to/from XML

=head1 SYNOPSIS

=begin code

use XML::Class;

class Foo does XML::Class[xml-element => 'foo'] {
    has Int $.version = 0;
    has Str $.zub is xml-element;
}

my $f = Foo.new(zub => "pow");

say $f.to-xml; # <?xml version="1.0"?><foo xmlns="http://example.com/" version="0"><zub>pow</zub></foo>


=end code

There are more examples in the L<USAGE|#USAGE> section below.

=head1 DESCRIPTION

This provides a relatively easy way to instantiate a Perl 6 object from
XML and create XML that describes the Perl 6 class in a consistent manner.

It is somewhat inspired by the C<XmlSerialization> class of the .Net
framework, but there are other antecedents.

Using a relatively static definition of the relation between a class
and XML that represents it means that XML can be consistently parsed
and generated in a way that should always remain valid to the original
description.

This module aims to map between Perl 6 object attributes and XML by
providing some default behaviours and some attribute traits to alter
that behaviour to model the XML.

By default scalar attributes who's value type can be expressed as an
XML simple type (e.g.  strings, real numbers, boolean, datetimes) will
be serialised as attribute values or (with an C<xml-element> trait,)
as elements with simple content.  positional attributes will always
be serialised as a sequence of elements (with an optional container
specified by a trait,) likewise associative attributes (though the use
of these is discouraged as there is no constraint on the names of the
elements which are taken from the keys of the Hash.)  Perl 6 classes are
expressed as XML complex types with the same serialisation as above.
Provision is also made for the serialisation and de-serialisation of
other than the builtin types to simple contemt (trivial examples might
be Version objects for instance,) and for the handling of data that
might be unknown at definition time (such as the xsd:Any in SOAP head
and body elements,) by the use of "namespace maps".

There are things that explicitly aren't catered for such as  "mixed
content" (that is where XML markup may be within text content as in
XHTML for example,) but that shouldn't be a problem for data storage or
messaging applications for the most part.

=head1 METHODS

The role only supplies two public methods.

=head2 method to-xml

    multi method to-xml() returns Str
    multi method to-xml(:$document!) returns XML::Document
    multi method to-xml(:$element!, Attribute :$attribute) returns XML::Element

This outputs the object instance as its representation as XML, by default
it will output as a Str which should be good for most applications however
the C<:document> or C<:element> adverbs can be used to cause the output
of an L<XML::Document> or L<XML::Element> which may be useful if some
further processing is required.  The C<attribute> parameter in the latter
case is used internally, but could be used to output the representation of
a single Attribute of the object if that is useful for some application.

=head2 method from-xml

    multi method from-xml(XML::Class:U: Str $xml) returns XML::Class
    multi method from-xml(XML::Class:U: XML::Document:D $xml) returns XML::Class
    multi method from-xml(XML::Class:U: XML::Element:D $xml) returns XML::Class


This is a class method that should be called with the XML to be parsed
into a new object that will be returned. It can take either a string
representing the XML or a pre-parsed L<XML::Document> or L<XML::Element>
if the application already has those in hand.

=head1 USAGE

It's probably easiest to explain the bulk of this by example in the
first place. The rules for deserialisation are symmetrical to those for
serialisation, so all the examples below should be reversible.

=head2 CLASS DECLARATION

L<XML::Class> is a C<role> which should be applied to a class when it
is defined, the role itself has optional parameters that can be applied.

By default a serialised class will take the element name from the
C<shortname> of the class:

=begin code

class Foo::Bar does XML::Class {
    ...
}

=end code

Will be serialised as:

=begin code

<Bar>
  ...
</Bar>

=end code

If you need or want to use an alternative element name it can provided
as a parameter to the role:

=begin code

class Foo::Bar does XML::Class[xml-element => 'Foobar'] {
    ...
}

=end code

Will become:

=begin code

<Foobar>
   ...
</Foobar>

=end

A namespace with an (optional) prefix can be applied too:

=begin code

class Foo::Bar does XML::Class[xml-element => 'Foobar', xml-namespace => 'urn:foo', xml-namespace-prefix => 'fo'] {
    ...
}

=end code

Will be serialised as:

=begin code

<fo:Foobar xmlns:fo="urn:foo">
    ...
</fo:Foobar>

=end code

Any namespace and/or prefix declared will remain the default for the
rest of the class unless over-ridden explicitly with the C<xml-namespace>
trait or by the definition of any included XML::Class typed attributes.

=head2 SCALAR ATTRIBUTES

Only object attributes with a public accessor will be serialised to XML.

By default a scalar attribute (that is with a C<$.> sigil) of a "simple
type" (that is strings, real numbers, bool, datetime and date) will be
serialised as XML attributes with the same name as the Perl 6 attribute:

=begin code

class Foo::Bar does XML::Class {
    has Str $.string = "foo";
}

=end code

Will be rendered to:

=begin code

<Bar string="foo">
    ...
</Bar>

=end code

The name of the output (or input) attribute can be explicitly set with
the C<xml-attribute> trait, thus:

=begin code

class Foo::Bar does XML::Class {
    has Str $.string is xml-attribute('thing') = "foo";
}

=end code

Will be rendered to:

=begin code

<Bar thing="foo">
    ...
</Bar>

=end code

If your XML description calls for an element rather than an attribute
then the C<xml-element> trait should be used:

=begin code

class Foo::Bar does XML::Class {
    has Str $.string is xml-element = "foo";
}

=end code

Will be rendered to:

=begin code

<Bar>
    <string>foo</string>
</Bar>

=end code

An alternative name can be supplied to the C<xml-element> trait:

=begin code

class Foo::Bar does XML::Class {
    has Str $.string is xml-element('Thing') = "foo";
}

=end code

which will be rendered to:

=begin code

<Bar>
    <Thing>foo</Thing>
</Bar>

=end code

=head2 POSITIONAL ATTRIBUTES

Positional attributes are always serialised as a sequence of XML elements
with the same element name. Thus:

=begin code

class Foo::Bar does XML::Class {
    has Str @.string = <a b>
}

=end code

Will be output as:

=begin code

<Bar>
    <string>a</string>
    <string>b</string>
</Bar>

=end code

The element name can be set by C<xml-element>:

=begin code

class Foo::Bar does XML::Class {
    has Str @.string is xml-element('Thing') = <a b>
}

=end code

Will be output as:

=begin code

<Bar>
    <Thing>a</Thing>
    <Thing>b</Thing>
</Bar>

=end code

In the positional case C<xml-element> without a supplied element name
has no effect.

If you require a container around the elements (such that the attribute
forms an XML complex typed element containing a sequence of zero or more
of the same element type,) you can use the C<xml-container> trait:

=begin code

class Foo::Bar does XML::Class {
    has Str @.string is xml-element('Thing') is xml-container('Things') = <a b>
}

=end code

Which will be output as:

=begin code

<Bar>
    <Things>
        <Thing>a</Thing>
        <Thing>b</Thing>
    </Things>
</Bar>

=end code

This could alternatively be expressed as a class typed attribute with
its own single positional attribute, this is described below.

=head2 ASSOCIATIVE ATTRIBUTES

Associative (or Hash,) attributes (that is those declared with the C<%.>
sigil,) will produce XML such that a container element is produced with
the name of the attribute with a sequence of elements named after the
keys of the hash:

=begin code

class Foo::Bar does XML::Class {
	has %.bars = (a => 1, b => 2);

}

=end code

Will produce the XML:

=begin code

<Bar>
    <bars>
        <a>1</a>
        <b>2</b>
    </bars>
</Bar>

=end code

The name of the containing element can be set with the C<xml-element>
trait:

=begin code

class Foo::Bar does XML::Class {
	has %.bars is xml-element('Bars') = (a => 1, b => 2);

}

=end code

Will produce the XML:

=begin code

<Bar>
    <Bars>
        <a>1</a>
        <b>2</b>
    </Bars>
</Bar>

=end code

In the associative case any C<xml-container> trait will be ignored.

There is no way currently to alter the names of the inner elements,
which may limit the usefulness of the output XML as it is easy to
produce XML which does not conform to the target description: this can
be somewhat mitigated by the use of an XML namespace on the attribute
if the application supports it, however it is suggested that you should
consider class typed attributes with a custom class to receive the data
rather than using an associative attribute.

=head2 CLASS TYPED ATTRIBUTES

A class typed attribute will be serialised to XML according to the rules
described above for its own attributes such that it forms an element of
complex content with the name derived from the shortname of the class.
So the following:

=begin code

class Foo does XML::Class {
	class Bar {
		has Str $.attribute = "thing";
		has Int $.element is xml-element  = 10;
	}
	has Bar $.bar = Bar.new;
}

=end code

Will emit XML like:

=begin code
<Foo>
    <Bar attribute="thing">
        <element>10</element>
    </Bar>
</Foo>
=end code

The same rule applies to positional attributes typed to a class:

=begin code
class Foo does XML::Class {
	class Bar {
		has Str $.attribute = "thing";
		has Int $.element is xml-element  = 10;
	}
	has Bar @.bar = (Bar.new(attribute => "something", element => 42), Bar.new(attribute => "else", element => 666));
}
=end code

Will give you:

=begin code
<Foo>
    <Bar attribute="something">
        <element>42</element>
    </Bar>
    <Bar attribute="else">
        <element>666</element>
    </Bar>
</Foo>
=end code

As with positionals of simple types the C<xml-container> trait allows
the sequence to have an enclosing element.

If you wish to have an additional enclosing element for a single object
then the C<xml-element> trait can be applied:

=begin code
class Foo does XML::Class {
	class Bar {
		has Str $.attribute = "thing";
		has Int $.element is xml-element  = 10;
	}
	has Bar $.bar is xml-element('Inner') = Bar.new;
}
=end code

Giving:

=begin code
<Foo>
    <Inner>
        <Bar attribute="thing">
            <element>10</element>
        </Bar>
    </Inner>
</Foo>
=end code

If the class of the attribute itself does L<XML::Class> then any
C<xml-element>, C<xml-namespace> and C<xml-namespace-prefix> will be used:

=begin code
class Foo does XML::Class {
	class Bar does XML::Class[xml-element => 'Thing', xml-namespace => 'urn:things', xml-namespace-prefix => 'th'] {
		has Str $.attribute = "thing";
		has Int $.element is xml-element  = 10;
	}
	has Bar $.bar = Bar.new;
}
=end code

Results in:

=begin code
<Foo>
    <th:Thing xmlns:th="urn:things" attribute="thing">
        <th:element>10</th:element>
    </th:Thing>
</Foo>
=end code

The class can, of course, be defined anywhere you see fit, it need not
be within the outer class as it is above.

As alluded to above in the description of positional attributes it is
entirely possible to represent the "sequence with container element"
as a class with a single positional attribute:

=begin code
class Foo does XML::Class {
	class Things {
		has Str @.things is xml-element('Thing')  = <a b>;
	}
	has Things $.bar = Things.new;
	
}
=end code

Will give semantically identical XML to the original example; which
you choose to use should be determined by the design requirements of
the application.

A common structure in XML is an element with one or more attributes
as well as textual content, which in XSD terms is a "complex type with
simple content" such as:

=begin code
<Foo>
  <Name lang="en">Foo</Name>
</Foo>
=end code

Which can be expressed as a class with an attribute with the
C<xml-simple-content> trait:

=begin code
class Foo does XML::Class {
	class Name {
		has Str $.lang = 'en';
		has Str $.name is xml-simple-content = 'Foo';
	}
	has Name $.bar = Name.new;
}
=end code

Obviously this is reversible.

There can only be one C<xml-simple-content> attribute per class, but
there can be any number of XML attributes and possibly C<xml-element>s.

=head2 XML NAMESPACES

As well as applying xml namespaces as parameters to the XML::Class
role they can be applied on a per-element basis (possibly over-riding
any effective namespace,) with the C<xml-namespace> trait, currently
namespaced XML attributes aren't supported.

=begin code
class Foo does XML::Class {
	has Str $.bar is xml-element is xml-namespace('urn:bar','b') = "thing";
}
=end code

Will give you:

=begin code
<Foo>
    <b:bar xmlns:b="urn:bar">thing</b:bar>
</Foo>
=end code

The second, prefix, parameter to the trait is optional and if omitted the
supplied namespace will become the default for the scope of the element.

This can be applied in combination with most other traits and attribute
types, for example:

=begin code
class Foo does XML::Class {
	has Str @.bar is xml-container('Bars') is xml-element is xml-namespace('urn:bar','b') = <a b c>;
}
=end code

Will give you

=begin code
<Foo>
    <b:Bars xmlns:b="urn:bar">
        <b:bar>a</b:bar>
        <b:bar>b</b:bar>
        <b:bar>c</b:bar>
    </b:Bars>
</Foo>
=end code

And, as alluded to in the discussion of associative parameters above,
namespaces can be applied to a hash as:

=begin code
class Foo does XML::Class {
	has %.bars is xml-element('Bars') is xml-namespace('urn:my-bars', 'ba') = (a => 1, b => 2);
}
=end code

To give you:

=begin code
<Foo>
    <ba:Bars xmlns:ba="urn:my-bars">
        <ba:b>2</ba:b>
        <ba:a>1</ba:a>
    </ba:Bars>
</Foo>
=end code

=head2 UNTYPED ATTRIBUTES

For the best consistency you should have typed attributes, however for
simple content of the built in types (strings, real numbers, Bool,  Date,
DateTime and so forth,) they will be serialised correctly based on the
type of the value, however because no type information is available they
will always be deserialised from XML as strings (you are of course free
to perform your own coercion later.) The same applies equally to the
values of positional and associative attributes.

In the case of untyped attributes (or values of aggregate attributes,)
where the values are objects that would suggest a "complex type" they
will be serialised to XML as per the rules discussed above, however on
deserialisation from XML if a complex type is found in the place of an
untyped attribute then it will be skipped and the attribute will be left
uninitialised silently, you can cause this to be an error by making the
attribute 'required' in your class definition, though you probably want
to avoid the situation by providing a type if at all possible.

However there are cases where a particular XML schema definition may
explicitly provide for the presence of any element in a particular place,
this is often used in messaging wrappers such as SOAP where the C<Head>
and C<Body> elements are both defined in the schema as a sequence of
'any':

=begin code
<xs:sequence>
    <xs:any namespace="##other" minOccurs="0" maxOccurs="unbounded" processContents="lax"/>
</xs:sequence>
=end code

This case is handled for the deserialisation case by the C<xml-any>
trait for the attributes where this is expected which indicates that
special handling is required for the attribute value and (in your program
code,) a dynamic variable C<%*NS-MAP> which maps a possible namespace URI
that may be found in the element to a type which will be instantiated
to receive the content in the otherwise identical manner to statically
declared types.

For example if one were to have a class defining a SOAP envelope like:

=begin code
class Envelope does XML::Class[xml-namespace => 'http://schemas.xmlsoap.org/soap/envelope/'] {
    has $.head is xml-any is xml-element('Head');
    has $.body is xml-any is xml-element('Body');
}
=end code

And receive an Envelope like:

=begin code
<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/">
    <Head/>
    <Body>
        <Data xmlns="urn:my-data">
            <Something>some data</Something>
        </Data>
    </Body>
</Envelope>
=end code

Then the following code would get you the received Data object (assuming you have the
envelope in C<$xml> already:

=begin code
my %*NS-MAP = ('urn:my-data' => Data );

my $e = Envelope.from-xml($xml);

say $e.body.perl; # Data.new(something => "some data")
=end code

This allows you to create a SOAP client (or indeed server,) quite simply
(though in reality the Body and Head elements are actually sequences
of potentially multiple elements, the mechanism works equally well for
differing elements mapped to differently mapped classes with a positional
attribute.)

The C<%*NS-MAP> can be defined in any scope above the C<from-xml> which
requires the namespace lookup and can be added to/removed from in the
lifetime of your application.

If no matching namespace is found in the C<%*NS-MAP> for that found
to be in effect for the element being processed then nothing will be
populated into the attribute marked C<xml-any>.

=head2 OTHER TYPES AS SIMPLE CONTENT

If your application has data types that aren't the builtin types but
are nonetheless able to be expressed as "simple content" (that is they
can be expressed as a string that contains sufficient information to
recreate an object of the equivalent value,) then you can provide your
own code with the C<xml-serialise> and C<xml-deserialise> traits to turn
the object into a string and convert it back into an object of the same
type respectively.  A Perl 6 L<Version> object is a good example:

=begin code
class Versioned does XML::Class {
    sub version-out(Version $v) returns Str {
        $v.Str;
    }
    sub version-in(Str $v) returns Version {
        Version.new($v);
    }

    has Version $.version-attribute is xml-serialise(&version-out) is xml-deserialise(&version-in);
    has Version $.version-element is xml-serialise(&version-out) is xml-deserialise(&version-in) is xml-element;
}
=end code

Would for instance populate correctly the Version object from this XML:

=begin code
<Versioned version-attribute="0.1.0">
    <version-element>2.0.1</version-element>
</Versioned>
=end code

The only constraint on the code supplied for the traits is that for the
serialise case it should have a single argument that is the of the type
to be serialised and should return the appropriate string.  For the
deserialise case it should accept a single string (the value of the
attribute or element,) and return an object of the appropriate type.

=head2 OMITTING EMPTY VALUES

By default an uninitialised attribute will give rise to an XML attribute
with the empty string as a value or an empty XML element, for many 
applications this should be fine, however if a peer application
requires a value to be defined or has some constraint if the element
or attribute is present then the C<xml-skip-null> trait can be applied
which will cause the element or attribute to not be emitted at all
if the Perl 6 attribute is not a defined value.

=end pod

use XML;

role XML::Class[Str :$xml-namespace, Str :$xml-namespace-prefix, Str :$xml-element] {

    # need to close over these to use within blocks that might have their own defined
    method xml-element {
        $xml-element // $?CLASS.^shortname;
    }
    method xml-namespace {
        $xml-namespace;
    }
    method xml-namespace-prefix {
        $xml-namespace-prefix;
    }

    # Exceptions can be used anywhere here
    my class X::NoElement is Exception {
        has Str $.element is required;
        has Attribute $.attribute is required;
        method message() {
            if $.attribute.defined {
                "Expected element '{ $!element }' not found for attribute '{ $!attribute.name.substr(2) }'";
            }
            else {
                "Expected element '{ $!element }' not found";
            }
        }
    }

    # Roles applied by the traits
    my role NameX {
        has Str $.xml-name is rw;
        method xml-name() is rw returns Str {
            $!xml-name //= $.name.substr(2);
            $!xml-name;
        }
    }

    my role NodeX  {
    }

    my role AttributeX does NodeX does NameX {
    }

    my role ElementX[Bool :$from-serialise] does NodeX does NameX {
        has Bool $.from-serialise = $from-serialise;

    }

    my role ContainerX does NodeX {
        has Str $.container-name is rw;
        method container-name() is rw returns Str {
            $!container-name //= $.name.substr(2);
            $!container-name;
        }

    }

    # This is to provide "simple content" within a complext type
    my role ContentX does NodeX {
    }

    my role NamespaceX[Str :$xml-namespace, Str :$xml-namespace-prefix] does NodeX {
        has Str $.xml-namespace        = $xml-namespace;
        has Str $.xml-namespace-prefix = $xml-namespace-prefix;
    }

    # Just a stub as only used for signalling
    my role SkipNullX does NodeX {
    }

    my role SerialiseX[&serialiser] {
        has &.serialiser = &serialiser;
        method serialise($value) {
            self.serialiser.($value);
        }
    }

    my role DeserialiseX[&deserialiser] {
        has &.deserialiser = &deserialiser;
        method deserialise($value) {
            self.deserialiser.($value);
        }
    }

    # xml-any
    my role AnyX {
    }

    # Dummy class to substitute for the actual type
    # when we have an AnyX
    my class XmlAny {

    }

    multi sub trait_mod:<is> (Attribute $a, :$xml-any!) is export {
        $a does AnyX;
    }

    multi sub trait_mod:<is> (Attribute $a, :&xml-serialise!) is export {
        $a does SerialiseX[&xml-serialise];
    }

    multi sub trait_mod:<is> (Attribute $a, :&xml-deserialise!) is export {
        $a does DeserialiseX[&xml-deserialise];
    }
    multi sub trait_mod:<is> (Attribute $a, :$xml-skip-null!) is export {
        $a does SkipNullX;
    }

    multi sub trait_mod:<is> (Attribute $a, :$xml-simple-content!) is export {
        $a does ContentX;
    }

    multi sub trait_mod:<is> (Attribute $a, Str :$xml-namespace) is export {
        $a does NamespaceX[:$xml-namespace];
    }
    multi sub trait_mod:<is> (Attribute $a, :$xml-namespace! (Str $namespace, $namespace-prefix?)) is export {
        $a does NamespaceX[xml-namespace => $namespace, xml-namespace-prefix => $namespace-prefix];
    }

    multi sub trait_mod:<is> (Attribute $a, :$xml-container) is export {
        $a does ContainerX;
        if $xml-container.defined && $xml-container ~~ Str {
            $a.container-name = $xml-container;
        }
    }

    multi sub trait_mod:<is> (Attribute $a, Bool :$xml-attribute!) is export {
        $a does AttributeX;
    }

    multi sub trait_mod:<is> (Attribute $a, Str:D :$xml-attribute!) is export {
        $a does AttributeX;
        $a.xml-name = $xml-attribute;
    }

    multi sub trait_mod:<is> (Attribute $a, Bool :$xml-element!) is export {
        $a does ElementX;
    }
    multi sub trait_mod:<is> (Attribute $a, Str:D :$xml-element!) is export {
        $a does ElementX;
        $a.xml-name = $xml-element;
    }

    sub apply-namespace(Attribute $attribute) {

    }


    my role ElementWrapper {

        has Str $.xml-namespace        is rw;
        has Str $.xml-namespace-prefix is rw;

        method xml-namespace-prefix() is rw {
            if not $!xml-namespace-prefix.defined {
                if not $!xml-namespace.defined {
                    if self.parent.defined {
                        $!xml-namespace-prefix = self.parent.?xml-namespace-prefix;
                    }
                }
            }
            $!xml-namespace-prefix;
        }

        # These are for parsing, the above is for generating
        has Str $.local-name;

        method local-name() {
            if not $!local-name.defined {
                if $.name.index(':') {
                    ( $!prefix, $!local-name) = $.name.split(':', 2);
                }
                else {
                    $!local-name = $.name;
                }
            }
            $!local-name;
        }

        has Str $.prefix;

        # may not be a prefix but will always be a local-name
        method prefix() {
            if not $!local-name.defined {
                my $ = self.local-name;
            }
            $!prefix;
        }


        has Str %.namespaces;

        method local-namespaces() {
            sub map-ns(Pair $p) {
                my $key = do if $p.key.index(':') { 
                        $p.key.split(':')[1] 
                } 
                else { 
                    'default'
                }; 
                $key => $p.value;
            }
            self.attribs.pairs.grep( { $_.key.starts-with('xmlns') }).map(&map-ns).hash;
        }

        method namespaces() {
            if not %!namespaces.keys {
                my %parents;
                if self.parent.defined {
                    if self.parent.can('namespaces') {
                        %parents = self.parent.namespaces;
                    }
                }
                %!namespaces = %parents, self.local-namespaces;
            }
            %!namespaces;
        }

        method namespace() {
            my $prefix = self.prefix // 'default';
            self.namespaces{$prefix};
        }

        method prefix-for-namespace(Str:D $ns) {
            self.namespaces.invert.hash{$ns};
        }

        method add-object-attribute(Mu $val, Attribute $attribute) {
            if $attribute.has_accessor {
                my $name = self.make-name($attribute);
                my $value = $val.defined ?? $attribute.get_value($val) !! $attribute.type;
                if $attribute !~~ SkipNullX || $value.defined {
                    my $values = serialise($value, $attribute);
                    self.add-value($name, $values);
                }
            }
        }

        method add-wrapper(Attribute $a) returns XML::Element {
            my XML::Element $wrapped = self;
            if $a.defined && $a ~~ ElementX && !$a.from-serialise {
                my $t = create-element($a);
                $t.insert(self);
                $wrapped = $t;
            }
            $wrapped;
        }

        method make-name(Attribute $attribute) returns Str {
            my $name =  do given $attribute {
                when NameX {
                    $attribute.xml-name;
                }
                default {
                    $attribute.name.substr(2);
                }
            }
            $name;
        }

        method add-value(Str $name, $values ) {
            for $values.list -> $value {
                given $value {
                    when ElementWrapper {
                        if $!xml-namespace-prefix.defined {
                            $value.xml-namespace-prefix //= $!xml-namespace-prefix;
                        }
                        self.append($value);
                    }
                    when XML::Element {
                        self.append($value);
                    }
                    when XML::Text {
                        self.append($value);
                    }
                    when Pair {
                        self.set($_.key, $_.value);
                    }
                    default {
                        self.set($name, $value);
                    }
                }
            }
        }

        multi sub check-role(Any:U) {
            Nil
        }
        multi sub check-role(ElementWrapper $element) returns ElementWrapper {
            $element;
        }

        multi sub check-role(XML::Element $element where * !~~ ElementWrapper ) returns ElementWrapper {
            if $element !~~ $?ROLE {
                $element does $?ROLE;
            }
            $element
        }

        multi sub check-role(XML::Text $node) {
            $node;
        }

        method first-child() {
            check-role(self.firstChild // Nil);
        }

        # better find by namespace
        method find-child(Str $name, Str $ns?) {
            my $element = self.elements(TAG => $name, :SINGLE) || self.elements.map(&check-role).grep({ $_.local-name eq $name && $_.namespace eq $ns}).first;
            check-role($element);
        }

        method find-children(Str $name, Str $ns?) {
            (self.elements(TAG => $name) || self.elements.map(&check-role).grep({ $_.local-name eq $name && $_.namespace eq $ns})).map(&check-role);
        }

        multi method positional-element(Attribute $attribute, Cool $t) {
            check-role(self.firstChild);
        }

        multi method positional-element(Attribute $attribute, Mu $t) {
            check-role( $attribute ~~ ElementX ?? self.firstChild !! self);
        }

        multi method positional-children(Str $name, Attribute $attribute where * !~~ AnyX, Mu $t, Str :$namespace) {
            my @elements;

            for self.find-children($name, $namespace) -> $node {
                @elements.append: $node.positional-element($attribute, $t);
            }
            @elements;
        }

        multi method positional-children(Str $name, AnyX $attribute, Mu $t, Str :$namespace ) {
            my @elements;
            for self.elements.map(&check-role) -> $node {
                @elements.append: $node.positional-element($attribute, $t);
            }
            @elements;
        }

        method strip-wrapper(Attribute $attribute, Str :$namespace is copy) {

            if !$namespace.defined || $attribute ~~ NamespaceX {
                $namespace = $attribute ~~ NamespaceX ?? $attribute.xml-namespace !! self.namespace;
            }
            
            check-role($attribute ~~ ContainerX ?? self.find-child($attribute.container-name, $namespace) !! self);
        }

        method setNamespace($uri, $prefix?) {
            self.XML::Element::setNamespace($uri, $prefix);
            $!xml-namespace = $uri;
            if $prefix.defined {
                $!xml-namespace-prefix = $prefix;
            }
        }

        method name() is rw {
            my $n = self.XML::Element::name();
            if self.xml-namespace-prefix {
                $n = self.xml-namespace-prefix ~ ':' ~ $n;
            }
            $n;
        }
    }

    multi sub create-element(Attribute $a, Bool :$container) returns XML::Element {
        my $name = do if $container {
            $a.container-name;
        }
        else {
            $a ~~ ElementX ?? $a.xml-name !! $a.name.substr(2);
        }
        my $x = do if $a ~~ NamespaceX {
            if $a ~~ ContainerX && !$container {
                create-element($name);
            }
            else {
                create-element($name, $a.xml-namespace, $a.xml-namespace-prefix);
            }
        }
        else {
            create-element($name);
        }
        $x;
    }

    multi sub create-element(Str:D $name, Any:U $?, Any:U $? ) returns XML::Element {
        my $x = XML::Element.new(:$name);
        $x does ElementWrapper;
        $x;
    }

    multi sub create-element(Str:D $name, Str $xml-namespace, $xml-namespace-prefix?) {
        my $xe = samewith($name);
        if $xml-namespace.defined {
            $xe.setNamespace($xml-namespace, $xml-namespace-prefix);
        }
        $xe;
    }

    
    my subset PoA of Attribute where { $_ !~~ NodeX};

    # serialise should have the most specific type
    # first and then call the one with a specific
    # attribute with the string representation

    
    multi sub serialise($val, SerialiseX $a) {
        my $str = $a.serialise($val);
        serialise($str, $a);
    }


    my subset DoA of Attribute where { $_ !~~ SerialiseX };

    multi sub serialise(Bool $val, DoA $a) {
        my $str = $val ?? 'true' !! 'false';
        serialise($str, $a);
    }

    multi sub serialise(Real $val, DoA $a) {
        my $v = $val.defined ?? $val.Str !! '';
        serialise($v, $a);
    }

    multi sub serialise(DateTime $val, DoA $a) {
        my $v = $val.defined  ?? $val.Str !! '';
        serialise($v, $a);
    }

    multi sub serialise(Date $val, DoA $a) {
        my $v = $val.defined  ?? $val.Str !! '';
        serialise($v, $a);
    }

    multi sub serialise(Str $val, ElementX $a) {
        my $x = create-element($a);
        if $val.defined {
            $x.insert(XML::Text.new(text => $val));
        }
        $x;
    }


    # Not sure why this works in some places and not others
    # hence the overly specific param

    my subset NoArray of Cool where * !~~ Positional|Associative;

    multi sub serialise(Str $val, PoA $a) {
        $val // '';
    }

    multi sub serialise(Cool $val, AttributeX $a) {
        ($a.xml-name => $val);
    }

    # One big sub because the multis were getting out of control
    multi sub serialise(@vals, Attribute $a) {
        my @els;
        for @vals.list -> $value {
            # we always want elements so set this but some objects we want the user to choose
            # whether they get the additional container so indicate we added it.
            @els.append: serialise($value, $a ~~ ElementX ?? $a !! $a but ElementX[:from-serialise]);
        }
        if $a ~~ ContainerX {
            my $el = create-element($a, :container);

            for @els -> $item {
                $el.append($item);
            }
            @els = ($el);
        }
        @els;
    }

    # this is simplified because adding them as XML attributes
    # is almost impossible to do in the reverse direction
    multi sub serialise(%vals, Attribute $a) {
        my $els = create-element($a);
        for %vals.kv -> $key, $value {
            $els.insert($key, $value);
        }
        $els;
    }


    multi sub serialise(XML::Class $val, Attribute $a) {
        $val.to-xml(:element, attribute => $a);
    }

    multi sub serialise(Cool $val, ContentX $a) {
        if $val.defined {
            XML::Text.new(text => $val);
        }
        else {
            Nil
        }
    }


    multi sub serialise(Mu $val, Attribute $a, $xml-element?, $xml-namespace?, $xml-namespace-prefix? ) {
        my $name = $xml-element // $val.^shortname;
        my $ret;
        # if it really isn't defined and we don't know what type it is skip it
        if !(!$val.defined && $val.WHAT =:= Any ) {
            my $xe = create-element($name, $xml-namespace, $xml-namespace-prefix);
            for $val.^attributes -> $attribute {
                $xe.add-object-attribute($val, $attribute);
            }
            # Add a wrapper if asked for
            # the from-serialise is true when this was set by default
            # in the Positional serialise.
            $ret = $xe.add-wrapper($a);
        }
        else {
            # however we may want the container nonetheless
            if $a.defined && $a ~~ ElementX && !$a.from-serialise {
                $ret = create-element($a);
            }
        }
        $ret;
    }

    multi method to-xml() returns Str {
        self.to-xml(:document).Str;
    }
    multi method to-xml(:$document!) returns XML::Document {
        my $xe = self.to-xml(:element);
        XML::Document.new($xe);
    }
    multi method to-xml(:$element!, Attribute :$attribute) returns XML::Element {
        serialise(self, $attribute, $xml-element, $xml-namespace, $xml-namespace-prefix);
    }

    multi method from-xml(XML::Class:U: Str $xml) returns XML::Class {
        my $doc = XML::Document.new($xml);
        self.from-xml($doc);
    }

    multi method from-xml(XML::Class:U: XML::Document:D $xml) returns XML::Class {
        my $root = $xml.root;
        self.from-xml($root);
    }

    multi method from-xml(XML::Class:U: XML::Element:D $xml, Attribute :$attribute) returns XML::Class {
        deserialise($xml, $attribute, self, :outer);
    }

    # Helpers should be moved
    multi sub get-positional-name(Attribute $attribute, Cool $t, :$namespace) {
        $attribute ~~ ElementX ?? $attribute.xml-name !! $attribute.name.substr(2);
    }

    multi sub get-positional-name(Attribute $attribute, Mu $t, Str :$namespace) {
        $attribute ~~ ElementX ?? $attribute.xml-name !! $t ~~ XML::Class ?? $t.xml-element !! $t.^shortname;
    }
    # Make sure we have all our helpers
    multi sub deserialise(XML::Element $element where * !~~ ElementWrapper,|c) {
        $element does ElementWrapper;
        deserialise($element, |c);
    }


    # For deserialise the most specific Attribute.type with the least specific type of Attribute
    # for scalar, aggregate types will call deserialise on the parts.
    # They also need to deal with either a Wrapped element or an XML::Text

    my subset TypedNode of XML::Node where * ~~ XML::Text|ElementWrapper;

    # This one implements "custom deserialisation"
    multi sub deserialise(TypedNode $element, DeserialiseX $attribute, $obj, Str :$namespace) {
        my $val = deserialise($element, $attribute, Str, :$namespace);
        $attribute.deserialise($val);
    }

    my subset SoA of Attribute where { $_ !~~ DeserialiseX };

    multi sub deserialise(TypedNode $element, SoA $attribute, Bool $obj, Str :$namespace) {
        my $val = deserialise($element, $attribute, Str, :$namespace);
        $val.defined ?? ($val eq 'true' || $val eq '1' ) ?? True !! False !! False;
    }

    
    multi sub deserialise(TypedNode $element, SoA $attribute, $obj where { $_.HOW ~~ Metamodel::SubsetHOW }, Str :$namespace) {
        my $type = $obj.^refinee;
        deserialise($element, $attribute, $type, :$namespace);
    }

    multi sub deserialise(TypedNode $element, SoA $attribute, DateTime $obj, Str :$namespace) {
        my $val = deserialise($element, $attribute, Str, :$namespace);
        my DateTime $d = try DateTime.new($val);
        $d;
    }

    multi sub deserialise(TypedNode $element, SoA $attribute, Date $obj, Str :$namespace) {
        my $val = deserialise($element, $attribute, Str, :$namespace);
        my Date $d = try Date.new($val);
        $d;
    }

    multi sub deserialise(TypedNode $element, SoA $attribute, Real $obj where { $_.HOW !~~ Metamodel::SubsetHOW }, Str :$namespace) {
        my $val = deserialise($element, $attribute, Str, :$namespace);
        $val.defined ?? $obj($val) !! $obj;
    }

    multi sub deserialise(ElementWrapper $element, PoA $attribute, Str $obj, Str :$namespace) {
        my $val = $element.attribs{$attribute.name.substr(2)};
        $val;
    }

    multi sub deserialise(ElementWrapper $element, AttributeX $attribute, Str $obj, Str :$namespace) {
        my $val = $element.attribs{$attribute.xml-name};
        $val;
    }

    multi sub deserialise(ElementWrapper $element, ElementX $attribute, XmlAny $obj, Str :$namespace is copy) {
        my $name = $attribute.xml-name;

        if $attribute ~~ NamespaceX {
            $namespace = $attribute.xml-namespace;
        }

        my $node = $element.find-child($name, $namespace);
        my $ret = do if $node.defined {
            my $child = $node.first-child;
            given $child {
                when XML::Text {
                    $child.Str;
                }
                when XML::CDATA {
                    $child.data;
                }
                when XML::Element {
                    if $child.namespace -> $ns {
                        if %*NS-MAP and %*NS-MAP{$ns}:exists {
                            deserialise($child, $attribute, %*NS-MAP{$ns}, namespace => $ns);
                        }
                        else {
                            Nil;
                        }
                    }
                    else {
                        Nil;
                    }
                }
                default {
                    $obj; # the element has no child;
                }
            }
        }
        else {
            $obj;
        }
        $ret;
    }

    multi sub deserialise(ElementWrapper $element, ElementX $attribute, Str $obj, Str :$namespace is copy) {
        my $name = $attribute.xml-name;

        if $attribute ~~ NamespaceX {
            $namespace = $attribute.xml-namespace;
        }

        my $node = $element.find-child($name, $namespace);
        my $ret = do if $node.defined {
            my $child = $node.firstChild;
            given $child {
                when XML::Text {
                    $child.Str;
                }
                when XML::CDATA {
                    $child.data;
                }
                when XML::Element {
                    Nil; # Almost certainly got here because it was an untyped attribute
                }
                default {
                    $obj; # the element has no child;
                }
            }
        }
        else {
            $obj;
        }
        $ret;
    }

    multi sub deserialise(ElementWrapper $element, ContentX $attribute, $obj, Str :$namespace) {
        $element.firstChild.Str;
    }

    multi sub deserialise(XML::Text $text, Attribute $attribute, Str $obj, Str :$namespace) {
        $text.Str;
    }

    multi sub derive-type(Mu $type is raw, ElementWrapper $e, Attribute $a where * !~~ AnyX) {
        $type =:= Mu ?? Str !! $type;
    }

    multi sub derive-type(Mu $type is raw, ElementWrapper $e, AnyX $a) {
        $type =:= Mu ?? XmlAny !! $type;
    }

    multi sub deserialise(ElementWrapper $element, Attribute $attribute, @obj, Str :$namespace is copy) {
        my @vals;
        my $t = derive-type(@obj.of, $element, $attribute);
        my $name = get-positional-name($attribute, $t, :$namespace);
        if not $namespace.defined {
            $namespace = $t ~~ XML::Class ?? $t.xml-namespace !! $element.namespace;
        }
        my $e = $element.strip-wrapper($attribute, :$namespace);

        if $e.defined {
            $namespace = $t ~~ XML::Class ?? $t.xml-namespace !! $attribute ~~ NamespaceX ?? $attribute.xml-namespace !! $e.namespace;
            for $e.positional-children($name, $attribute, $t, :$namespace) -> $node {
                if $t ~~ XmlAny {
                    if $node.namespace -> $ns {
                        if %*NS-MAP and %*NS-MAP{$ns}:exists {
                            @vals.append: deserialise($node, $attribute, %*NS-MAP{$ns}, namespace => $ns);
                        }
                    }
                }
                else {
                    @vals.append:  deserialise($node, $attribute, $t, :$namespace);
                }
            }
        }
        @vals;
    }

    multi sub deserialise(ElementWrapper $element, Attribute $attribute, Cool %obj, Str :$namespace) {
        my %vals;

        if $attribute ~~ ElementX {
            my $name = $attribute.xml-name;
            my $c = $element.elements(TAG => $name, :SINGLE);
            for $c.nodes -> $node {
                %vals{$node.name} = deserialise($node.firstChild, $attribute, %obj.of, :$namespace);
            }
        }
        else {
            warn "Unable to deserialise this Hash from XML";
        }
        %vals;
    }


    multi sub deserialise(ElementWrapper $element is copy, Attribute $attribute, Mu $obj, Str :$namespace, Bool :$outer) {

        my $name = $obj ~~ XML::Class ?? $obj.xml-element !! $obj.^shortname;

        my Str $ns = $obj ~~ XML::Class ?? $obj.xml-namespace // $namespace !! $namespace;

        if $ns {
            my $prefix = $element.prefix-for-namespace($ns);
            if $prefix  && $prefix ne 'default' {
                $name = "$prefix:$name";
            }
        }


        if $attribute ~~ ElementX and $element.name ne $name {
            my $name = $attribute.xml-name;
            $element = $element.find-child($name, $ns);
            if !$element && $outer {
                X::NoElement.new(element => $name, attribute => $attribute).throw
            }
        }
        if $element.defined and $element.name ne $name {
            $element = $element.find-child($name, $ns);
            if !$element && $outer {
                X::NoElement.new(element => $name, attribute => $attribute).throw
            }
        }


        my $ret = $obj;
        if $element {
            my %args;
            for $obj.^attributes -> $attr {
                my $attr-name = $attr.name.substr(2);
                my $type = derive-type($attr.type, $element, $attr);
                %args{$attr-name} := deserialise($element, $attr, $type, namespace => $ns);
            }
            $ret = $obj.new(|%args);
        }
        $ret;
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
