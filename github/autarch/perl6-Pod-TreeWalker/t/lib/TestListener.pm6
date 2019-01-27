use Pod::TreeWalker::Listener;
class TestListener does Pod::TreeWalker::Listener {
    has @.events;

    multi method start (Pod::Block::Code $node) {
        @.events.push( { :start, :type('code') } );
        return True;
    }
    multi method end (Pod::Block::Code $node) {
        @.events.push( { :end, :type('code') } );
    }

    multi method start (Pod::Block::Comment $node) {
        @.events.push( { :start, :type('comment') } );
        return True;
    }
    multi method end (Pod::Block::Comment $node) {
        @.events.push( { :end, :type('comment') } );
    }

    multi method start (Pod::Block::Declarator $node) {
        @.events.push( { :start, :type('declarator'), :wherefore($node.WHEREFORE) } );
        return True;
    }
    multi method end (Pod::Block::Declarator $node) {
        @.events.push( { :end, :type('declarator'), :wherefore($node.WHEREFORE) } );
    }

    multi method start (Pod::Block::Named $node) {
        @.events.push( { :start, :type('named'), :name($node.name) } );
        return True;
    }
    multi method end (Pod::Block::Named $node) {
        @.events.push( { :end, :type('named'), :name($node.name) } );
    }

    multi method start (Pod::Block::Para $node) {
        @.events.push( { :start, :type('para') } );
        return True;
    }
    multi method end (Pod::Block::Para $node) {
        @.events.push( { :end, :type('para') } );
    }

    multi method start (Pod::Block::Table $node) {
        my @h = $node.headers.map({ .contents[0].contents[0] });
        @.events.push(
            {
                :start,
                :type('table'),
                :caption( $node.caption ),
                :headers(@h),
            }
        );
        return True;
    }
    method table-row (Array $row) {
        my @r = $row.map({ .contents[0].contents[0] });
        @.events.push( { :table-row(@r) } );
    }
    multi method end (Pod::Block::Table $node) {
        @.events.push( { :end, :type('table') } );
    }

    multi method start (Pod::FormattingCode $node) {
        @.events.push( { :start, :type('formatting-code'), :code-type($node.type), :meta($node.meta) } );
        return True;
    }
    multi method end (Pod::FormattingCode $node) {
        @.events.push( { :end, :type('formatting-code'), :code-type($node.type), :meta($node.meta) } );
    }

    multi method start (Pod::Heading $node) {
        @.events.push( { :start, :type('heading'), :level($node.level) } );
        return True;
    }
    multi method end (Pod::Heading $node) {
        @.events.push( { :end, :type('heading'), :level($node.level) } );
    }

    method start-list (Int :$level, Bool :$numbered) {
        @.events.push( { :start, :type('list'), :level($level), :numbered($numbered) } );
    }
    method end-list (Int :$level, Bool :$numbered) {
        @.events.push( { :end, :type('list'), :level($level), :numbered($numbered) } );
    }

    multi method start (Pod::Item $node) {
        @.events.push( { :start, :type('item'), :level($node.level) } );
        return True;
    }
    multi method end (Pod::Item $node) {
        @.events.push( { :end, :type('item'), :level($node.level) } );
    }

    multi method start (Pod::Raw $node) {
        @.events.push( { :start, :type('raw'), :target($node.target) } );
        return True;
    }
    multi method end (Pod::Raw $node) {
        @.events.push( { :end, :type('raw'), :target($node.target) } );
    }

    method config (Pod::Config $node) {
        @.events.push( { :config-type($node.type), :config($node.config) } );
    }

    method text (Str $text) {
        @.events.push( { :text($text) } );
    }
}
