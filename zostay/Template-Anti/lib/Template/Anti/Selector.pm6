use v6;

use XML;

class Template::Anti::Selector::NodeSet {
    has @!nodes;
    has SetHash $!contains .= new({});

    method put($node) {
        unless $!contains{$node.WHICH} {
            @!nodes.push($node);
            $!contains{$node.WHICH} = True;
        }
    }

    method to-list { @!nodes }
}

class Template::Anti::Selector::NodeWalker {
    has $.origin;
    has @!open-list = $!origin;

    method next-node {
        while @!open-list {
            my $next-node = @!open-list.shift;

            next if $next-node ~~ XML::Text;
            next if $next-node ~~ XML::CDATA;
            next if $next-node ~~ XML::PI;
            next if $next-node ~~ XML::Comment;

            $next-node = $next-node.root
                if $next-node ~~ XML::Document;

            @!open-list.unshift: $next-node.nodes
                if $next-node ~~ XML::Element;

            return $next-node;
        }

        return;
    }
}

grammar Template::Anti::Selector::Grammar {
    rule TOP {
        <expression-list>
    }

    rule expression-list {
        <expression> +% ','
    }

    rule expression {
        <ancestor-child>
    }

    rule ancestor-child {
        <ancestors=.parent-child> +
    }

    rule parent-child {
        <family=.brother-sister> +% '>'
    }

    rule brother-sister {
        <siblings=.match-list> +% '+'
    }

    token match-list {
        <match>+
    }

    token match {
        || <tag-all>
        || <tag-name>
        || <class-name>
        || <id-name>
        || <contains-text>
        || <attr-has>
        || <attr-prefix>
        || <attr-contains>
        || <attr-word>
        || <attr-end>
        || <attr-equals>
        || <attr-nequals>
        || <attr-begin>
    }

    token tag-all       { '*' }
    token tag-name      { <name> }
    token class-name    { '.' <name> }
    token id-name       { '#' <name> }

    token contains-text  { ':' <.ws> 'contains' <.ws> '(' <.ws> <string> <.ws> ')' }
    token attr-has       { '[' <.ws> <name> <.ws> ']' }
    token attr-prefix    { '[' <.ws> <name> <.ws> '|=' <.ws> <string> <.ws> ']' }
    token attr-contains  { '[' <.ws> <name> <.ws> '*=' <.ws> <string> <.ws> ']' }
    token attr-word      { '[' <.ws> <name> <.ws> '~=' <.ws> <string> <.ws> ']' }
    token attr-end       { '[' <.ws> <name> <.ws> '$=' <.ws> <string> <.ws> ']' }
    token attr-equals    { '[' <.ws> <name> <.ws>  '=' <.ws> <string> <.ws> ']' }
    token attr-nequals   { '[' <.ws> <name> <.ws> '!=' <.ws> <string> <.ws> ']' }
    token attr-begin     { '[' <.ws> <name> <.ws> '^=' <.ws> <string> <.ws> ']' }

    token name {
        <-[ \# \: \[ \] \| \= \^ \$ \~ \( \) \< \> \' \" \* \! \. \s \, \+ ]> +
    }

    token string {
        || "'" $<string>=[ <-[ ' ]>+ ] "'"
        || '"' $<string>=[ <-[ " ]>+ ] '"'
    }
}

class Template::Anti::Selector::Actions {
    method TOP($/) {
        make -> $iter, $set {
            $/<expression-list>.made.($iter, $set);
        };
    }

    method expression-list($/) {
        make -> $iter, $set {
            while my $node = $iter.next-node {
                @($/<expression>).map: { .made.($node, $set) }
            }
        };
    }

    method expression($/) {
        make $/.values[0].made
    }

    method ancestor-child($/) {
        make -> $node, $set {
            my @ancestors = @($/<ancestors>)».made;

            my $this-match = @ancestors.pop;
            if $this-match($node) {

                my $current = $node;
                my $matches = True;
                ANCESTOR: for @ancestors.reverse -> $match {
                    last unless $matches;

                    my $current-match;
                    until $current-match = $match($current) {
                        unless $current {
                            $matches = False;
                            last ANCESTOR;
                        }

                        $current = $current.parent;
                    }

                    $matches &&= $current-match;
                }

                $set.put($node) if $matches;

                $matches
            }

            False
        }
    }

    method parent-child($/) {
        make -> $node {
            my @family = @($/<family>)».made;

            my $current = $node;
            my $matches = True;
            for @family.reverse -> $match {
                last unless $matches;

                unless $current {
                    $matches = False;
                    last;
                }

                $matches = False unless $match($current);

                $current = $current.parent;
            }

            $matches
        }
    }

    method brother-sister($/) {
        make -> $node {
            my @siblings = @($/<siblings>)».made;

            my $current = $node;
            my $matches = True;
            for @siblings.reverse -> $match {
                last unless $matches;

                unless $current {
                    $matches = False;
                    last;
                }

                $matches = False unless $match($current);

                repeat {
                    $current = $current.previousSibling;
                } while $current ~~ XML::Text;
            }

            $matches;
        }
    }

    method match-list($/) {
        make -> $node {
            [&&] |@($/<match>).map: { $_.made.($node) }
        }
    }

    method match($/) {
        make $/.values[0].made
    }

    method tag-all($/) {
        make -> $node { True }
    }

    method tag-name($/) {
        make -> $node { $node.name eq $/<name>.made }
    }

    method class-name($m) {
        $m.make( -> $node {
            my $class = $m<name>.made;

            my $node-class = $node.attribs<class>;

            $node-class.defined
                && $node-class ~~ / << $class >> /;
        })
    }

    method id-name($m) {
        $m.make( -> $node {
            my $id = $m<name>.made;

            my $id-attr = $node.idattr;
            my $node-id = $node.attribs{$id-attr};

            $node-id.defined
                && $node-id ~~ / ^ \s* $id \s* $ /;
        })
    }

    method contains-text($m) {
        $m.make( -> $node {
            my $text = $m<string>.made;

            my $walker = Template::Anti::Selector::NodeWalker.new(
                origin => $node,
            );

            my $contains-text = False;
            while (my $test-node = $walker.next-node) {
                my @text-nodes = $test-node.contents;

                my $match = [||] |@text-nodes.map: { .text ~~ / $text / };
                if $match {
                    $contains-text = True;
                    last;
                }
            }

            $contains-text
        })
    }

    method attr-has($/) {
        make -> $node {
            my $name = $/<name>.made;
            $node.attribs{$name}.defined
        }
    }

    method attr-prefix($m) {
        $m.make( -> $node {
            my $name  = $m<name>.made;
            my $match = $m<string>.made;

            my $attr-value = $node.attribs{$name};

            $attr-value.defined
                && $attr-value ~~ /^ $match $|^ $match '-'/
        })
    }

    method attr-contains($m) {
        $m.make( -> $node {
            my $name  = $m<name>.made;
            my $match = $m<string>.made;

            my $attr-value = $node.attribs{$name};

            $attr-value.defined
                && $attr-value ~~ / $match /;
        });
    }

    method attr-word($m) {
        $m.make( -> $node {
            my $name  = $m<name>.made;
            my $match = $m<string>.made;

            my $attr-value = $node.attribs{$name};

            $attr-value.defined
                && $attr-value ~~ / << $match >> /;
        });
    }

    method attr-end($m) {
        $m.make( -> $node {
            my $name  = $m<name>.made;
            my $match = $m<string>.made;

            my $attr-value = $node.attribs{$name};

            $attr-value.defined
                && $attr-value ~~ / $match $ /;
        });
    }

    method attr-equals($m) {
        $m.make( -> $node {
            my $name  = $m<name>.made;
            my $match = $m<string>.made;

            my $attr-value = $node.attribs{$name};

            $attr-value.defined 
                && $attr-value eq $match
        });
    }

    method attr-nequals($m) {
        $m.make( -> $node {
            my $name  = $m<name>.made;
            my $match = $m<string>.made;

            my $attr-value = $node.attribs{$name};

            !$attr-value.defined || $attr-value ne $match
        });
    }

    method attr-begin($m) {
        $m.make( -> $node {
            my $name  = $m<name>.made;
            my $match = $m<string>.made;

            my $attr-value = $node.attribs{$name};

            $attr-value.defined
                && $attr-value ~~ / ^ $match /;
        });
    }

    method name($/)   { make ~$/ }
    method string($/) { make ~$/<string> }
}

class Template::Anti::Selector {
    has XML::Node $.source;

    method postcircumfix:<( )>(Str $selector) {
        self.query($selector);
    }

    method query($selector) {
        my $match = Template::Anti::Selector::Grammar.parse(
            $selector,
            :actions(Template::Anti::Selector::Actions.new),
        );

        die "unable to parse '$selector'" unless $match;
        
        my $iter = Template::Anti::Selector::NodeWalker.new(
            origin => $!source,
        );

        my $set = Template::Anti::Selector::NodeSet.new;
        $match.made.($iter, $set);

        return $set.to-list;
    }
}

