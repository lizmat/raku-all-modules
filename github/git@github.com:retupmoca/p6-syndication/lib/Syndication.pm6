use XML;

role Syndication::Item {
    has Str $.title;
    has Str $.link;
    has Str $.summary;
    has Str $.author;
    has DateTime $.updated;
}
role Syndication {
    has Str $.title;
    has Str $.link;
    has Str $.description;
    has @.items;
}

##

class Syndication::RSS::Item does Syndication::Item {
    method XML {
        my $xml = XML::Element.new(:name<item>);
        $xml.append: XML::Element.new(:name<title>, :nodes([$.title]));
        $xml.append: XML::Element.new(:name<link>, :nodes([$.link]));
        $xml.append: XML::Element.new(:name<guid>, :nodes([$.link]));
        $xml.append: XML::Element.new(:name<description>, :nodes([$.summary]));
        $xml.append: XML::Element.new(:name<pubDate>, :nodes([~$.updated]));
        $xml.append: XML::Element.new(:name<author>, :nodes([$.author]));

        return $xml;
    }
}
class Syndication::RSS does Syndication {
    multi method new($xml) {
        die "Parsing NYI";
    }

    method XML {
        my $xml = XML::Element.new(:name<rss>, :attribs({:version('2.0')}));
        my $channel = XML::Element.new(:name<channel>);
        $xml.append: $channel;
        $channel.append: XML::Element.new(:name<title>, :nodes([$.title]));
        $channel.append: XML::Element.new(:name<link>, :nodes([$.link]));
        $channel.append: $_.XML for @.items;

        return $xml;
    }

    method Str { ~self.XML }
}

class Syndication::Atom::Item does Syndication::Item {
    method XML {
        my $xml = XML::Element.new(:name<entry>);
        $xml.append: XML::Element.new(:name<title>, :nodes([$.title]));
        $xml.append: XML::Element.new(:name<link>, :attribs({:href($.link), :rel<alternate>}));
        $xml.append: XML::Element.new(:name<id>, :nodes([$.link]));
        $xml.append: XML::Element.new(:name<summary>, :nodes([$.summary]));
        $xml.append: XML::Element.new(:name<updated>, :nodes([~$.updated]));
        my $author = XML::Element.new(:name<author>);
        $author.append: XML::Element.new(:name<email>, :nodes([$.author]));
        $xml.append: $author;

        return $xml;
    }
}
class Syndication::Atom does Syndication {
    multi method new($xml) {
        die "Parsing NYI";
    }

    method XML {
        my $xml = XML::Element.new(:name<feed>, :attribs({:xmlns('http://www.w3.org/2005/Atom')}));
        $xml.append: XML::Element.new(:name<id>, :nodes([$.link]));
        $xml.append: XML::Element.new(:name<title>, :nodes([$.title]));
        $xml.append: XML::Element.new(:name<updated>, :nodes([@.items.map({$_.updated}).max]));
        $xml.append: $_.XML for @.items;

        return $xml;
    }

    method Str { ~self.XML }
}
