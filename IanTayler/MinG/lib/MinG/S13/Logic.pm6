use strict;
use MinG;
######################
# DEBUGGING   TOOLS  #
######################
constant $DEBUG is export = 0;
sub debug($s) is export {
   if $DEBUG {
       say $s;
   }
}
our $run_number is export = 1;

############################
# CONSTANTS OR NOT SO MUCH #
############################
class Mover { ... };
our $IS_SELECTOR = -> Node $x { $x.feat_node and $x.label.way == MERGE and $x.label.pol == PLUS };
our $IS_FEAT_NODE = -> Node $x { $x.feat_node };
our $IS_NOT_FEAT = -> Node $x { not ($x.feat_node) };
our $IS_LICENSOR = -> Node $x { $x.feat_node and $x.label.way == MOVE and $x.label.pol == PLUS };

our $IS_CORRECT_MOVER = -> Code $y { -> Mover $x { $x.children_with_property($y) } };
our $LABEL_IS = -> $y { -> Node $x { $x.label eqv $y } };

enum ParseWay < PROCEDURAL PARALLEL >;

constant $BASE_E_CATS = 2;
constant $MULTIP_E_CATS = 1;

#################################################################################
# Implemented the 'current' lexical tree as a global variable.
# This is the ugliest thing in the implementation. Should I at one point fix it?
# There's reasons for this global variable. Derivations need to have access to the
# lexical tree, but derivation objects are notoriously short-lived (they normally
# last a single step). So, having a lexical tree as an attribute of derivations means
# we'll copy it many times unnecessarily, given that the tree is the same for the whole
# parsing.
#
# Having this global variable is efficient and it's not very dangerous. While many
# things need to access it, only the parser ever changes it and it does it only
# once per parse. Taboos aside, I don't think this is so bad, just as long as this
# rule is followed:
#
########################################
# GLORIOUS RULE OF MAXIMUM IMPORTANCE: #
#**************************************************************
#* DO NOT UNDER ANY CIRCUMSTANCES CHANGE THE VALUE OF THIS    *
#*    VARIABLE FROM OUTSIDE THE MinG::S13::Parser CLASS.      *
#**************************************************************
our $s13_global_lexical_tree is export;
##########
#      ^ #
# THIS | #
##########
#|{
    Objects in this class describe positions in a Queue.
    }
class Priority {
    has Int @.pty;

    #|{
        A method that compares this object's priority with another Priority object's priority and returns true if this one's is smaller.
        }
    method bigger_than(Priority $other) of Bool {
        # Lexicographical order means longer priorities are less prioritish.
        # Or doesn't it? Testing.
        ##############################
        # else {
        # loop (my $i = 0; ($i < self.length) && ($i < $other.length); $i++) {
        #     if @.pty[$i] > $other.pty[$i] {
        #         return False;
        #     } elsif @.pty[$i] < $other.pty[$i] {
        #         return True;
        #     }
        # }
        # }
        # If we got here, they both have the same priority.
        # I think this shouldn't happen, but I don't see why it would be a problem.
        # So, we're just throwing True ##(Now False, just in case)## in this case,
        # and hope for the best.
        my $pretv = self.pty cmp $other.pty;
        return False if $pretv eqv More;
        return True;
    }

    #|{
        Method that appends a number at the end of the priority. It returns a new Priority instead of changing itself automatically. Less efficient, but more useful for our purposes.
        }
    method add_p(Int $n) of Priority {
        my @new_pty = @.pty; # Int-s are immutable, so this should be fine.
        @new_pty.push($n);
        return Priority.new(pty => @new_pty);
    }

    #|{
        Returns the length of the priority. In this implementation, priorities are sequences of numbers, and they are ordered lexicographically so that longer sequences have less priority than shorter ones.
        }
    method length() of Int {
        return @.pty.elems;
    }
}

#|{
    Function used to compare two priorities. Uses Priority.bigger_than method internally. There aren't many reasons to use it, but if you can find one, go ahead.
    }
sub bigger_pty (Priority $a, Priority $b) {
    return $a.bigger_than($b);
}

#|{
    Function that returns a child of the lexical tree's ROOT with the correct properties.
    }
sub child_of_root(FWay $way, FPol $pol, $type) of Node is export {
    my $ret_f = MinG::Feature.new(way => $way, pol => $pol, type => $type);
    my $ret_ind = $s13_global_lexical_tree.has_child($ret_f);
    return $s13_global_lexical_tree.children[$ret_ind] if $ret_ind;

    return Nil; # Otherwise.
}

#|{
    Class for our movers: they represent the nodes we selected when we ran into a [MOVE, PLUS] feature and encountered a [MOVE, MINUS] feature as one of ROOT's children.
    }
class Mover {
    has Priority $.priority;
    has Node $.node;

    #|{
        Method that returns an array with all the children of the node that have a certain property.
        }
    method children_with_property(Code $p) {
        return $.node.children_with_property($p);
    }

    method to_str() {
        return "P: {$.priority.pty.join()}. N: {$.node.qtree}";
    }
}

#|{
    Objets of this class are items in a Queue. The only Queue we need to implement is the one for category predictions, so this is to be interpreted as an item in THAT queue.
    }
class QueueItem {
    has Priority $.priority;
    has Mover @.movers;
    has Node $.node;

    #|{
        Method that gets the higher priority taking into consideration the queue's priority and all the movers' priorities.
        }
    method highest_priority() of Priority {
        my $best_priority = self.priority;
        for @.movers -> $mover {
            $best_priority = $mover.priority if $mover.priority.bigger_than($best_priority);
        }
        return $best_priority;
    }
    #|{
        Method that returns the list of movers without a certain indicated one.

        We take linear time here to avoid having to deal with empty movers in this array. If performance starts being an issue this may be a place to look. (Although, to be fair, the array of movers is usually very short due to the SMC, so linear time there isn't much of a problem.)
        }
    method movers_minus_this(Mover $one) of Array[Mover] {
        # Aha! You didn't expect me to keep using lambdas/pointy blocks like this!
        return self.movers_with_property(-> Mover $x { not($x eqv $one)});
    }

    #|{
        Method that returns an array with all the movers that have a certain property.
        }
    method movers_with_property(Code $p) of Array[Mover] {
        my Mover @retv;
        for @.movers -> $mover {
            push @retv, $mover if $p($mover);
        }
        return @retv;
    }

    #|{
        This method is a wrapper around Priority.bigger_than so that it can be called more easily from a Queue object.
        }
    method bigger_than(QueueItem $other) {
        return False unless self;
        return True unless $other;
        return self.highest_priority.bigger_than($other.highest_priority);
    }

    #|{
        Method that gets a QueueItem in string for to print while debugging.
        }
    method to_str() of Str {
        my @pretv = "\tQueueItem:";
        push @pretv, "\t\tPriority:\n\t\t{$.priority.pty.join()}";
        push @pretv, "\t\tMovers:";
        for @.movers -> $mover {
            push @pretv, "\n\t\t{$mover.to_str}";
        }
        push @pretv, "\t\tNode:\n\t\t{$.node.qtree}";
        return @pretv.join("\n");
    }

    #|{
        Method that "deep-clones" a QueueItem. Actually, only @.movers needs to be deep-cloned (and that means simply copying the array. It doesn't get deeper than that), as the rest of the attributes don't get modified normally.
        }
    method deep_clone() of QueueItem {
        my Mover @newmovers = @.movers; # I assume arrays don't copy references.
        return QueueItem.new(priority => self.priority, movers => @newmovers, node => $.node);
    }
}

#|{
    The Queue of category predictions.
    }
class Queue {
    has QueueItem @.items;
    has @!deletions;

    #|{
        With this method, we find out the index of the highest-priority item. Linear time.
        }
    method ind_max() of Int {
        if @.items.elems == 0 {
            # It may or may not be better to die here. I'm letting it be for now.
            # Actually, nope. Dying here.
            return Nil;
        }

        # The start may be empty without the whole thing being empty, so we need
        # to find the first non-empty place
        my Int $first_place = 0 but True;
        # This is supposed to be safe because we already checked that the array
        # isn't empty. We may be in for a surprise in a few months, though.
        loop (; not(@.items[$first_place]); $first_place++){};
        my $highest = @.items[$first_place];

        my $index = $first_place;
        loop (my $i = $first_place; $i < @.items.elems; $i++) {
            next unless @.items[$i];
            if @.items[$i].bigger_than($highest) {
                $highest = @.items[$i];
                $index = $i;
            }
        }
        return $index;
    }

    #|{
        Method that gets a reference to the highest-priority item. Linear time.
        }
    method max() of QueueItem {
        my Int $temp = self.ind_max;
        return @.items[$temp] if $temp;
        return Nil; # This is like dropping a derivational time-bomb.
                    # Preminger would be mad.
    }

    #|{
        Method that deletes the highest-priority item and returns it. Linear time.
        }
    method pop() of QueueItem {
        my Int $place_to_delete = self.ind_max;
        if $place_to_delete {
            # It's only a deletion if we're not in the last place!
            push @!deletions, $place_to_delete if ($place_to_delete < @.items.end);
            return @.items[$place_to_delete]:delete;
        }
        @.items = [];
        return Nil;
    }

    #|{
        Method that adds an element to the Queue.

        This runs in constant time. If there are previously deleted elements, it fills those positions instead of pushing, making sure our queue length doesn't get too far away from the real length.
        }
    method push(QueueItem $new) {
        if @!deletions.elems == 0 {
            push @.items, $new;
        } else {
            my Int $deleted_location = @!deletions.pop;
            @.items[$deleted_location] = $new;
        }
    }

    #|{
        Method that gets the amount of elements in the Queue.

        It's not reliable because we keep deleted items in the @.items array. We get the right result when there's 0 elements because Perl6 deletes pseudo-deleted elements from the end of the array (even if they were pseudo-deleted a long time ago). Note: I guess this could easily break with future implementations of Perl6.
        }
    method elems() of Int {
        return @.items.elems;
    }

    #|{
        Method that returns True if the Queue is empty.

        This is done for safety, as elems isn't very reliable. It runs in lineal time, though, so I'm not using it unless I really have to.
        }
    method empty() of Bool {
        return True if @.items.elems == 0;
        for @.items -> $item {
            return False if $item;
        }
        return True;
    }

    #|{
        Method that (partially) deep-clones a Queue. Some parts don't need to be deep-cloned, so we get references to that.
        }
    method deep_clone() of Queue {
        my QueueItem @newitems;
        for @.items -> $item {
            push @newitems, $item.deep_clone if $item;
        }
        return Queue.new(items => @newitems);
    }
}

#|{
    Class that represents derivation trees. As of now, they're just Nodes.
    }
class DerivTree is Node {
    # This is all tentative. We don't really generate a derivation tree but a
    # weird and useless derivation chain. Consider it a placeholder for future
    # true derivations.
    method add_to_end(Node $n) {
        # my $lastman = self;
        # while $lastman.children.elems > 0 {
        #     $lastman = $lastman.children[0];
        # }
        # $lastman.children.push($n);
    }
};
