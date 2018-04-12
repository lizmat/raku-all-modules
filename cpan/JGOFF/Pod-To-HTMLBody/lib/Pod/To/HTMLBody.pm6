use v6;

=begin pod

=head1 Pod::To::HTMLBody

Generate a simple HTML C<< <body/> >> fragment.

Subclass this in order to do your own HTML display.

=head1 Synopsis

    use Pod::To::HTMLBody;

    say Pod::To::HTMLBody.render( $=[0] );

=head1 Documentation

Somewhat up in the air at the moment.

=end pod

use Pod::To::Tree;

class Pod::To::HTMLBody:ver<0.0.1> {
	method HTML-start( $node ) {
		given $node {
			when Node::Bold { '<b>' }
			when Node::Code { '<code>' }
			when Node::Config { '' }
			when Node::Comment { '<!--' }
			when Node::Document { '<div>' }
			when Node::Entity { $node.contents } # XXX fix later
			when Node::Italic { '<i>' }
			when Node::Item { '<li>' }
			when Node::Link { qq[<a href="{$node.url}">] }
			when Node::List { '<ul>' }
			# XXX hack to show parent usage
			when Node::Paragraph {
				'<p>' unless $node.parent ~~ Node::Item
			}
			when Node::Section {
				qq[<section><h1>{$node.title}</h1>]
			}
			when Node::Reference { '<var>' }
			when Node::Heading { qq[<h{$node.level}>] }
			when Node::Text { $node.value }
			when Node::Table { '<table>' }
			when Node::Table::Header { '<th>' }
			when Node::Table::Data { '<td>' }
			when Node::Table::Body { '' }
			when Node::Table::Body::Row { '<tr>' }
			when Node::Underline { '<u>' }
			default {
				die "Don't know how to start HTML for $node!"
			}
		}
	}

	# Another way to write walker methods that are subclassable.
	#
	multi method HTML-end( Node::Bold $node ) { '</b>' }
	multi method HTML-end( Node::Code $node ) { '</code>' }
	multi method HTML-end( Node::Config $node ) { '' }
	multi method HTML-end( Node::Comment $node ) { '-->' }
	multi method HTML-end( Node::Document $node ) { '</div>' }
	multi method HTML-end( Node::Entity $node ) { '' }
	multi method HTML-end( Node::Item $node ) { '</li>' }
	multi method HTML-end( Node::Italic $node ) { '</i>' }
	multi method HTML-end( Node::Link $node ) { '</a>' }
	multi method HTML-end( Node::List $node ) { '</ul>' }
	# XXX hack to show parent usage
	multi method HTML-end( Node::Paragraph $node ) {
		'</p>' unless $node.parent ~~ Node::Item
	}
	multi method HTML-end( Node::Section $node ) { '</section>' }
	multi method HTML-end( Node::Reference $node ) { '</var>' }
	multi method HTML-end( Node::Heading $node ) { qq[</h{$node.level}>] }
	multi method HTML-end( Node::Text $node ) { '' }
	multi method HTML-end( Node::Table $node ) { '</table>' }
	multi method HTML-end( Node::Table::Header $node ) { '</th>' }
	multi method HTML-end( Node::Table::Data $node ) { '</td>' }
	multi method HTML-end( Node::Table::Body $node ) { '' }
	multi method HTML-end( Node::Table::Body::Row $node ) { '</tr>' }
	multi method HTML-end( Node::Underline $node ) { '</u>' }
	multi method HTML-end( $node ) {
		die "Don't know how to end HTML for $node!"
	}

	method walk( $node ) {
		my $html = '';
		$html ~= self.HTML-start( $node );
		my $child = $node.first-child;
		while $child {
			$html ~= self.walk( $child );
			$child = $child.next-sibling;
		}
		$html ~= self.HTML-end( $node );
		$html;
	}

	method render( $pod ) {
		my $tree = Pod::To::Tree.to-tree( $pod );
#say $tree.visualize;
		return self.walk( $tree );
	}
}

# vim: ft=perl6
