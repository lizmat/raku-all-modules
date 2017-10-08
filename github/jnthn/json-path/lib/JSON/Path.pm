use JSON::Tiny;

class JSON::Path {
    has $!path;

    our $Safe = True;

    my enum ResultType < ValueResult PathResult MapResult >;

    my grammar JSONPathGrammar {
        token TOP {
            ^
            <commandtree>
            [ $ || <giveup> ]
        }
        
        token commandtree {
            <command> <commandtree>?
        }
        
        proto token command    { * }
        token command:sym<$>   { <sym> }
        token command:sym<.>   { <sym> <ident> }
        token command:sym<[*]> { '[' ~ ']' '*' }
        token command:sym<..>  { <sym> <ident> }
        token command:sym<[n]> {
            | '[' ~ ']' $<n>=[\d+]
            | "['" ~ "']" $<n>=[\d+]
        }
        token command:sym<['']> {
            "['" ~ "']" $<key>=[<-[']>+]
        }
        token command:sym<[n1,n2]> {
            '[' ~ ']' [ [ $<ns>=[\d+] ]+ % ',' ]
        }
        token command:sym<[n1:n2]> {
            '[' ~ ']' [ $<n1>=['-'?\d+] ':' [$<n2>=['-'?\d+]]? ]
        }
        token command:sym<[?()]> {
            '[?(' ~ ')]' $<code>=[<-[)]>+]
        }
        
        method giveup() {
            die "Parse error near pos " ~ self.pos;
        }
    }
    
    multi method new($path) {
        self.bless(:$path);
    }

    submethod BUILD(Str() :$!path) { }

    multi method Str(JSON::Path:D:) {
        $!path
    }

    method !get($object is copy, ResultType $rt) {
        if $object ~~ Str { # assume it's a JSON representation
            $object = from-json($object);
        }

        my &collector = JSONPathGrammar.parse($!path,
            actions => class {
                method TOP($/) {
                    make $<commandtree>.ast;
                }
                
                method commandtree($/) {
                    make $<command>.ast.assuming(
                        $<commandtree>
                            ?? $<commandtree>.ast
                            !! -> \result, @path { 
                                given $rt {
                                    when ValueResult { take result.item }
                                    when PathResult  { take @path.join('') }
                                    when MapResult   { take result = &*JSONPATH_MAP(result) }
                                }
                            });
                }
                
                method command:sym<$>($/) {
                    make sub ($next, $current, @path) {
                        $next($object, ['$']);
                    }
                }
                
                method command:sym<.>($/) {
                    my $key = ~$<ident>;
                    make sub ($next, $current, @path) {
                        $next($current{$key}, [flat @path, "['$key']"]);
                    }
                }
                
                method command:sym<[*]>($/) {
                    make sub ($next, $current, @path) {
                        for @($current).kv -> $idx, $object {
                            $next($object, [flat @path, "[$idx]"]);
                        }
                    }
                }

                method command:sym<..>($/) {
                    my $key = ~$<ident>;

                    make sub ($next, $current, @path) {
                        multi descend(Associative $o) {
                            if $o{$key}:exists {
                                $next($o{$key}, [flat @path, "..$key"]);
                            }
                            for $o.keys -> $k {
                                descend($o{$k});
                            }
                        }

                        multi descend(Positional $o) {
                            for $o.list -> $elem {
                                descend($elem);
                            }
                        }

                        multi descend(Any $o) {
                            # just throw it away, not what we're looking for
                        }

                        descend($current);
                    }
                }

                method command:sym<[n]>($/) {
                    my $idx = +$<n>;
                    make sub ($next, $current, @path) {
                        $next($current[$idx], [flat @path, "['$idx']"]);
                    }
                }
                
                method command:sym<['']>($/) {
                    my $key = ~$<key>;
                    make sub ($next, $current, @path) {
                        $next($current{$key}, [flat @path, "['$key']"]);
                    }
                }

                method command:sym<[n1,n2]>($/) {
                    my @idxs = $<ns>>>.Int;
                    make sub ($next, $current, @path) {
                        for @idxs {
                            $next($current[$_], [flat @path, "[$_]"]);
                        }
                    }
                }
                
                method command:sym<[n1:n2]>($/) {
                    my ($from, $to) = (+$<n1>, $<n2> ?? +$<n2> !! Inf);
                    make sub ($next, $current, @path) {
                        my @idxs = 
                            (($from < 0 ?? +$current + $from !! $from) max 0)
                            ..
                            (($to < 0 ?? +$current + $to !! $to) min ($current.?end // 0));
                        for @idxs {
                            $next($current[$_], [flat @path, "[$_]"]);
                        }
                    }
                }

                method command:sym<[?()]>($/) {
                    die "Non-safe evaluation"
                        if $Safe;

                    use MONKEY-SEE-NO-EVAL;
                    my &condition = EVAL '-> $_ { my $/; ' ~ ~$<code> ~ ' }';
                    no MONKEY-SEE-NO-EVAL;
                    make sub ($next, $current, @path) {
                        for @($current).grep(&condition) {
                            $next($_, @path);
                        }
                    }
                }
            }).ast;
        gather &collector($object, []);
    }

    method paths($object) {
        self!get($object, PathResult);
    }

    method values($object) {
        self!get($object, ValueResult);
    }

    method value($object) is rw {
        self.values($object).[0]
    }

    method map($object, &*JSONPATH_MAP) {
        self!get($object, MapResult).eager
    }

    method set(Pair (:key($object), :value($substitute)), $limit = Inf) {
        my $sub'd = 0;
        self.map($object, -> $orig {
            if $sub'd < $limit {
                $sub'd++;
                $substitute
            }
            else {
                $orig
            }
        });
        $sub'd
    }
}

sub jpath($object, $expression) is export {
	JSON::Path.new($expression).values($object);
}

sub jpath1($object, $expression) is rw is export {
	JSON::Path.new($expression).value($object);
}

sub jpath_map(&coderef, $object, $expression) is export {
	JSON::Path.new($expression).map($object, &coderef);
}
