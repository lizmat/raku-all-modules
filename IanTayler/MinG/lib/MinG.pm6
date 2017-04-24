use strict;
=begin pod
=head1 NAME

MinG -- A small module for describing MGs in Perl6.
=end pod

#############
# CONSTANTS #
#############
constant $ESPA0 = %?RESOURCES{"espa0.mg"};
constant $ENG0 = %?RESOURCES{"eng0.mg"};

class MinG::Feature { ... }

#################################################
#   INTERNAL THINGS     #   MAY CHANGE RAPIDLY  #
#################################################
=begin pod
=head1 INTERNAL CLASSES AND FUNCTIONS
=end pod

#|{
    A basic class defining a Tree-node for internal use.
    }
class Node {
    has $.label;
    has Node @.children;

    #|{
        Method for adding a child at the end of the children array. Returns the index of the new child.
        }
    method add_child(Node $child) of Int {
        push @!children, $child;
        return @!children.end;
    }

    #|{
        Method for checking whether there is a children of this Node that is a certain feature. Returns the index where the child is, if there is one, or Nil if there isn't.
        }
    method has_child ($poss_child) of Int {
        # 0 but True means we want this instance of the number 0 to be treated
        # as a true value, even though Perl6 normally treats them as false
        # values.
        loop (my $i = 0 but True; $i < @!children.elems; $i++) {
            if @!children[$i].label eqv $poss_child {
                return $i;
            }
        }
        return Nil;
    }

    #|{
        Method that returns the string representation of a Node label.
        }
    method str_label() of Str {
        return $!label ~ " ";
    }

    #|{
        Method that returns a LaTeX/qtree representation of the Node.
        }
    method qtree() of Str {
        # As of now, this is recursive, and not even tail-recursive.
        # So this might get ugly fast, performance wise.
        my $retv;
        if @!children > 0 {
            $retv = "[\.{self.str_label} ";
            for @!children -> $this {
                $retv ~= $this.qtree();
            }
            $retv ~= "] ";
        } else {
            if self.str_label !eq " " {
                $retv = self.str_label;
            } else {
                $retv = "[ ] "
            }
        }
        return $retv;
    }

    #|{
        Method that makes a LaTeX file named $name which includes this Node's tree using qtree.
        }
    method make_tex(Str $name) {
        my $tree = self.qtree;
        my $contents = slurp %?RESOURCES{"template.tex"};
        $contents.=subst("#<HERE-TREE>", $tree);
        spurt "\.\/$name", $contents;
    }

    #|{
        Method that makes a LaTeX file named $name which includes this Node's tree using qtree.
        }
    method multimake_tex(@nodes, Str $name) {
        my $contents = slurp %?RESOURCES{"template.tex"};

        my $repeated = $contents ~~ /'%COPYFROM'.+'%COPYTO'/;
        $repeated x= @nodes.elems; #length-1

        $contents.=subst(/'%COPYFROM'.+'%COPYTO'/, $repeated);
        for @nodes -> $node {
            my $tree = $node.qtree;
            $contents.=subst("#<HERE-TREE>", $tree, :x(1));
        }
        spurt "\.\/$name", $contents;
    }

    #|{
        Make a LaTeX file named $name which includes this Node's tree using qtree, and then compile it using pdflatex.
        }
    method compile_tex(Str $name) {
        self.make_tex($name);
        shell "pdflatex \.\/$name";
    }

    #|{
        Make a LaTeX file named $name which includes this series of nodes' trees using qtree, and then compile it using pdflatex.
        }
    method multicompile_tex(@nodes, Str $name) {
        self.multimake_tex(@nodes, $name);
        shell "pdflatex \.\/$name";
    }

    #|{
        This method checks whether this node is a feature-node. (We called them LexNodes which, to be fair, makes no sense.)
        }
    method feat_node() of Bool {
        return False;
    }

    #|{ Get this Node's feature-node-children.}
    method feat_children() of Array[Node] {
        my Node @retv = Nil;
        for @.children -> $this {
            if $this.feat_node {
                @retv.push($this);
            }
        }
        return @retv;
    }

    #|{ Get this Node's non-feature-node-children.}
    method non_feat_children() of Array[Node] {
        my Node @retv = Nil;
        for @.children -> $this {
            unless $this.feat_node {
                @retv.push($this);
            }
        }
        return @retv;
    }

    #|{ Get all the children of this Node that have property $p }
    method children_with_property (Code $p) of Array[Node] {
        my Node @retv;
        for @.children -> $this_little_thing {
            if $p($this_little_thing) {
                @retv.push($this_little_thing);
            }
        }
        return @retv;
    }
}

#|{
    Define eqv between Nodes as an equivalence in labels.
    }
multi infix:<eqv>(Node $l, Node $r) { $l.label eqv $r.label };

#|{
    A class defining the trees we'll use for representing the lexicon. In particular, LexNodes are going to be representing the nodes that hold features.
    }
class LexNode is Node {
    #has MinG::Feature $.label;

    #|{
        Override Node's str_label() method. We use MinG::Feature's to_str() method to get the representation.
        }
    method str_label() of Str {
        return $.label.to_str;
    }

    #|{
        Override Node's feat_node() because we ARE a feature node.
        }
    method feat_node() of Bool {
        return True;
    }
}

enum FWay <MERGE MOVE>;
enum FPol <PLUS MINUS>;

#|{
    Takes an FWay and an FPol and returns the proper prefix for a string description of a feature of that type.
    }
sub feature_prefix(FWay $way, FPol $pol) of Str {
    if $way == MERGE {
        return ""  if $pol == MINUS;
        return "=" if $pol == PLUS;
    } else {
        return "+" if $pol == PLUS;
        return "-" if $pol == MINUS;
    }
    die "Weird arguments for feature_prefix.";
}

#####################################################
#   EXTERNAL THINGS     #   SHOULD STAY CONSTANT    #
#####################################################
=begin pod
=head1 EXPORTED CLASSES AND FUNCTIONS
=end pod

#|{
    A class that defines an MG-style-feature.
    }
class MinG::Feature {
    # FWay $.way marks whether it is to be deleted through Merge or through Move.
    #
    # FPol $.pol marks the polarity of the feature (selector/licensor or
    # selectee/licensee).
    #
    # Str $.type is the category of the feature (traditionally D, N, V, P, etc).

    has FWay $.way;
    has FPol $.pol;
    has Str $.type;

    #|{
        Method that returns a string representation of the feature.
        }
    method to_str {
        return feature_prefix($!way, $!pol) ~ $!type;
    }

    #|{
        Method that returns a LexNode containing the feature as its label. $last indicates whether or not the node is to have any feature children.
        }
    method to_lexnode(Bool $last) of LexNode {
        return LexNode.new(children => (), last => $last, label => self);
    }
}

#|{
    Takes a string description of a feature (e.g. "=D") and returns a MinG::Feature.
    }
sub feature_from_str (Str $inp) of MinG::Feature is export {
    if $inp ~~ /^ <[= + \-]> \w+ / {
        my $fchar = ~$/.substr(0, 1);
        given $fchar {
            when '+' {
                return MinG::Feature.new(way =>  MOVE, pol => PLUS, type => ~$/.substr(1));
            }
            when '-' {
                return MinG::Feature.new(way =>  MOVE, pol => MINUS, type => ~$/.substr(1));
            }
            when '=' {
                return MinG::Feature.new(way =>  MERGE, pol => PLUS, type => ~$/.substr(1));
            }
        }
    } elsif $inp ~~ /^ \w+/ {
        return MinG::Feature.new(way =>  MERGE, pol => MINUS, type => ~$/);
    }
    die "$inp is not a valid description of a feature";
}

#|{
    A class that defines an MG-style Lexical Item as an array of features plus some phonetic and semantic content described currently as strings.
    }
class MinG::LItem {
    has MinG::Feature @.features;
    has Str $.sem;
    has Str $.phon;
}

#|{
    A class that defines a Grammar as an array of lexical items.
    }
class MinG::Grammar {
    has MinG::LItem @.lex;
    has MinG::Feature $.start_cat;

    #|{
        Method for getting a lexical tree like the one used in Stabler's (2013) parser.
        }
    method litem_tree() of Node {
        my $root = Node.new(label => "ROOT", children => ());

        # We iterate over the lexical items.
        for @!lex -> $this_lex {
            my @lex_feats = $this_lex.features;
            my $curr_node = $root;

            # For each lexical item, we add the "new" features to the tree,
            # starting from the last one.
            while @lex_feats > 0 {
                my $this_feat = @lex_feats.pop;
                if $curr_node.has_child($this_feat) -> $ind {
                    # If the feature is already there, then we update the
                    # current node and keep going.
                    $curr_node = $curr_node.children[$ind];
                } else {
                    # If the feature isn't there, we need to add it.
                    # We add $this_feat to the $curr_node, with value $last =
                    # True iff there are no more features to add later.
                    # NOTE: Remember we popped one element of @lex_feats at the
                    # beggining of this while loop.
                    my $ind = $curr_node.add_child($this_feat.to_lexnode(@lex_feats <= 0));
                    $curr_node = $curr_node.children[$ind];
                }
            }
            # Leaves are always word's phonetic content.
            my $new_node = Node.new(children => (), label => $this_lex.phon);
            $curr_node.add_child($new_node);
        }
        return $root;
    }
}
