NAME
====

XML::Class - Role to Serialize/De-Serialize a Perl 6 class to/from XML

SYNOPSIS
========

    use XML::Class;

    class Foo does XML::Class[xml-element => 'foo'] {
        has Int $.version = 0;
        has Str $.zub is xml-element;
    }

    my $f = Foo.new(zub => "pow");

    say $f.to-xml; # <?xml version="1.0"?><foo xmlns="http://example.com/" version="0"><zub>pow</zub></foo>

There are more examples in the [USAGE](#USAGE) section below.

DESCRIPTION
===========

This provides a relatively easy way to instantiate a Perl 6 object from XML and create XML that describes the Perl 6 class in a consistent manner.

It is somewhat inspired by the `XmlSerialization` class of the .Net framework, but there are other antecedents.

Using a relatively static definition of the relation between a class and XML that represents it means that XML can be consistently parsed and generated in a way that should always remain valid to the original description.

This module aims to map between Perl 6 object attributes and XML by providing some default behaviours and some attribute traits to alter that behaviour to model the XML.

By default scalar attributes who's value type can be expressed as an XML simple type (e.g. strings, real numbers, boolean, datetimes) will be serialised as attribute values or (with an `xml-element` trait,) as elements with simple content. positional attributes will always be serialised as a sequence of elements (with an optional container specified by a trait,) likewise associative attributes (though the use of these is discouraged as there is no constraint on the names of the elements which are taken from the keys of the Hash.) Perl 6 classes are expressed as XML complex types with the same serialisation as above. Provision is also made for the serialisation and de-serialisation of other than the builtin types to simple contemt (trivial examples might be Version objects for instance,) and for the handling of data that might be unknown at definition time (such as the xsd:Any in SOAP head and body elements,) by the use of "namespace maps".

There are things that explicitly aren't catered for such as "mixed content" (that is where XML markup may be within text content as in XHTML for example,) but that shouldn't be a problem for data storage or messaging applications for the most part.

METHODS
=======

The role only supplies two public methods.

method to-xml
-------------

    multi method to-xml() returns Str
    multi method to-xml(:$document!) returns XML::Document
    multi method to-xml(:$element!, Attribute :$attribute) returns XML::Element

This outputs the object instance as its representation as XML, by default it will output as a Str which should be good for most applications however the `:document` or `:element` adverbs can be used to cause the output of an [XML::Document](XML::Document) or [XML::Element](XML::Element) which may be useful if some further processing is required. The `attribute` parameter in the latter case is used internally, but could be used to output the representation of a single Attribute of the object if that is useful for some application.

method from-xml
---------------

    multi method from-xml(XML::Class:U: Str $xml) returns XML::Class
    multi method from-xml(XML::Class:U: XML::Document:D $xml) returns XML::Class
    multi method from-xml(XML::Class:U: XML::Element:D $xml) returns XML::Class

This is a class method that should be called with the XML to be parsed into a new object that will be returned. It can take either a string representing the XML or a pre-parsed [XML::Document](XML::Document) or [XML::Element](XML::Element) if the application already has those in hand.

USAGE
=====

It's probably easiest to explain the bulk of this by example in the first place. The rules for deserialisation are symmetrical to those for serialisation, so all the examples below should be reversible.

CLASS DECLARATION
-----------------

[XML::Class](XML::Class) is a `role` which should be applied to a class when it is defined, the role itself has optional parameters that can be applied.

By default a serialised class will take the element name from the `shortname` of the class:

    class Foo::Bar does XML::Class {
        ...
    }

Will be serialised as:

    <Bar>
      ...
    </Bar>

If you need or want to use an alternative element name it can provided as a parameter to the role:

    class Foo::Bar does XML::Class[xml-element => 'Foobar'] {
        ...
    }

Will become:

    <Foobar>
       ...
    </Foobar>

    =end

    A namespace with an (optional) prefix can be applied too:

    =begin code

    class Foo::Bar does XML::Class[xml-element => 'Foobar', xml-namespace => 'urn:foo', xml-namespace-prefix => 'fo'] {
        ...
    }

Will be serialised as:

    <fo:Foobar xmlns:fo="urn:foo">
        ...
    </fo:Foobar>

Any namespace and/or prefix declared will remain the default for the rest of the class unless over-ridden explicitly with the `xml-namespace` trait or by the definition of any included XML::Class typed attributes.

SCALAR ATTRIBUTES
-----------------

Only object attributes with a public accessor will be serialised to XML.

By default a scalar attribute (that is with a `$.` sigil) of a "simple type" (that is strings, real numbers, bool, datetime and date) will be serialised as XML attributes with the same name as the Perl 6 attribute:

    class Foo::Bar does XML::Class {
        has Str $.string = "foo";
    }

Will be rendered to:

    <Bar string="foo">
        ...
    </Bar>

The name of the output (or input) attribute can be explicitly set with the `xml-attribute` trait, thus:

    class Foo::Bar does XML::Class {
        has Str $.string is xml-attribute('thing') = "foo";
    }

Will be rendered to:

    <Bar thing="foo">
        ...
    </Bar>

If your XML description calls for an element rather than an attribute then the `xml-element` trait should be used:

    class Foo::Bar does XML::Class {
        has Str $.string is xml-element = "foo";
    }

Will be rendered to:

    <Bar>
        <string>foo</string>
    </Bar>

An alternative name can be supplied to the `xml-element` trait:

    class Foo::Bar does XML::Class {
        has Str $.string is xml-element('Thing') = "foo";
    }

which will be rendered to:

    <Bar>
        <Thing>foo</Thing>
    </Bar>

POSITIONAL ATTRIBUTES
---------------------

Positional attributes are always serialised as a sequence of XML elements with the same element name. Thus:

    class Foo::Bar does XML::Class {
        has Str @.string = <a b>
    }

Will be output as:

    <Bar>
        <string>a</string>
        <string>b</string>
    </Bar>

The element name can be set by `xml-element`:

    class Foo::Bar does XML::Class {
        has Str @.string is xml-element('Thing') = <a b>
    }

Will be output as:

    <Bar>
        <Thing>a</Thing>
        <Thing>b</Thing>
    </Bar>

In the positional case `xml-element` without a supplied element name has no effect.

If you require a container around the elements (such that the attribute forms an XML complex typed element containing a sequence of zero or more of the same element type,) you can use the `xml-container` trait:

    class Foo::Bar does XML::Class {
        has Str @.string is xml-element('Thing') is xml-container('Things') = <a b>
    }

Which will be output as:

    <Bar>
        <Things>
            <Thing>a</Thing>
            <Thing>b</Thing>
        </Things>
    </Bar>

This could alternatively be expressed as a class typed attribute with its own single positional attribute, this is described below.

ASSOCIATIVE ATTRIBUTES
----------------------

Associative (or Hash,) attributes (that is those declared with the `%.` sigil,) will produce XML such that a container element is produced with the name of the attribute with a sequence of elements named after the keys of the hash:

    class Foo::Bar does XML::Class {
	    has %.bars = (a => 1, b => 2);

    }

Will produce the XML:

    <Bar>
        <bars>
            <a>1</a>
            <b>2</b>
        </bars>
    </Bar>

The name of the containing element can be set with the `xml-element` trait:

    class Foo::Bar does XML::Class {
	    has %.bars is xml-element('Bars') = (a => 1, b => 2);

    }

Will produce the XML:

    <Bar>
        <Bars>
            <a>1</a>
            <b>2</b>
        </Bars>
    </Bar>

In the associative case any `xml-container` trait will be ignored.

There is no way currently to alter the names of the inner elements, which may limit the usefulness of the output XML as it is easy to produce XML which does not conform to the target description: this can be somewhat mitigated by the use of an XML namespace on the attribute if the application supports it, however it is suggested that you should consider class typed attributes with a custom class to receive the data rather than using an associative attribute.

CLASS TYPED ATTRIBUTES
----------------------

A class typed attribute will be serialised to XML according to the rules described above for its own attributes such that it forms an element of complex content with the name derived from the shortname of the class. So the following:

    class Foo does XML::Class {
	    class Bar {
		    has Str $.attribute = "thing";
		    has Int $.element is xml-element  = 10;
	    }
	    has Bar $.bar = Bar.new;
    }

Will emit XML like:

    <Foo>
        <Bar attribute="thing">
            <element>10</element>
        </Bar>
    </Foo>

The same rule applies to positional attributes typed to a class:

    class Foo does XML::Class {
	    class Bar {
		    has Str $.attribute = "thing";
		    has Int $.element is xml-element  = 10;
	    }
	    has Bar @.bar = (Bar.new(attribute => "something", element => 42), Bar.new(attribute => "else", element => 666));
    }

Will give you:

    <Foo>
        <Bar attribute="something">
            <element>42</element>
        </Bar>
        <Bar attribute="else">
            <element>666</element>
        </Bar>
    </Foo>

As with positionals of simple types the `xml-container` trait allows the sequence to have an enclosing element.

If you wish to have an additional enclosing element for a single object then the `xml-element` trait can be applied:

    class Foo does XML::Class {
	    class Bar {
		    has Str $.attribute = "thing";
		    has Int $.element is xml-element  = 10;
	    }
	    has Bar $.bar is xml-element('Inner') = Bar.new;
    }

Giving:

    <Foo>
        <Inner>
            <Bar attribute="thing">
                <element>10</element>
            </Bar>
        </Inner>
    </Foo>

If the class of the attribute itself does [XML::Class](XML::Class) then any `xml-element`, `xml-namespace` and `xml-namespace-prefix` will be used:

    class Foo does XML::Class {
	    class Bar does XML::Class[xml-element => 'Thing', xml-namespace => 'urn:things', xml-namespace-prefix => 'th'] {
		    has Str $.attribute = "thing";
		    has Int $.element is xml-element  = 10;
	    }
	    has Bar $.bar = Bar.new;
    }

Results in:

    <Foo>
        <th:Thing xmlns:th="urn:things" attribute="thing">
            <th:element>10</th:element>
        </th:Thing>
    </Foo>

The class can, of course, be defined anywhere you see fit, it need not be within the outer class as it is above.

As alluded to above in the description of positional attributes it is entirely possible to represent the "sequence with container element" as a class with a single positional attribute:

    class Foo does XML::Class {
	    class Things {
		    has Str @.things is xml-element('Thing')  = <a b>;
	    }
	    has Things $.bar = Things.new;

    }

Will give semantically identical XML to the original example; which you choose to use should be determined by the design requirements of the application.

A common structure in XML is an element with one or more attributes as well as textual content, which in XSD terms is a "complex type with simple content" such as:

    <Foo>
      <Name lang="en">Foo</Name>
    </Foo>

Which can be expressed as a class with an attribute with the `xml-simple-content` trait:

    class Foo does XML::Class {
	    class Name {
		    has Str $.lang = 'en';
		    has Str $.name is xml-simple-content = 'Foo';
	    }
	    has Name $.bar = Name.new;
    }

Obviously this is reversible.

There can only be one `xml-simple-content` attribute per class, but there can be any number of XML attributes and possibly `xml-element`s.

XML NAMESPACES
--------------

As well as applying xml namespaces as parameters to the XML::Class role they can be applied on a per-element basis (possibly over-riding any effective namespace,) with the `xml-namespace` trait, currently namespaced XML attributes aren't supported.

    class Foo does XML::Class {
	    has Str $.bar is xml-element is xml-namespace('urn:bar','b') = "thing";
    }

Will give you:

    <Foo>
        <b:bar xmlns:b="urn:bar">thing</b:bar>
    </Foo>

The second, prefix, parameter to the trait is optional and if omitted the supplied namespace will become the default for the scope of the element.

This can be applied in combination with most other traits and attribute types, for example:

    class Foo does XML::Class {
	    has Str @.bar is xml-container('Bars') is xml-element is xml-namespace('urn:bar','b') = <a b c>;
    }

Will give you

    <Foo>
        <b:Bars xmlns:b="urn:bar">
            <b:bar>a</b:bar>
            <b:bar>b</b:bar>
            <b:bar>c</b:bar>
        </b:Bars>
    </Foo>

And, as alluded to in the discussion of associative parameters above, namespaces can be applied to a hash as:

    class Foo does XML::Class {
	    has %.bars is xml-element('Bars') is xml-namespace('urn:my-bars', 'ba') = (a => 1, b => 2);
    }

To give you:

    <Foo>
        <ba:Bars xmlns:ba="urn:my-bars">
            <ba:b>2</ba:b>
            <ba:a>1</ba:a>
        </ba:Bars>
    </Foo>

UNTYPED ATTRIBUTES
------------------

For the best consistency you should have typed attributes, however for simple content of the built in types (strings, real numbers, Bool, Date, DateTime and so forth,) they will be serialised correctly based on the type of the value, however because no type information is available they will always be deserialised from XML as strings (you are of course free to perform your own coercion later.) The same applies equally to the values of positional and associative attributes.

In the case of untyped attributes (or values of aggregate attributes,) where the values are objects that would suggest a "complex type" they will be serialised to XML as per the rules discussed above, however on deserialisation from XML if a complex type is found in the place of an untyped attribute then it will be skipped and the attribute will be left uninitialised silently, you can cause this to be an error by making the attribute 'required' in your class definition, though you probably want to avoid the situation by providing a type if at all possible.

However there are cases where a particular XML schema definition may explicitly provide for the presence of any element in a particular place, this is often used in messaging wrappers such as SOAP where the `Head` and `Body` elements are both defined in the schema as a sequence of 'any':

    <xs:sequence>
        <xs:any namespace="##other" minOccurs="0" maxOccurs="unbounded" processContents="lax"/>
    </xs:sequence>

This case is handled for the deserialisation case by the `xml-any` trait for the attributes where this is expected which indicates that special handling is required for the attribute value and (in your program code,) a dynamic variable `%*NS-MAP` which maps a possible namespace URI that may be found in the element to a type which will be instantiated to receive the content in the otherwise identical manner to statically declared types.

For example if one were to have a class defining a SOAP envelope like:

    class Envelope does XML::Class[xml-namespace => 'http://schemas.xmlsoap.org/soap/envelope/'] {
        has $.head is xml-any is xml-element('Head');
        has $.body is xml-any is xml-element('Body');
    }

And receive an Envelope like:

    <Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/">
        <Head/>
        <Body>
            <Data xmlns="urn:my-data">
                <Something>some data</Something>
            </Data>
        </Body>
    </Envelope>

Then the following code would get you the received Data object (assuming you have the envelope in `$xml` already:

    my %*NS-MAP = ('urn:my-data' => Data );

    my $e = Envelope.from-xml($xml);

    say $e.body.perl; # Data.new(something => "some data")

This allows you to create a SOAP client (or indeed server,) quite simply (though in reality the Body and Head elements are actually sequences of potentially multiple elements, the mechanism works equally well for differing elements mapped to differently mapped classes with a positional attribute.)

The `%*NS-MAP` can be defined in any scope above the `from-xml` which requires the namespace lookup and can be added to/removed from in the lifetime of your application.

If no matching namespace is found in the `%*NS-MAP` for that found to be in effect for the element being processed then nothing will be populated into the attribute marked `xml-any`.

OTHER TYPES AS SIMPLE CONTENT
-----------------------------

If your application has data types that aren't the builtin types but are nonetheless able to be expressed as "simple content" (that is they can be expressed as a string that contains sufficient information to recreate an object of the equivalent value,) then you can provide your own code with the `xml-serialise` and `xml-deserialise` traits to turn the object into a string and convert it back into an object of the same type respectively. A Perl 6 [Version](Version) object is a good example:

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

Would for instance populate correctly the Version object from this XML:

    <Versioned version-attribute="0.1.0">
        <version-element>2.0.1</version-element>
    </Versioned>

The only constraint on the code supplied for the traits is that for the serialise case it should have a single argument that is the of the type to be serialised and should return the appropriate string. For the deserialise case it should accept a single string (the value of the attribute or element,) and return an object of the appropriate type.

OMITTING EMPTY VALUES
---------------------

By default an uninitialised attribute will give rise to an XML attribute with the empty string as a value or an empty XML element, for many  applications this should be fine, however if a peer application requires a value to be defined or has some constraint if the element or attribute is present then the `xml-skip-null` trait can be applied which will cause the element or attribute to not be emitted at all if the Perl 6 attribute is not a defined value.
