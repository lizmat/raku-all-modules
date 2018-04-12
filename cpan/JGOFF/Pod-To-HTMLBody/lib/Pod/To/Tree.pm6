use v6;

=begin pod

=head1 Pod::To::Tree

Return a tree of Node:: objects from Perl 6 POD.

=head1 Synopsis

    use Pod::To::Tree;

    say Pod::To::Tree.new.to-tree( $=[0] );

=head1 Documentation

=head2 Motivation

The Perl 6 POD tree works out nicely, overall. There are a few places, however, that if you want to generate HTML you might run into some issues. Walking the tree of an item naively would get you C<< <li> <p> foo </p> </li> >> - one element for the outer L<Pod::Item>, then the L<Pod::Block::Para> inside that, and inside that the content text 'foo'.

It's pretty easy to deal with this in code, it must be said. You could keep track of when you enter and exit a L<Pod::Item> node, and inside your L<Pod::Block::Para> handling code, check to see if you're in a L<Pod::Item> node and suppress the C<< <p>..</p> >> appropriately.

Event-based systems would check to see when a C<enter-pod-item> and C<exit-pod-item> event fires, and keep track of it that way. This means, though, that you have to add bookkeeping code to every L<Pod> node type that might want to suppress a C<< <p>..</p> >> layer. And then code inside the L<Pod::Block::Para> handler that does just that, maybe even twice because you have to check once on the way in, once on the way out in an event-based system.

I think it's simpler to centralize the code in the L<Pod::Block::Para> handler, and check whether that paragraph is the child of an L<Pod::Item> node. The check can be done at that point and not need to be "scattered."

So this module makes certain that each node (except for the root) has a valid C<.parent> link, that way inside the L<Pod::Block::Para> handler you can check C<<$.parent !~~ Node::Item or $.html ~= '<p>'>>.

The other motivation is a bit more subtle, and focuses on the L<Pod::Table> class. It has both a C<.header> and C<.contents> attribute, and I'd rather have the <.contents> attribute B<always> contain the text associated with the object. So, rather than a single L<Node::Table> mimic with a C<.header>, the L<Node::Table> contains an optional L<Node::Table::Header> object and an equally-optional (ya never know, someone may write a POD table with headers, mean to fill in the content later, and never does) L<Node::Table::Body> object.

As a final note, having 'next' and 'previous' references means that you can pass an arbitrary C<Node::> node around and you'll always be able to get to the next and previous index, not so with arrays. I mean, you could have each node have its index, and then follow the parent reference and then take index N+1 of its C<.content> array, but that's a bit of overkill.

On the other hand it's probably not going to be a common operation once the tree is written out, so I might just be overthinking that a tad.

=head1 Layout

This is a bit spread-out, but it does make walking the tree of objects dead-simple. In fact, here's how you do it:

  sub walk-tree( $root ) {
    my $first-child = $root.first-child;

    say "<$root>";
    say $root.contents if $root.^can('contents');
    while $first-child {
      walk-tree( $first-child );
      $first-child = $first-child.next-sibling;
    }
    say "</$root>";
  } 

POD nodes either are leaf nodes - meaning that they have no internal structure, like a L<Node::Text> node, or branch nodes, meaning they have internal structures, like a L<Node::Document> node containing one or more other nodes.

You can use the C<.is-leaf> and C<.is-branch> methods to test for that, or just check the C<.first-child> attribute directly.

=head2 Migod, it's full of references.

Each node has:

=item .parent

  Its immediate parent node, or Nil if no parent.

=item .previous-sibling

  The node that occurs "before" it depth-first, or Nil if it's the first.

=item .next-sibling

  The node that follows it, or Nil if it's the end.

=item .first-child

  The first content node, or Nil if it has no contents.

Simple tree-walking code is given above, in case you don't want to mess with the algorithm, and it even generates something like XML/HTML. The nodes correspond pretty much to how HTML would lay out, but you're welcome to interpret the nodes as you like.

=head1 METHODS

=item to-tree( $pod )

Given Perl 6 POD, return a different tree structure, along with some useful annotations.

=end pod

#
#                    parent
#                       ^
#                       |
# previous-sibling <- $node -> next-sibling
#                       |
#                       |
#                       V
#                    first-child
#
my role Node::Visualization {
	method indent( Int $layer ) { ' ' xx $layer }

	method display( $layer ) {
		my $ok-parent = 'XXX';
		if $.parent {
			my $current-child = $.parent.first-child;
			# XXX it could easily walk to some other layer if the
			# XXX first-child is pointing incorrectly.
			# XXX
			while $current-child {
				if $current-child === self {
					$ok-parent = 'ok';
					last;
				}
				$current-child = $current-child.next-sibling;
			}
		}
		else {
			$ok-parent = 'ok';
		}
		my $ok-next-sibling = 'ok';
		if $.next-sibling {
			if $.next-sibling.previous-sibling {
				$ok-next-sibling = 'XXX' if
					$.next-sibling.previous-sibling !=== self;
			}
			else {
				$ok-next-sibling = 'XXX';
			}
		}
		my $ok-previous-sibling = 'ok';
		if $.previous-sibling {
			if $.previous-sibling.next-sibling {
				$ok-previous-sibling = 'XXX' if
					$.previous-sibling.next-sibling !=== self;
			}
			else {
				$ok-previous-sibling = 'XXX';
			}
		}
		my $ok-first-child = 'ok';
		if $.first-child {
			if $.first-child.parent {
				$ok-first-child = 'XXX' if
					$.first-child.parent !=== self;
			}
			else {
				$ok-first-child = 'XXX';
			}
		}
		my @layer =
			self ~ ':',
			" :parent({$.parent // ''}) $ok-parent",
			" :previous-sibling({$.previous-sibling // ''}) $ok-previous-sibling",
			" :next-sibling({$.next-sibling // ''}) $ok-next-sibling",
			" :first-child({$.first-child // ''}) $ok-first-child",
		;
		return join( '', map { self.indent( $layer ) ~ $_ ~ "\n" }, @layer );
	}

	method visualize( $layer = 0 ) {
		my $text = self.display( $layer );
		my $child = $.first-child;
		while $child {
			$text ~= $child.visualize( $layer + 1 );
			$child = $child.next-sibling;
		}
		$text;
	}
}
class Node {
	also does Node::Visualization;

	has $.parent is rw;
	has $.first-child is rw;
	has $.next-sibling is rw;
	has $.previous-sibling is rw;

	has %.config is rw;

	method new-from-pod( $pod ) {
		return self.bless(
			:config( $pod.config )
		)
	}

	method replace-with( $node ) {
		$node.parent = $.parent;
		$node.previous-sibling = $.previous-sibling;
		$node.next-sibling = $.next-sibling;
		# Don't touch first-child.

		if $.parent and $.parent.first-child === self {
			$.parent.first-child = $node;
		}
		if $.previous-sibling {
			$.previous-sibling.next-sibling = $node;
		}
		if $.next-sibling {
			$.next-sibling.previous-sibling = $node;
		}
	}

	method last-sibling {
		my $last-sibling = self;
		while $last-sibling.next-sibling {
			$last-sibling = $last-sibling.next-sibling;
		}
		$last-sibling;
	}

	method add-below( $to-insert ) {
		return unless $to-insert;
		$to-insert.parent = self;
		$to-insert.next-sibling = Nil;
		if $.first-child {
			my $last-child = $.first-child.last-sibling;
			$to-insert.previous-sibling = $last-child;
			$last-child.next-sibling = $to-insert;
		}
		else {
			$.first-child = $to-insert;
		}
	}
}

class Node::FormattingCode is Node { has $.type }

class Node::Bold is Node::FormattingCode { has $.type = 'B' }

class Node::Code is Node { }

class Node::Config is Node {
	has $.type;
	has $.like;
}

class Node::Comment is Node { }

class Node::Document is Node { }

class Node::Entity is Node {
	has $.contents;
}

class Node::Italic is Node::FormattingCode { has $.type = 'I' }

class Node::Item is Node { }

class Node::Link is Node {
	has $.url;
}

class Node::List is Node { }

class Node::Paragraph is Node { }

class Node::Section is Node {
	has $.title;
}

# XXX What is this?...
class Node::Reference is Node {
	has $.title;
}

class Node::Heading is Node {
	has $.level;
}

class Node::Text is Node {
	has $.value;
}

class Node::Table is Node { }

class Node::Table::Header is Node { }

class Node::Table::Data is Node { }

class Node::Table::Body is Node { }

class Node::Table::Body::Row is Node { }

class Node::Underline is Node::FormattingCode { has $.type = 'U' }

my role Node-FormattingCode-Helpers {
	multi method to-node( Pod::FormattingCode $pod ) {
		self.to-node( $pod, $pod.type );
	}

	multi method to-node( Pod::FormattingCode $pod, 'B' ) {
		my $node = Node::Bold.new-from-pod( $pod );
		self.add-contents-below( $node, $pod );
		$node;
	}

	multi method to-node( Pod::FormattingCode $pod, 'C' ) {
		my $node = Node::Code.new-from-pod( $pod );
		self.add-contents-below( $node, $pod );
		$node;
	}

	# XXX This should get folded back into the text.
	multi method to-node( Pod::FormattingCode $pod, 'E' ) {
		my $node = Node::Entity.new(
			:config( $pod.config ),
			:contents( $pod.contents )
		);
		$node;
	}

	multi method to-node( Pod::FormattingCode $pod, 'I' ) {
		my $node = Node::Italic.new-from-pod( $pod );
		self.add-contents-below( $node, $pod );
		$node;
	}

	multi method to-node( Pod::FormattingCode $pod, 'L' ) {
		my $node = Node::Link.new(
			:config( $pod.config ),
			:url( $pod.meta )
		);
		self.add-contents-below( $node, $pod );
		$node;
	}

	multi method to-node( Pod::FormattingCode $pod, 'R' ) {
		my $node = Node::Reference.new-from-pod( $pod );
		self.add-contents-below( $node, $pod );
		$node;
	}

	multi method to-node( Pod::FormattingCode $pod, 'U' ) {
		my $node = Node::Underline.new-from-pod( $pod );
		self.add-contents-below( $node, $pod );
		$node;
	}

	multi method to-node( Pod::FormattingCode $pod, 'Z' ) {
		my $node = Node::Comment.new-from-pod( $pod );
		self.add-contents-below( $node, $pod );
		$node;
	}

	multi method to-node( Pod::FormattingCode $pod, Str $unknown ) {
		die "Unknown formatting code '$unknown' for $pod"
	}
}
my role Node-Helpers {
	method add-contents-below( $node, $pod ) {
		for @( $pod.contents ) -> $element {
			$node.add-below( self.to-node( $element ) );
		}
	}

	multi method to-node( $pod ) {
		die "Unknown Pod type " ~ $pod.perl;
	}

	multi method to-node( Pod::Block::Code $pod ) {
		my $node = Node::Code.new-from-pod( $pod );
		self.add-contents-below( $node, $pod );
		$node;
	}

	multi method to-node( Pod::Block::Comment $pod ) {
		my $node = Node::Comment.new-from-pod( $pod );
		self.add-contents-below( $node, $pod );
		$node;
	}

	multi method to-node( Pod::Block::Named $pod, 'pod' ) {
		my $node = Node::Document.new-from-pod( $pod );
		self.add-contents-below( $node, $pod );
		$node;
	}

	multi method to-node( Pod::Block::Named $pod, Str $section ) {
		my $node = Node::Section.new(
			:config( $pod.config ),
			:title( $pod.name )
		);
		self.add-contents-below( $node, $pod );
		$node;
	}

	multi method to-node( Pod::Block::Named $pod ) {
		self.to-node( $pod, $pod.name );
	}

	multi method to-node( Pod::Block::Para $pod ) {
		my $node = Node::Paragraph.new-from-pod( $pod );
		self.add-contents-below( $node, $pod );
		$node;
	}

	method new-Node-Table-Body-Row( $pod ) {
		my $node = Node::Table::Body::Row.new;
		for @( $pod ) -> $element {
			my $data = Node::Table::Data.new;
			$data.add-below( self.to-node( $element ) );
			$node.add-below( $data );
		}
		$node;
	}

	multi method to-node( Pod::Block::Table $pod ) {
		my $node = Node::Table.new-from-pod( $pod );
		if $pod.headers {
			my $header = Node::Table::Header.new;
			for @( $pod.headers ) -> $element {
				my $data = Node::Table::Data.new;
				$data.add-below( self.to-node( $element ) );
				$header.add-below( $data );
			}
			$node.add-below( $header );
		}

		if $pod.contents {
			my $body = Node::Table::Body.new;
			for @( $pod.contents ) -> $element {
				$body.add-below( 
					self.new-Node-Table-Body-Row( $element )
				);
			}
			$node.add-below( $body );
		}
		$node;
	}

	multi method to-node( Pod::Config $pod ) {
		Node::Config.new(
			:config( $pod.config ),
			:type( $pod.type ),
			:like( $pod.<like> )
		);
	}

	multi method to-node( Pod::Heading $pod ) {
		my $node = Node::Heading.new(
			:config( $pod.config ),
			:level( $pod.level )
		);
		self.add-contents-below( $node, $pod );
		$node;
	}

	multi method to-node( Pod::Item $pod ) {
		my $node = Node::Item.new(
			:config( $pod.config ),
			:level( $pod.level )
		);
		self.add-contents-below( $node, $pod );
		$node;
	}

	multi method to-node( Str $pod ) {
		my $node = Node::Text.new( :value( $pod ) );
		$node;
	}
}

class Pod::To::Tree {
	also does Node-Helpers;
	also does Node-FormattingCode-Helpers;

	method to-tree( $pod ) {
		my $tree = self.to-node( $pod );
		return $tree;
	}
}

# vim: ft=perl6
