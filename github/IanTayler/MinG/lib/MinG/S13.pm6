use strict;
use MinG;
use MinG::S13::Logic;

=begin pod
=head1 NAME

MinG::S13 -- Stabler's (2013) parser.
=end pod

#################################################
#   INTERNAL THINGS     #   MAY CHANGE RAPIDLY  #
#################################################
=begin pod
=head1 INTERNAL CLASSES AND FUNCTIONS
=end pod

#|{
    Class that represents one derivation.
    }
class MinG::S13::Derivation {
    has Str @.input;
    has Queue $.q;
    # $structure holds the current derivation tree of the derivation.
    has DerivTree $.structure;
    has DevNode @.tree_nodes;

    #|{
        Method that returns whether this derivation still needs more steps.
        }
    method still_going() of Bool {
        return (@.input.elems > 0) || ($.q.elems > 0);
    }

    #|{ See Stabler (2013)}
    method scan(QueueItem $pred, Int $child_place) of MinG::S13::Derivation {
        my $leave = $pred.node.children[$child_place];

        debug("Scanned {$leave.label}");
        my $start_place = 1;
        $start_place = 0 if $leave.label eq "";

        my @new_t_n = @.tree_nodes;
        push @new_t_n, DevNode.new(label => $leave.label, position => $pred.priority);

        return MinG::S13::Derivation.new(input => @.input[$start_place..*], q => $.q, tree_nodes => @new_t_n);
    }

    #|{ See Stabler (2013)}
    # We pass most of the state around because we have to calculate all of this
    # anyway to check whether or not we need to to run the rule.
    method merge1(QueueItem $pred, Node @leaves, Node $selected, Node $selector) of MinG::S13::Derivation {
        # The following is a bit of a mess. It closely follows the way the rule
        # was written in Stabler (2013), so if you're trying to understand this,
        # it may be a good idea to read that first.
        my $new_node = LexNode.new( label => $selector.label, children => @leaves);

        my $f_item = QueueItem.new(priority => $pred.priority.add_p(0),\
                                   movers => (),\
                                   node => $new_node);

        my $s_item = QueueItem.new(priority => $pred.priority.add_p(1),\
                                   movers => $pred.movers,\
                                   node => $selected);

        my $nq = $.q.deep_clone;
        $nq.push($f_item); $nq.push($s_item);
        my @new_t_n = @.tree_nodes;
        push @new_t_n, DevNode.new(label => '<', position => $pred.priority);

        return MinG::S13::Derivation.new(input => @.input, q => $nq, tree_nodes => @new_t_n);
    }

    #|{ See Stabler (2013)}
    method merge2(QueueItem $pred, Node @non_terms, Node $selected, Node $selector) of MinG::S13::Derivation {
        my $new_node = LexNode.new( label => $selector.label, children => @non_terms);

        my $f_item = QueueItem.new(priority => $pred.priority.add_p(1),\
                                   movers => $pred.movers,\
                                   node => $new_node);

        my $s_item = QueueItem.new(priority => $pred.priority.add_p(0),\
                                   movers => (),\
                                   node => $selected);

        my $nq = $.q.deep_clone;
        $nq.push($f_item); $nq.push($s_item);

        debug("THIS SHOULD BE FALSE: {($nq eqv $.q).perl}");

        my @new_t_n = @.tree_nodes;
        push @new_t_n, DevNode.new(label => '>', position => $pred.priority);

        return MinG::S13::Derivation.new(input => @.input, q => $nq, tree_nodes => @new_t_n);
    }

    #|{ See Stabler (2013)}
    method merge3(QueueItem $pred, Node @leaves, Node $mover_child, Node $selector, Mover $mover) of MinG::S13::Derivation {
        my $new_node = LexNode.new( label => $selector.label, children => @leaves);
        my $f_item = QueueItem.new( priority => $pred.priority.add_p(0),\
                                    movers => (),\
                                    node => $new_node);

        my $s_item = QueueItem.new( priority => $mover.priority,\
                                     movers => $pred.movers_minus_this($mover),\
                                     node => $mover_child);
        my $nq = $.q.deep_clone;
        $nq.push($f_item); $nq.push($s_item);

        my @new_t_n = @.tree_nodes;
        push @new_t_n, DevNode.new(label => '<', position => $pred.priority);
        push @new_t_n, DevNode.new(label => $mover.priority.to_str(), position => $pred.priority.add_p(1));

        return MinG::S13::Derivation.new(input => @.input, q => $nq, tree_nodes => @new_t_n);
    }

    #|{ See Stabler (2013)}
    method merge4(QueueItem $pred, Node @non_terms, Node $mover_child, Node $selector, Mover $mover) of MinG::S13::Derivation {
        my $new_node = LexNode.new( label => $selector.label, children => @non_terms);
        my $f_item = QueueItem.new( priority => $pred.priority.add_p(1),\
                                    movers => $pred.movers_minus_this($mover),\
                                    node => $new_node);

        my $s_item = QueueItem.new( priority => $mover.priority,\
                                     movers => (),\
                                     node => $mover_child);
        my $nq = $.q.deep_clone;
        $nq.push($f_item); $nq.push($s_item);

        my @new_t_n = @.tree_nodes;
        push @new_t_n, DevNode.new(label => '>', position => $pred.priority);
        push @new_t_n, DevNode.new(label => $mover.priority.to_str(), position => $pred.priority.add_p(0));

        return MinG::S13::Derivation.new(input => @.input, q => $nq, tree_nodes => @new_t_n);
    }

    #|{ See Stabler (2013)}
    method move1(QueueItem $pred, Node $licensor, Node $licensed) of MinG::S13::Derivation {
        my @new_movers = $pred.movers;
        push @new_movers, Mover.new(priority => $pred.priority.add_p(0),\
                                    node => $licensed);

        my $new_item = QueueItem.new( priority => $pred.priority.add_p(1),\
                                      movers => @new_movers,\
                                      node => $licensor);
        my $nq = $.q.deep_clone;
        $nq.push($new_item);

        my @new_t_n = @.tree_nodes;
        push @new_t_n, DevNode.new(label => '>', position => $pred.priority);

        return MinG::S13::Derivation.new(input => @.input, q => $nq, tree_nodes => @new_t_n);

    }

    #|{ See Stabler (2013)}
    method move2(QueueItem $pred, Node $licensor, Node $mover, Node $mover_child) of MinG::S13::Derivation {
        my @new_movers = $pred.movers_minus_this($mover);
        push @new_movers, Mover.new(priority => $mover.priority,\
                                    node => $mover_child);

        my $new_item = QueueItem.new( priority => $pred.priority,\
                                      movers => @new_movers,\
                                      node => $licensor);

        my $nq = $.q.deep_clone;
        $nq.push($new_item);

        my @new_t_n = @.tree_nodes;
        push @new_t_n, DevNode.new(label => '<', position => $pred.priority);

        return MinG::S13::Derivation.new(input => @.input, q => $nq, tree_nodes => @new_t_n);
    }

    #|{
        Method that gets the expansions to be had in the next step. Check the code's comments for more details.
        }
    # This method is getting massive. Really, half the work of the parser is
    # done here.
    method exps() of Array {
        my $this_prediction = $.q.pop();
        my @retv;
        return @retv unless $this_prediction;

        # Heuristic. We won't allow too many empty categories!
        # This is a very important part of the algorithm. It is necessary if we
        # are not going to implement the probability heuristic recommended by
        # Stabler (2013). This seems to work pretty well. I haven't encountered
        # any real restrictions imposed by this in examples I've tried out and
        # it improves performance tremendously.
        return @retv if $.q.elems > ((@.input.elems + $BASE_E_CATS ) * $MULTIP_E_CATS);

        # SCAN CONSIDERED. NEEDS MERGE1-4 and MOVE1-2.
        if $this_prediction.node.has_child(@.input[0]) -> $child_place {
            my $scanned = self.scan($this_prediction, $child_place);
            append @retv, $scanned if $scanned;
        } elsif $this_prediction.node.has_child("") -> $child_place {
            my $scanned = self.scan($this_prediction, $child_place);
            append @retv, $scanned if $scanned;
        }

        # Note: with MERGE1, MERGE2, etc. we mean the rules as defined by
        # Stabler. We distinguish that from our implementation of the rules
        # which we will call MinG::S13::Derivation.merge1, etc.

        # Here we consider MERGE1 to MERGE4
        # This line can be a bit daunting, but it's not that hard actually.
        # We grab this prediction's node and take the children of that node that
        # have the property of being a selector (i.e. FWAY::MERGE and FPol::PLUS).
        # If the list is empty, the condition evaluates to False. If it isn't,
        # it evaluates to True, and we get those children in the array called
        # @selector_ch.
        if $this_prediction.node.children_with_property($IS_SELECTOR) -> @selector_ch {
            # We iterate over every child that is a selector. Applying MERGE1
            # and/or MERGE2 if the conditions are met.
SEL_LOOP:   for @selector_ch -> $selector {
                # The following code checks that there is a node immediately below
                # ROOT that has the proper category.
                my $selected_label = MinG::Feature.new(way => MERGE,\
                                                   pol => MINUS,\
                                                   type => $selector.label.type);
                my Node $selected = child_of_root($selected_label);

                # Get all leaves and do MERGE1
                if ($selected && $selector.children_with_property($IS_NOT_FEAT)) -> @leaves {
                    my $merged = self.merge1($this_prediction, @leaves, $selected, $selector);
                    append @retv, $merged if $merged;
                }
                # Get all non-leaves and do MERGE2
                if ($selected && $selector.children_with_property($IS_FEAT_NODE)) -> @non_terms {
                    my $merged = self.merge2($this_prediction, @non_terms, $selected, $selector);
                    append @retv, $merged if $merged;
                }

                # If we have the appropriate movers, do MERGE3 and/or MERGE4.
                # The conditional line is convoluted. Pay special attention to
                # the anonymous functions defined at the start of this file.
                if ($this_prediction.movers_with_property(\
                        $IS_CORRECT_MOVER(\
                            $LABEL_IS($selected_label)))) -> @corr_movers {
                    # We know there's one and only one child with the same feature
                    # in its label so it's safe to take the first child with that
                    # property.
                    # Of course, this isn't getting us any "nice code" awards.
                    for @corr_movers -> $corr_mover {
                        my $corr_child = \
                            $corr_mover.children_with_property(\
                                $LABEL_IS($selected_label))[0];

                        # Checking for MERGE3.
                        if $selector.children_with_property($IS_NOT_FEAT) -> @leaves {
                            my $merged = self.merge3($this_prediction,\
                                                     @leaves,\
                                                     $corr_child,\
                                                     $selector,\
                                                     $corr_mover);
                            append @retv, $merged if $merged;
                        }

                        # Checking for MERGE4.
                        if $selector.children_with_property($IS_FEAT_NODE) -> @leaves {
                            my $merged = self.merge4($this_prediction,\
                                                     @leaves,\
                                                     $corr_child,\
                                                     $selector,\
                                                     $corr_mover);
                            append @retv, $merged if $merged;
                        }
                    }
                }
            }
        }

        # Now it's the turn to consider MOVE1 and MOVE2
        if $this_prediction.node.children_with_property($IS_LICENSOR) -> @licensor_ch {
            for @licensor_ch -> $licensor {
                my $licensed_label = MinG::Feature.new(way => MOVE,\
                                                   pol => MINUS,\
                                                   type => $licensor.label.type);
                my Node $licensed = child_of_root($licensed_label);

                # If licensed isn't Nil, then we should apply MOVE1.
                if $licensed {
                    my $moved = self.move1($this_prediction,\
                                           $licensor,\
                                           $licensed);
                    append @retv, $moved if $moved;
                }

                # MOVE2 gets applied if we can find the appropriate movers.
                if ($this_prediction.movers_with_property(\
                        $IS_CORRECT_MOVER(\
                            $LABEL_IS($licensed_label)))) -> @corr_movers {
                    # Run move2 for each correct mover.
                    for @corr_movers -> $corr_mover {
                        my $corr_child = \
                            $corr_mover.children_with_property(\
                                $LABEL_IS($licensed_label))[0];

                        my $moved = self.move2($this_prediction,\
                                               $licensor,\
                                               $corr_mover,\
                                               $corr_child);
                        append @retv, $moved if $moved;
                    }

                }
            }
        }

        # Return an array with all the derivations that were added by MERGE1-4 and MOVE1-2.
        return @retv;
    }

    #|{
        Method that beautifies a derivation. Mostly used for debugging purposes.
        }
    method to_str() of Str {
        my Str @pretv = ["INPUT:\n\t{@.input.gist}"];
        push @pretv, "QUEUE:";
        for $.q.items -> $qi {
            push @pretv, $qi.to_str if $qi;
        }
        push @pretv, "STRUCTURE:\n\t{DevNode.list_to_str(@.tree_nodes)}";
        return @pretv.join("\n");
    }
}

#####################################################
#   EXTERNAL THINGS     #   SHOULD STAY CONSTANT    #
#####################################################
=begin pod
=head1 EXPORTED CLASSES AND FUNCTIONS
=end pod

#|{
    Class that implements the parser per se. This is not where the magic happens, but it is where most of the external API is defined.
    }
class MinG::S13::Parser {
    has MinG::S13::Derivation @!devq;
    # Trees of successful derivations!
    has @.results;
    has Node $.start_cat;
    has MinG::Grammar $!full_grammar;

    # This is temporal. devq is not meant to be public.
    method devq() {
        return @!devq;
    }

    #|{
        Method that gets a nice string representation of the @!devq.
        }
    method devq_to_str() {
        my @pretv = "###############\nDERIVATION QUEUE:";
        my $i = 0;
        for @!devq -> $dev {
            push @pretv, "DERIVATION \#$i";
            $i++;
            push @pretv, $dev.to_str;
        }
        push @pretv, "END DEVQ\n###############";
        return @pretv.join("\n");
    }
    #|{
        Method that runs one iteration of the parsing loop, running one step of each derivation in parallel. Gets all possible derivations.
        }
    method parallel_run() of Bool {
        # Notice we're using Promises.
        debug("Run number: $run_number");
        debug("\tInitial \@!devq: ");
        debug(self.devq_to_str);

        my $finished = False;

        my @promises;
        for @!devq -> $dev {
            if not($dev.still_going()) {
                push @.results, DevNode.list_to_node($dev.tree_nodes);
                $finished = True;
            } else {
                push @promises, Promise.start({ $dev.exps() });
            }
        }
        my @newdevq;
        for @promises -> $prom {
            append @newdevq, $prom.result;
        }

        @!devq = @newdevq;
        $run_number++ if $DEBUG;

        return $finished;
    }

    #|{
        Method that runs one iteration of the parsing loop, running one step of one derivation only. No parallel computation.
        }
    method procedural_run() of DerivTree {
        debug("Run number: $run_number");
        debug("\tInitial \@!devq: ");
        { print "\t\t"; say @!devq; say "\n" } if $DEBUG;
        my $this_dev = @!devq.pop();
        my @new_exps = $this_dev.exps();
        append @!devq, @new_exps if @new_exps; # Do not append if it is Nil.

        debug("\tNew queue: ");
        { print "\t\t"; say @!devq; say "\n" } if $DEBUG;

        $run_number++ if $DEBUG;
        return $this_dev.structure;
    }

    #|{
        Method that runs the main parsing loop using parallel_run. Gets all possible derivations.
        }
    method parallel_parse() of Bool {
        # Clean debugging symbols:
        $run_number = 1 if $DEBUG;
        while @!devq.elems > 0 {
            # This only gets the first derivation
            # last if self.parallel_run();

            # While this gets all of them.
            self.parallel_run();
        }
        if @.results.elems == 0 {
            return False;
        } else {
            return True;
        }
    }

    #|{
        Method that runs the main parseing loop using procedural_run. Stops after it finds the first derivation.
        }
    method procedural_parse() of Bool {
        # Clean debugging symbols:
        $run_number = 1 if $DEBUG;
        my $poss_result;
        while @!devq.elems > 0 and @!devq[@!devq.end].still_going {
            $poss_result = self.procedural_run();
        }
        if @!devq.elems == 0 {
            return False;
        } else {
            @!results.push($poss_result);
            return True;
        }
    }

    #|{
        Method that initialises that parser to later parse several strings. Should be used instead of Parser.setup when a single grammar is going to be used several times.
        }
    method init(MinG::Grammar $g) {
        $!full_grammar = $g;
        $s13_global_lexical_tree = $g.litem_tree();
        my $start_ind = $s13_global_lexical_tree.has_child($g.start_cat);
        say "bad start symbol for the grammar!" without $start_ind;
        $!start_cat = $s13_global_lexical_tree.children[$start_ind];
    }

    #|{
        Method that re-initialises the parser using the full version of the grammar.
        }
    method re_init() {
        self.init($!full_grammar);
    }

    #|{
        Method that parses a single string based on the grammar that was initialised using Parser.init()
        }
    method parse_str(Str $inp, ParseWay $do = PARALLEL, Str $compile = "") of Bool {
        @!results = ();
        my @proper_input = $inp.lc.split(' ');
        my $que = Queue.new(items => (QueueItem.new(priority => Priority.new(pty => (0)),\
                                                    movers => (),\
                                                    node => $.start_cat,\
                                                    )));
        my $start_dev = MinG::S13::Derivation.new(input => @proper_input,\
                                       q => $que,\
                                       );
        push @!devq, $start_dev;

        say "Parsing...";
        debug("\tThis is the input:\n\t\t{@.devq[0].input}\n\tLength:\n\t\t{@.devq[0].input.elems}");
        if $do == PROCEDURAL {
            if self.procedural_parse() {
                say "\t{@.results[0].qtree}";
                return True;
            } else {
                say "\tThe string you passed is not in the language.";
                return False;
            }
        } else {
            if self.parallel_parse() {
                if $compile {
                    Node.multicompile_tex(@.results, $compile);
                } else {
                    for @.results -> $res {
                        say "\t{$res.qtree}";
                    }
                }
                return True;
            } else {
                say "\tThe string you passed is not in the language.";
                return False;
            }
        }
    }

    #|{
        Method that deletes all non-phonetically-empty words that don't appear in the input before parsing. When using large grammars, this can be much more efficient, but has a large constant time-cost, so it will make small grammars slower.
        }
    method large_parse(Str $inp, ParseWay $do = PARALLEL, Str $compile = "") of Bool {
        my @words = $inp.lc.split(' ');
        my @necessary_items;
        for $!full_grammar.lex -> $lex_item {
            # A bit ridiculous in length, but oh well.
            if (($lex_item.phon eq "") || ($lex_item.phon eq any(@words)) || ($lex_item.features[*-1] eqv $.start_cat)) {
                push @necessary_items, $lex_item;
            }
        }
        my $necessary_grammar = MinG::Grammar.new(lex => @necessary_items,\
                                                  start_cat => $!full_grammar.start_cat);
        # say "Input: $inp";
        # $necessary_grammar.litem_tree.qtree.say;

        $s13_global_lexical_tree = $necessary_grammar.litem_tree();
        my $start_ind = $s13_global_lexical_tree.has_child($necessary_grammar.start_cat);
        die "bad start symbol for the grammar!" without $start_ind;
        $!start_cat = $s13_global_lexical_tree.children[$start_ind];

        my Bool $retv = self.parse_str($inp, $do, $compile);
        self.re_init();
        return $retv;
    }


    #|{
        Method that sets up a parser with a certain grammar and a certain input (taken as a string for convenience, converted to lower case and an array as needed) and creates the first derivation.
        }
    method setup(MinG::Grammar $g, Str $inp) {
        # Clean previous results:
        @.results = ();

        my @proper_input = $inp.lc.split(' ');

        # We set up the $s13_global_lexical_tree global variable. This should probably be
        # the only place where we do this.
        $s13_global_lexical_tree = $g.litem_tree();
        my $start_ind = $s13_global_lexical_tree.has_child($g.start_cat);

        die "bad start symbol for the grammar!" without $start_ind;

        my $start_categ = $s13_global_lexical_tree.children[$start_ind];

        my $que = Queue.new(items => (QueueItem.new(priority => Priority.new(pty => (0)),\
                                                    movers => (),\
                                                    node => $start_categ,\
                                                    )));
        my $start_dev = MinG::S13::Derivation.new(input => @proper_input,\
                                       q => $que,\
                                       );
        push @!devq, $start_dev;
    }

    #|{
        Method to set the parser up, parse and spit the result. All in one go.
        }
    method parse_me(MinG::Grammar $g, Str $inp, ParseWay $do = PARALLEL) {
        say "Parsing $inp.";
        self.setup($g, $inp);
        debug("\tThis is the input:\n\t\t{@.devq[0].input}\n\tLength:\n\t\t{@.devq[0].input.elems}");
        if $do == PROCEDURAL {
            if self.procedural_parse() {
                say "\t{@.results[0].qtree}";
            } else {
                say "\tThe string you passed is not in the language.";
            }
        } else {
            if self.parallel_parse() {
                for @.results -> $res {
                    say "\t{$res.qtree}";
                }
            } else {
                say "\tThe string you passed is not in the language.";
            }
        }

    }
}

#|{
    This is a wrapper subroutine to save to avoid using the MinG::S13::Parser class directly.
    }
sub parse_and_spit(MinG::Grammar $g, Str $inp, ParseWay $waytoparse = PARALLEL) is export {
    MinG::S13::Parser.new().parse_me($g, $inp, $waytoparse);
}

###############################
#            TEST             #
###############################
sub MAIN() {
    my $feat1 = feature_from_str("=A");
    my $feat2 = feature_from_str("A");
    my $startc = feature_from_str("B");

    my $item1 = MinG::LItem.new( features => ($feat1, $startc), phon => "b", sem => "");
    my $itema = MinG::LItem.new( features => ($feat2), phon => "a", sem => "");

    my $g = MinG::Grammar.new(lex => ($itema, $item1), start_cat => $startc);
    my $lexor = $g.litem_tree;
    say "{$lexor.qtree}\n";

    my $parser = MinG::S13::Parser.new();

    my $c = feature_from_str("C"); my $selv = feature_from_str("=V"); my $v = feature_from_str("V"); my $d = feature_from_str("D"); my $seld = feature_from_str("=D");

    my $force = MinG::LItem.new( features => ($selv, $c), phon => "");
    my $juan = MinG::LItem.new( features => ($d), phon => "juan");
    my $come = MinG::LItem.new( features => ($seld, $seld, $v), phon => "come");
    my $hay = MinG::LItem.new( features => ($seld, $v), phon => "hay");
    my $escupe = MinG::LItem.new( features => ($seld, $seld, $v), phon => "escupe");
    my $pan = MinG::LItem.new( features => ($d), phon => "pan");
    my $manteca = MinG::LItem.new( features => ($d), phon => "manteca");
    my $y = MinG::LItem.new( features => ($selv, $selv, $v), phon => "y");

    my $mucho = MinG::LItem.new( features => ($seld, $d), phon => "mucho");

    my $sentence = MinG::LItem.new( features => ($v), phon => "imasentence");

    $g = MinG::Grammar.new(lex => ($come, $sentence, $juan, $hay, $mucho, $pan, $y), start_cat => $v);

    # my @frases = ["Juan come pan", "manteca escupe Juan", "come escupe Juan", "Juan", "come", "Pan Come Manteca", "juan come mucho pan"];

    my @frases = ["juan come juan y imasentence", "hay juan", "juan hay", "mucho mucho juan come mucho pan y juan come mucho pan", "imasentence y imasentence y imasentence"];

    $parser.init($g);

    for @frases -> $frase {
        #say "\n\tPROCEDURAL: ";
        #$parser.parse_me($g, $frase, PROCEDURAL);

        say "\n\tPARALLEL: ";
        $parser.large_parse($frase);
    }

}
