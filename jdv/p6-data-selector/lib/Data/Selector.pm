use v6;

=begin pod

=head1 NAME

Data::Selector - data selection dsl parser and applicator

=head1 VERSION

1.00

=head1 SYNOPSIS

=begin code

 my $data_tree = {
     foo => {
        bar => { baz1 => 1, baz22 => 2, baz32 => [ 'a', 'b', 'c', ], },
     },
     asdf => 'woohoo',
 };
 Data::Selector.apply_tree(
     selector_tree => Data::Selector.parse_string(
         named_selectors => { '$bla' => '[non-existent,asdf]', },
         selector_string => '$bla,foo.bar.baz*2.1..-1',
         # (same thing with all optional + chars added)
         # named_selectors => { '$bla' => '[+non-existent,+asdf]', },
         # selector_string => '$bla,+foo.+bar.+baz*2.+1..-1',
     ),
     data_tree => $data_tree,
 );

 # $data_tree is now:
 # {
 #    foo => { bar => { baz22 => 2, baz32 => [ 'b', 'c', ], }, },
 #    asdf => 'woohoo',
 # }

=end code

=head1 DESCRIPTION

This module enables data selection via a terse dsl.  The obvious use case is
data shaping though it could also be used to hint data requirements down the
stack.

A selector string is transformed into a selector tree by parse_string().  Then
the apply_tree() method performs key (array subscripts and hash keys) inclusion,
and/or exclusion on a data tree using the selector tree.  Note that arrays in
the data tree are trimmed of the slots that were removed.

Note that parse_string() will throw some exceptions (in predicate form) but
there are probably many non-sensical selector strings that it won't throw on.
The apply_tree() method, on the other hand, does not throw any exceptions
because in the general case this is preferable.  For example, some typical
"errors" might be missing (misspelled in the selector tree or non-existent in
the data tree) keys or indexing into an array with a string.  Both cases may
legitimately happen when elements of a set are not the same shape.  In the case
of an actual error the resulting data tree will likely reflect it.

=head1 SELECTOR STRINGS

Selector strings are a terse, robust way to express data selection.  They are
sensitive to order of definition, are embeddable via square brackets, can be
constructed of lists of selector strings, and are therefore composable.

A selector string consists of tokens separated by dot characters.  Each dot
character denotes another level in the data tree.  The selector strings may be a
single value or a list of values delimited by square brackets and separated by
commas.

A leading hyphen character indicates exclusion.

An optional leading plus character indicates inclusion.  It is only required for
inclusion of values that start with a hyphen, like a negative array subscript,
or a plus character.

Its important to note that positive array subscripts with a leading + character
are not supported.  For instance, the selector string of "++2" will not
interpreted as "include array subscript 2".  It could be used to include a hash
key of "+2" however.  The same applies to "-+2".  This inconsistency is the
result of a limitation in the implementation and may be changed in the future.

Note that inclusion, in addition to specifying what is to be included, implies a
lower precedence exclusion of all other keys.  In other words, if a particular
key is not specified for inclusion but there was an inclusion then it will be
excluded.  For example, lets say the data tree is a hash with keys foo, bar, and
baz.  A selector string of "foo" will include the foo key and exclude the bar
and baz keys.  But a selector string of "foo,bar" will include the foo and bar
keys and exclude the baz key.

Wildcarding is supported via the asterisk character.

Negative array subscripts are supported but remember that they must be preceded
by a plus character to indicate inclusion (which must be urlencoded as %2B for
urls).  For example, "-1" means "exclude key 1" where "+-1" means "include key
-1".

Array subscript ranges are supported via the double dot sequence.  These can be
tricky when used with negative array subscripts.  For example, "-1..-1" means
exclude 1 to -1.  But "+-2..-1" means include -2 to -1.

Named selectors allow for pre-defined selectors to be interpolated into a
selector_string.  They begin with a dollar character and otherwise can only
contain lower case alpha or underscore characters (a-z,_).

=head2 EXAMPLES

Lets say we have a date tree like so:

=begin code

 $data_tree = {
     count => 2,
     items => [
         {
             body => 'b1',
             links => [ 'l1', 'l2', 'l3', ],
             rel_1_url => 'foo',
             rel_1_id => 12,
             rel_2_url => 'bar',
             rel_2_id => 34,
         },
         {
             body => 'b2',
             links => [ 'l4', 'l5', ],
             rel_1_url => 'up',
             rel_1_id => 56,
             rel_2_url => 'down',
             rel_2_id => 78,
         },
     ],
     total => 42,
 }

=end code

=item total only

=begin code

 $selector_string = "total";

 $data_tree = {
     total => 42,
 }

=end code

=item only rel urls in items

=begin code

 $selector_string = "items.*.rel_*_url"

 $data_tree = {
     items => [
         {
             rel_1_url => 'foo',
             rel_2_url => 'bar',
         },
         {
             rel_1_url => 'up',
             rel_2_url => 'down',
         },
     ],
 }

=end code

=item count and last item with no body

=begin code

 $selector_string = "count,items.+-1.-body"

 $data_tree = {
     count => 2,
     items => [
         {
             links => [ 'l4', 'l5', ],
             rel_1_url => 'up',
             rel_1_id => 56,
             rel_2_url => 'down',
             rel_2_id => 78,
         },
     ],
 }

=end code

=item last 2 links

=begin code

 $selector_string = "items.*.links.+-2..-1"

 $data_tree = {
     items => [
         {
             links => [ 'l2', 'l3', ],
         },
         {
             links => [ 'l4', 'l5', ],
         },
     ],
 }

=end code

=end pod

grammar Data::Selector::SelectorString::Grammar {
    token TOP {
        ^ <selector_group> $
    }

    token selector_group {
        '[' ~ ']' [ <selector>+ % ',' ]
    }

    token selector {
        [ <selector_path_part> | <selector_group> | <named_selector> ]+ % '.'
    }

    token selector_path_part {
        <-[[\].\$,]>+ [ '..' <-[[\].\$,]>+ ]?
    }

    token named_selector {
        \$<[a..z_]>+
    }
}

class Data::Selector::SelectorString::Actions {
    has $.order is rw;
    has $.named_selectors is rw;

    method TOP( Match $/ --> Hash ) {
        make $/.<selector_group>.ast.hash;
    }

    method selector_group( Match $/ --> Hash ) {
        my %h;
        for @( $/.<selector> ) -> $v {
            for $v.ast.kv -> $k, $v {
                for $v.kv -> $k2, $v2 {
                    %h{$k}{$k2} = $v2;
                }
                my $first_char = $k.substr( 0, 1 );
                my $inverse_k =
                ( $first_char eq "-" ?? "+" !! "-" ) ~ $k.substr( 1 );
                %h{$inverse_k}:delete;
            }
        }
        make %h;
    }

    method selector( Match $/ --> Hash ) {
        my @h_current;
        @h_current[0] = my Hash %h_root;
        # TODO:  why need parens here?  used to work without.
        for $/.caps>>.kv -> ( $k, $v ) {
            if $k eq 'selector_path_part' {
                for $v.ast.kv -> $k is copy, $v {
                    unless $k.substr(0,1) eq '+' || $k.substr(0,1) eq '-' {
                        $k = "+$k"
                    }

                    for @h_current.keys -> $i {
                        @h_current[$i] = @h_current[$i]{$k} = Hash.new( %( $v ) );
                    }
                }
            }
            elsif $k eq 'selector_group' {
                my @h_cur_new;
                for $v.ast.kv -> $k, $v {
                    for @h_current.keys -> $i {
                        push( @h_cur_new, @h_current[$i]{$k} = Hash.new(%($v)) );
                    }
                }
                @h_current = @h_cur_new;
            }
            elsif $k eq 'named_selector' {
                my @h_cur_new;
                for $v.ast.kv -> $k, $v {
                    for @h_current.keys -> $i {
                        push( @h_cur_new, @h_current[$i]{$k} = Hash.new(%($v)) );
                    }
                }
                @h_current = @h_cur_new;
            }
        }
        make %h_root;
    }

    method selector_path_part( Match $/ --> Hash ) {
        make %( $/ => %( _order_ => ++$.order, ), );
    }

    method named_selector( Match $/ --> Hash ) {
        die "unknown named selector:  $/" unless $.named_selectors;
        my Str $selector_string = $.named_selectors{"$/"} ~ '';
        my $action_object = Data::Selector::SelectorString::Actions.new(
            order => $.order,
            named_selectors => $.named_selectors,
        );
        my Hash $ast;
        {
            my $/;
            $ast = Data::Selector::SelectorString::Grammar.parse(
                "[$selector_string]",
                :actions( $action_object ),
            ).ast;
        }
        $.order = $action_object.order;
        make $ast;
    }
}

class Data::Selector {

=begin pod

=head1 METHODS

=item parse_string

Creates a selector tree from a selector string.  A map of named selectors can
also be provided which will be interpolated into the selector string before it
is parsed.

Required Args:  selector_string

Optional Args:  named_selectors

=end pod

    method parse_string ( Str :$selector_string!, Hash :$named_selectors --> Hash ) {
        my $tree = Data::Selector::SelectorString::Grammar.parse(
            "[$selector_string]",
            actions => Data::Selector::SelectorString::Actions.new(
                named_selectors => $named_selectors
            )
        ).ast;

        sub reorder ( $tree ) {
            my $order;
            my @queue = ( $tree );
            while @queue.elems {
                my $t = @queue.shift;
                my @sorted_keys = $t.keys.grep(
                    { $_ ne '_order_' }
                ).sort(
                    { $t{$^a}<_order_> cmp $t{$^b}<_order_> }
                );
                for @sorted_keys -> $k {
                    $t{$k}<_order_> = ++$order;
                    @queue.push( $t{$k} );
                }
            }
            return $tree;
        }

        return reorder( $tree );
    }

=begin pod

=item apply_tree

Include or exclude parts of a data tree as specified by a selector tree.  Note
that arrays that have elements excluded, or removed, will be trimmed.

Required Args:  selector_tree, data_tree

=end pod

    method apply_tree ( Hash :$selector_tree!, Hash :$data_tree! is rw --> Nil ) {
        my @queue = ( [ $selector_tree, $data_tree, ], );
        my %selector_trees_keys;
        while (@queue) {
            my ( $selector_tree, $data_tree, ) = @( shift @queue );

            %selector_trees_keys{$selector_tree.WHICH} ||= [
                $selector_tree.keys.grep(
                    { $_ ne '_order_'; }
                ).sort(
                    { $selector_tree{$^a}<_order_>
                      <=> $selector_tree{$^b}<_order_>; }
                ).map(
                    {
                        my $selector_tree_key_base = $_.substr( 1, );
                        [
                            $_,
                            $selector_tree_key_base,
                            Any,
                            Any,
                            Any,
                        ];
                    }
                );
            ];

            my @data_tree_keys =
            $data_tree ~~ Hash
            ?? keys %( $data_tree )
            !! ( 0..^$data_tree );

            my @selector_tree_keys = @( %selector_trees_keys{$selector_tree.WHICH} );
            my $has_includes;
            for (@selector_tree_keys) {
                $has_includes = 1
                if !$has_includes && $_[0].starts-with( '+' );
                if $_[0].starts-with( '+-' ) || $_[0].starts-with( '--' ) {
                    if $_[0] ~~ /^('+'|'-')('-'\d+)$/ {
                        $_[4] = $_[0];
                        if $1 < 0 && $1 >= -@($data_tree) {
                            $_[0] = $0 ~ (  @($data_tree) + $1 );
                        }
                        else {
                            $0 ~ substr( $1, 1, );
                        }
                        $_[1] = substr( $_[0], 1, );
                    }
                }

                if $data_tree ~~ Array && $_[0].index( '..' ) {
                    $_[0] ~~ /^['+'|'-']('-'?\d+)\.\.('-'?\d+)$/;
                    my @array_range = +$0, +$1;
                    $_[3]= @array_range.map: {
                        $_ < 0 ??  @($data_tree) + $_ !! $_;
                    };
                }
            }

            my %matching_selector_keys_by_data_key;
            my $data_tree_keys_string = join( "\n", @data_tree_keys, ) ~ "\n";
            for @selector_tree_keys {
                #TODO: not sure why [] required here but probably RT#121024
                my $selector_tree_key_pattern
                  = '[' ~ join( '\n|', $_[3][0] .. $_[3][1], ) ~ '\n]' if $_[3].defined;

                unless $selector_tree_key_pattern.defined {
                    $selector_tree_key_pattern = ( $_[2] || $_[1] ) ~ '\n';
                    #TODO: timtoady says already an RT maybe
                    my $/;
                    $selector_tree_key_pattern ~~ s:g/(\W)/\\$0/;
                    $selector_tree_key_pattern = $selector_tree_key_pattern.trans(
                        [ '\\*', '\\\\n', '\\-0\\\\n' ] => [ '\N*?', '\n', '0\n' ]
                    );
                }
                my @matches =
                $data_tree_keys_string ~~ m:global/<$selector_tree_key_pattern>/;
                for @matches -> $data_tree_key {
                    push(
                        %matching_selector_keys_by_data_key{$data_tree_key.chop},
                        $_[4] // $_[0],
                    );
                }
            }

            my ( %arrays_to_be_trimmed, %deferred_excludes, %matched_includes, );
            for keys %matching_selector_keys_by_data_key -> $data_tree_key {
                my $matching_selector_keys =
                %matching_selector_keys_by_data_key{$data_tree_key};
                if ( $matching_selector_keys[*-1].starts-with( '-' ) ) {
                    if ( $data_tree ~~ Hash ) {
                        $data_tree{$data_tree_key}:delete;
                    }
                    else {
                        my $ok =
                        try { $data_tree[$data_tree_key] = '_to_be_trimmed_'; };
                        %arrays_to_be_trimmed{$data_tree.WHICH} = $data_tree if $ok;
                    }
                }
                else {
                    %matched_includes{$data_tree.WHICH}{$data_tree_key}++;
                    %deferred_excludes{$data_tree.WHICH}{$data_tree_key}:delete;

                    my $matched_includes_for_data_tree =
                    %matched_includes{$data_tree.WHICH};
                    my @data_keys_to_be_deferred = @data_tree_keys.grep: {
                        !$matched_includes_for_data_tree{$_};
                    };
                    %deferred_excludes{$data_tree.WHICH}{$_}
                    = $data_tree for @data_keys_to_be_deferred;

                    my $data_sub_tree =
                        $data_tree ~~ Hash
                    ?? $data_tree{$data_tree_key}
                    !! try { $data_tree[$data_tree_key] };

                    my $selector_sub_tree =
                    @($matching_selector_keys) == 1
                    ?? %( $selector_tree{ $matching_selector_keys[0] } )
                    !! %(
                        $matching_selector_keys.map(
                            { %( $selector_tree{$_} ); }
                        )
                    );

                    @queue.push( $[ $selector_sub_tree, $data_sub_tree, ] )
                    if $data_sub_tree ~~ Array|Hash &&
                    $selector_sub_tree.keys.grep: { $_ ne '_order_'; };
                }
            }

            if ( $has_includes && !%matched_includes ) {
                %deferred_excludes{$data_tree.WHICH}{$_} = $data_tree
                for @data_tree_keys;
            }

            for keys %deferred_excludes -> $data_tree_string {
                my @data_tree_keys = %deferred_excludes{$data_tree_string}.keys;
                if (@data_tree_keys) {
                    my $data_tree =
                    %deferred_excludes{$data_tree_string}{ @data_tree_keys[0] };
                    next unless $data_tree ~~ Hash|Array;

                    if ( $data_tree ~~ Hash ) {
                        $data_tree{@data_tree_keys}:delete;
                    }
                    else {
                        for @data_tree_keys {
                            %arrays_to_be_trimmed{$data_tree.WHICH} = $data_tree
                              if try $data_tree[$_] = '_to_be_trimmed_';
                        }
                    }
                }
            }

            for values %arrays_to_be_trimmed -> $array {
                @($array) =
                map { $_ eq '_to_be_trimmed_' ?? |() !! $_; }, @($array);
            }
        }

        return;
    }
}
