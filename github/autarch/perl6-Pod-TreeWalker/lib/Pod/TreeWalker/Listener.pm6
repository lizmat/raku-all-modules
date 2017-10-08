unit role Pod::TreeWalker::Listener;

# These multi methods cause the interpreter to complain about ambiguous calls,
# even though it seems like the role method should be shadowed by the class's
# method.

multi method start (Pod::Block:D $node) {
    return True;
}

multi method end (Pod::Block:D $node) {
    return True;
}

multi method start (Pod::Block::Code $node) {  }
multi method end (Pod::Block::Code $node) {  }
multi method start (Pod::Block::Comment $node) {  }
multi method end (Pod::Block::Comment $node) {  }
multi method start (Pod::Block::Declarator $node) {  }
multi method end (Pod::Block::Declarator $node) {  }
multi method start (Pod::Block::Named $node) {  }
multi method end (Pod::Block::Named $node) {  }
multi method start (Pod::Block::Para $node) {  }
multi method end (Pod::Block::Para $node) {  }
multi method start (Pod::Block::Table $node) {  }
multi method end (Pod::Block::Table $node) {  }
multi method start (Pod::FormattingCode $node) {  }
multi method end (Pod::FormattingCode $node) {  }
multi method start (Pod::Heading $node) {  }
multi method end (Pod::Heading $node) {  }
multi method start (Pod::Item $node) {  }
multi method end (Pod::Item $node) {  }
multi method start (Pod::Raw $node) {  }
multi method end (Pod::Raw $node) {  }

method start-list (Int :$level, Bool :$numbered) { }
method end-list (Int :$level, Bool :$numbered) { }
method table-row (Array $row) { }
method config (Pod::Config $node) {  }
method text (Str:D $text) {  }

=begin pod

=NAME Pod::TreeWalker::Listener

Role for classes which handle events produced by L<doc:Pod::TreeWalker>

=SYNOPSIS

    class MyListener does Pod::TreeWalker::Listener {
        multi method start (Pod::Heading $node) {
            say "Heading level {$node.level}";
        }

        multi method end (Pod::Heading $node) {
            say "Heading level {$node.level}";
        }

        method table-row (Array $row) { ... }
   }

=DESCRIPTION

This role defines the API which objects passed to L<doc:Pod::TreeWalker>'s
constructor are expected to implement.

=METHOD $listener.start(... $node)

The C<start> method is a multi method which is called for most Pod objects. It
is passed a L<doc:Pod::Block> object of some sort.

If this method returns C<False>, then the L<doc:Pod::TreeWalker> will not look
at the contents of the node, nor will it call the corresponding C<end> method
for the node.

=head3 Tables

The headers of a table (from C<$node.headers>) are passed as an array of
L<Pod::Blocks>.

=METHOD $listener.end(... $node)

The C<end> is a multi method that is called for most Pod objects.  It is
passed a L<doc:Pod::Block> object of some sort.

=METHOD $listener.start-list(Int :$level, Bool :numbered)

This method is called whenever a new list level is encountered. It can be
called multiple times in a row if a list item is introduced that skips levels,
for example:

    =item1 start-list is called once
    =item3 start-list is called twice

=METHOD $listener.end-list(Int :$level, Bool :numbered)

This method is called whenever a list level is done. List C<start-list>, it
can be called multiple times in a row.

=METHOD $listener.table-row(Array $row)

This method is called once for each row in a table. Each element of C<$row>
will in turn be a L<Pod::Block>.

=METHOD $listener.config(Pod::Config $node)

This method is called for Pod config declarations.

=METHOD $listener.text(Str $text)

This method is called for plain text, usually inside a paragraph block.

=AUTHOR Dave Rolsky <autarch@urth.org>

=COPYRIGHT

This software is copyright (c) 2015 by Dave Rolsky.

=LICENSE

This is free software; you can redistribute it and/or modify it under the
terms of The Artistic License 2.0.

=end pod
