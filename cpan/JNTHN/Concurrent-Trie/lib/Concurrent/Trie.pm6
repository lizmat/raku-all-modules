class Concurrent::Trie {
    my class AlreadyInserted is Exception { }

    my class Node {
        has %.children;
        has Bool $.is-entry;
    
        my \EMPTY = Node.new;
        
        method EMPTY { EMPTY }

        method lookup-char(Str $char) {
            %!children{$char}
        }

        method clone-with-chars(@chars) {
            if @chars {
                my $first = @chars[0];
                my @rest = @chars.tail(*-1);
                if %!children{$first}:exists {
                    self.clone: children => {
                        %!children,
                        $first => %!children{$first}.clone-with-chars(@rest)
                    }
                }
                else {
                    self.clone: children => {
                        %!children,
                        $first => EMPTY.clone-with-chars(@rest)
                    }
                }
            }
            elsif $!is-entry {
                die AlreadyInserted.new;
            }
            else {
                self.clone: :is-entry
            }
        }
    }

    has Node $!root = Node.EMPTY;
    has atomicint $!elems;

    method insert(Str:D $value --> Nil) {
        if $value {
            my @chars = $value.comb;
            cas $!root, { .clone-with-chars(@chars) }
            $!elems⚛++;
            CATCH {
                when AlreadyInserted {
                    # Not a problem, exception is just to escape from the
                    # update attempt and not bump $!elems.
                }
            }
        }
    }

    method contains(Str:D $value --> Bool) {
        my $current = $!root;
        for $value.comb {
            $current .= lookup-char($_);
            return False without $current;
        }
        return $current.is-entry;
    }

    method entries(Str:D $prefix = '' --> Seq) {
        my $start = $!root;
        gather {
            my $current = $start;
            for $prefix.comb {
                $current .= lookup-char($_);
                last without $current;
            }
            entry-walk($prefix, $current) with $current;
        }
    }

    sub entry-walk(Str $prefix, Node $current) {
        take $prefix if $current.is-entry;
        for $current.children.kv -> $char, $child {
            entry-walk("$prefix$char", $child);
        }
    }

    multi method elems(Concurrent::Trie:D: --> Int) {
        $!elems
    }

    multi method Bool(Concurrent::Trie:D: --> Bool) {
        $!elems != 0
    }
}
