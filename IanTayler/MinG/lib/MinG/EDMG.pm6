use strict;
use MinG;
use MinG::S13;

unit module MinG::EDMG;

enum FSide <LEFT RIGHT>;

#####################################################
#   EXTERNAL THINGS     #   SHOULD STAY CONSTANT    #
#####################################################
=begin pod
=head1 EXPORTED CLASSES AND FUNCTIONS
=end pod

#|{
    Class that defines an EDMG feature.
    }
class Feature is MinG::Feature {
    has Bool $.is_adj;
    has Bool $.is_head_mov;
    has Bool $.is_covert_mov;
    has FSide $.side;
    has FSide $.head_mov_side;

    #|{
        Method that returns an EDMG Feature out of a string description.
        }
    method from_str(Str $s) of Feature {
        my regex feat_marker {<[\+ \- \> \< \= \@ \*]>};
        my regex type_desc {\w+};
        my regex marker_first {^<feat_marker><type_desc>$};
        my regex marker_last {^<type_desc><feat_marker>$};
        my regex no_marker {^<type_desc>$};
        unless $s ~~ /<marker_first>|<marker_last>|<no_marker>/ {
            note "\"$s\" is not an appropriate string description of a feature";
            return Nil;
        }
        my $last_t_d = $/<marker_last><type_desc>.Str if $/<marker_last><type_desc>;
        my $last_f_m = $/<marker_last><feat_marker>.Str if $/<marker_last><feat_marker>;
        my $first_t_d = $/<marker_first><type_desc>.Str if $/<marker_first><type_desc>;
        my $first_f_m = $/<marker_first><feat_marker>.Str if $/<marker_first><feat_marker>;
        my $nom_t_d = $/<no_marker><type_desc>.Str if $/<no_marker><type_desc>;
        if $/<marker_first> {
            given $first_f_m {
                when '+' { return Feature.new(way => MOVE, pol => PLUS, type => $first_t_d) };

                when '*' { return Feature.new(way => MOVE, pol => PLUS, type => $first_t_d,\
                                       is_covert_mov => True) };

                when '-' { return Feature.new(way => MOVE, pol => MINUS, type => $first_t_d) };

                when '>' { return Feature.new(way => MERGE, pol => PLUS, type => $first_t_d,\
                                       side => LEFT, is_head_mov => True,\
                                       head_mov_side => RIGHT) };

                when '<' { return Feature.new(way => MERGE, pol => PLUS, type => $first_t_d,\
                                       side => LEFT, is_head_mov => True,\
                                       head_mov_side => LEFT) };

                when '=' { return Feature.new(way => MERGE, pol => PLUS, type => $first_t_d,\
                                       side => LEFT) };
                when '@' { return Feature.new(way => MERGE, pol => PLUS, type => $first_t_d,\
                                       side => LEFT, is_adj => True) };
            }
        } elsif $/<marker_last> {
            given $last_f_m {
                when '+' { return Feature.new(way => MOVE, pol => PLUS, type => $last_t_d) };

                when '*' { return Feature.new(way => MOVE, pol => PLUS, type => $last_t_d,\
                                       is_covert_mov => True) };

                when '-' { return Feature.new(way => MOVE, pol => MINUS, type => $last_t_d) };

                when '>' { return Feature.new(way => MERGE, pol => PLUS, type => $last_t_d,\
                                       side => RIGHT, is_head_mov => True,\
                                       head_mov_side => RIGHT) };

                when '<' { return Feature.new(way => MERGE, pol => PLUS, type => $last_t_d,\
                                       side => RIGHT, is_head_mov => True,\
                                       head_mov_side => LEFT) };

                when '=' { return Feature.new(way => MERGE, pol => PLUS, type => $last_t_d,\
                                       side => RIGHT) };
                when '@' { return Feature.new(way => MERGE, pol => PLUS, type => $last_t_d,\
                                       side => RIGHT, is_adj => True) };
            }
        } elsif $/<no_marker> {
            return Feature.new(way => MERGE, pol => MINUS, type => $nom_t_d);
        }
        # We shouldn't get here, but just in case.
        note "Weird argument and behaviour in method MinG::EDMG::Feature.from_str with input $s";
        return Nil;
    }
}

#|{
    Class that defines an EDMG lexical item.
    }
class LItem is MinG::LItem { }; # As of now, I don't see any needed additions.

#|{
    Class that defines an EDMG grammar.
    }
class Grammar is MinG::Grammar { }; # No additions needed for now.
