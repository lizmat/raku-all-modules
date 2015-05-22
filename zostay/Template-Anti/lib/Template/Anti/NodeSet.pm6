use v6;

use XML;

use Template::Anti::Selector;

=begin pod

=TITLE class Template::Anti::NodeSet

=SUBTITLE Class for traversing and maniuplating documents

=begin SYNOPSIS

    use Template::Anti;
    my $tmpl = Template::Anti.load(
        '<html><head><title>Hello World</title>...'
    );

    # $ns is a Template::Anti::NodeSet
    my $ns = $tmpl('title');

    # But you might just want to work with NodeSets like this:
    $tmpl('title, h1').text('Sith Lords');
    $tmpl('h1').attrib(title => 'The Force shall free me.');
    $tmpl('ul.people').truncate(1);
    $tmpl('ul.people li').apply([
        { name => 'Vader',   url => 'http://example.com/vader' },
        { name => 'Sidious', url => 'http://example.com/sidious' },
    ]).via: -> $item, $sith-lord {
        my $a = $item.find('a');
        $a.text($sith-lord<name>);
        $a.attrib(href => $sith-lord<url>);
    });

=end SYNOPSIS

=begin DESCRIPTION

A NodeSet object is returned by L<Template::Anti::Template> whenever a selector is run against some source. The selector may be empty. Operations may be run agains the selector to retrieve sub-selectors or get information about the document or manipulate the document.

As the purpose of this class is basically write-only, most methods of this class return the invocant. This way method calls may be easily chained together without having to assign them to a variable.

=end DESCRIPTION

=head1 Attributes

=head2 has @.nodes

    has XML::Node @.nodes

These are the L<XML::Node> nodes that the node set contain.

=head2 has @.data

    has @.data

This is the current data associated with the node set for use with D<method via>.

=head1 Methods

=head2 method text

    method text(Template::Anti::NodeSet:D: Str $text) returns Template::Anti::NodeSet

Replaces the contents of the contianed nodes with the given C<$text>.

Returns the node set object so that this method may chained.

=head2 method attrib

    method attrib(Template::Anti::NodeSet:D: *%attribs) returns Template::Anti::NodeSet

Sets the attributes of the contained nodes according to the pairs given in C<%attribs>.

Returns the node set object so that this method may be chained.

=head2 method truncate

    method truncate(Template::Anti::NodeSet:D: Int $keep = 0) returns Template::Anti::NodeSet

This deletes all the child nodes of the nodes in the set. If C<$keep> is set to a non-zero value, then the first C<$keep> L<XML::Element> nodes found will be kept, but the rest will be destroyed.

=head2 method apply

    method apply(Template::Anti::NodeSet:D: @data) returns Template::Anti::NodeSet

This sets D<has @.data> to the list of data models of your choice. This prepares the object for call C<method via>.

=head2 method via

    method via(Template::Anti::NodeSet:D: &code) returns Template::Anti::NodeSet

This method iterates over D<has @.data> set by D<method apply> and calls C<&code> for each piece of data. The C<&code> will be passed a new L<Template::Anti::NodeSet> along with each model in the data. The nodes in the node set will either be the original nodes, or a cloned copy of them that have been appended to their respective original's parent.

If the number of models in the data set by C<apply> is 0, then the matched nodes will be removed.

For example, say you have a list in your input like this:

    <ul class="people">
        <li><a href="#">Name</a></li>
    </ul>

And you then use C<apply> and C<via> like so:

    $at('ul.people li').apply([
        { name => 'Vader',   url => 'http://example.com/vader' },
        { name +> 'Sidious', url => 'http://example.com/sidious' },
    ]).via: -> $item, $sith-lord {
        my $a = $item.find('a');
        $a.text($sith-lord<name>);
        $a.attrib(href => $sith-lord<url>);
    };

You will generate output like this:

    <ul class="people">
        <li><a href="http://example.com/vader">Vader</a></li>
        <li><a href="http://example.com/sidious">Sidious</a></li>
    </ul>

=head2 method find

    method find(Template::Anti::NodeSet:D: Str $selector) returns TEmplate::Anti::NodeSet

This method I<does not> return the object itself. Instead, it applies the given C<$selector> against all the contained nodes and returns a new L<Template::Anti::NodeSet> containing those nodes.

=end pod

class Template::Anti::NodeSet {
    has XML::Node @.nodes; #= The nodes within the node set (may be empty)
    has @.data;  #= A list of models to use by D<method via>

    method text(Str $text) {
        self.truncate;
        for @!nodes -> $node {
            $node.append(XML::Text.new(:$text));
        }

        self
    }

    method attrib(*%attribs) {
        for @!nodes -> $node {
            for %attribs.kv -> $name, $value {
                $node.set($name, $value);
            }
        }

        self
    }

    method truncate(Int $keep = 0) {
        for @!nodes -> $node {
            my $kept = 0;

            if $keep == 0 {
                $node.nodes = ();
            }

            else {
                for $node.nodes {
                    when XML::Element { .remove if $kept++ >= $keep }
                    when XML::Node    { .remove }
                    default           { }
                }
            }
        }


        self
    }

    method apply(@!data) { self }

    method via(&code) {
        if @!data {
            my $needs-cloning = False;
            for @!data -> $d {
                my @nodes = @!nodes;
                if $needs-cloning++ {
                    @nodes.=map: {
                        my $clone = $^orig.cloneNode;
                        $orig.parent.append($clone);
                        $clone
                    }
                }

                my $node-set = Template::Anti::NodeSet.new(:@nodes);
                &code($node-set, $d);
            }
        }
        else {
            @!nodes».remove;
        }

        self
    }

    method find(Str $selector) {
        my @new-nodes = @!nodes.map: -> $source {
            my $sq = Template::Anti::Selector.new(:$source);
            $sq($selector)
        }

        Template::Anti::NodeSet.new(:nodes(@new-nodes));
    }
}

