#!/usr/bin/env perl6
# implementation of Tarjan's algorithm in perl6
# uses pseudo code from https://en.wikipedia.org/wiki/Tarjan's_strongly_connected_components_algorithm

# various possibilities for how to describe a graph.
# The init method can be over-ridden to change the map the user's structure into the array structure here.
# Here init method assumes that we have a hash of nodes pointing to an array of children.
# If a node is included in an array of children, but is not in the original hash, it is added to the hash with no children.
use v6.c;

class Algorithm::Tarjan::Node {
    has @.succ is rw = ();
    has $.name;
    has $.index is rw;
    has $.low-link is rw;
    has Bool $.on-stack is rw = False;
}

class Algorithm::Tarjan {
    has Algorithm::Tarjan::Node %!nodes;
    has $!main-index;
    has @!stack;
    has @.strongly-connected;
    has Bool $!run-once;

    method init( %h ) {
        %!nodes = Empty;
        $!main-index = 0;
        @!stack = Empty;
        @.strongly-connected = Empty;
        $!run-once = False;
        for %h.kv -> $nd, @children { # stringifies all inputs
            %!nodes{ $nd } = Algorithm::Tarjan::Node.new(
                                    :name( ~$nd ),
                                    :succ( @children.map( { ~$_ }  ) )
                                    );
        };
        # adds children not in node set
        for %!nodes.values -> $node {
            for $node.succ {
              %!nodes{~$_} = Algorithm::Tarjan::Node.new( :name(~$_) ) unless %!nodes{~$_}:exists
            }
        }
    };

    method strong-components {
        return if $!run-once;
        for %!nodes.values -> $node {
            $.strong-connect($node) without $node.index
        };
        $!run-once = True;
    }

    method strong-connect( Algorithm::Tarjan::Node $v ) {
        $v.index = $v.low-link = $!main-index++;
        @!stack.push: $v;
        $v.on-stack = True;
        for $v.succ -> $w {
            my $wn = %!nodes{$w};
            with $wn.index {
              $v.low-link = min( $v.low-link, $wn.index )
                if $wn.on-stack
            } else {
              $.strong-connect( $wn );
              $v.low-link = min( $v.low-link, $wn.low-link );
            }
        }
        my Algorithm::Tarjan::Node $w;
        my @scc = ();
        if $v.index == $v.low-link {
            repeat {
                $w = @!stack.pop;
                $w.on-stack = False;
                @scc.push: $w.name;
            } until $w.name eq $v.name;
            @!strongly-connected.push( @scc.sort.join(',') ) if @scc.elems > 1;
        }
    }

    method find-cycles {
        $.strong-components();
        @!strongly-connected.elems
    }
}
