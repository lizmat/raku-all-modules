use v6;

class Algorithm::Viterbi;

#our class Start {};
#our class End {};

# TODO:
our role Observation {};

my grammar Grammar {
    token TOP {
        <chunk>+
        [ $ || <.panic: "Syntax error"> ]
    }

    token chunk {
        <record>+ \n
    }

    token record {
        $<observation>=[\w+] \t $<tag>=[\w+] \n
    }
}

my class Actions {
    method TOP($/) {
        make $<chunk>>>.ast;
    }

    method chunk($/) {
        make $<record>>>.ast;
    }

    method record($/) {
        make ~$<observation> => ~$<tag>;
    }
}

has @!alphabet; # The HMM's alphabet
has %.p-transition;
has %.p-emission;

# TODO: It might be nice to be able to do the computations both using
# logarithms and the way it works now?
submethod BUILD(:@!alphabet!, :%!p-transition, :%!p-emission) { }

# TODO: Algorithm::Viterbi on CPAN also computes the Forward probability of
# the sequence. Should be doable to compute as well.
# TODO: An improvement might be to create a Role for observations so that
# domain objects can be passed directly to the decoder.
#method decode($hmm: Array of Observation @input) {
method decode($hmm: @input) {
    # We represent the trellis as a 2D list. The first dimension is the "tick"
    # along the input, the second the state space. @trellis contains the
    # accumulated probabilities, @trace the state we came from.
    my @trellis = [];
    my @trace = [];

    # Initialise the first row of the matrix.
    my $first = @input.shift; # Shift the first observation off the input.
    @trellis[0][0] = 0;
    for ^@!alphabet -> $state {
        my $tag = @!alphabet[$state];
        @trellis[0][$state] = %!p-transition{'Start'}{$tag}
                            * %!p-emission{$tag}{$first};
        @trace[0][$state] = 'Start';
    }

    # Iterate over the input, calculating probabilities as we go.
    for @input.kv -> $index, $observation {
        for ^@!alphabet -> $state {
            my ($max-p, $i) = (0, 0);
            my $tag = @!alphabet[$state];

            # Do the argmax to figure out which previous state is the optimal
            # fit for this current state.
            for ^@!alphabet -> $prev-state {
                my $prev-tag = @!alphabet[$prev-state];
                my $new-p = @trellis[$index][$prev-state]
                          * %!p-transition{$prev-tag}{$tag}
                          * %!p-emission{$tag}{$observation};

                if $new-p > $max-p {
                    $max-p = $new-p;
                    $i = $prev-state;
                }
            }

            # Update the trellis and the trace.
            @trellis[$index+1][$state] = $max-p;
            @trace[$index+1][$state] = $i;
        }
    }

    # Finalisation.
    my $index = @input.end + 1;
    my ($max-p, $i) = (0, 0);
    # Do the argmax to find the optimal previous state before the End state.
    for ^@!alphabet -> $prev-state {
        my $prev-tag = @!alphabet[$prev-state];
        my $new-p = @trellis[$index][$prev-state]
                  * %!p-transition{$prev-tag}{'End'};

        if $new-p > $max-p {
            $max-p = $new-p;
            $i = $prev-state;
        }
    }

    # Compute the resulting list of tags by unshifting tags onto @result from
    # the reversed trace.
    my $final-tag = $i;
    my @result;
    for @trace.reverse -> @arr {
        @result.unshift: @!alphabet[$final-tag];
        $final-tag = @arr[$final-tag];
    }

    return @result;
}

# Compute unsmoothed bigram probabilities from an input file.
multi method train($hmm: Str $file) {
    # XXX: It'd probably be more efficient to do the counting inline in the
    # actions and then have a private method that normalises the counts,
    # instead of keeping the whole corpus in memory and dispatching to the
    # other train().
    my $res = Grammar.parsefile($file, :actions(Actions.new));
    $hmm.train($res.ast);
}

#multi method train($hmm: Array of Pair @input) {
multi method train($hmm: @input) {
    # First, count the number of transitions between pairs of tags, and
    # emission counts for each tag-observation pair.
    for @input.lol -> @sequence {
        my $prev = 'Start';
        for @sequence -> $pair {
            my ($observation, $tag) = ($pair.key, $pair.value);

            # Increment transition count.
            %!p-transition{$prev} //= {};
            %!p-transition{$prev}{$tag}++;
            # Increment emission count.
            %!p-emission{$tag} //= {};
            %!p-emission{$tag}{$observation}++;

            $prev = $tag;
        }

        %!p-transition{$prev} //= {};
        %!p-transition{$prev}{'End'}++;
    }

    # XXX: Development testing code
    #say %!p-transition{'Start'}<H>; # Should be: 77
    #say %!p-transition<C><H>; # Should be: 26
    #say %!p-transition<C>{'End'}; # Should be: 44
    #say %!p-emission<C><3>; # Should be: 20

    # Compute the actual transition probabilities.
    for %!p-transition.kv -> $from, %to {
        my $sum = [+] %to.values;
        for %to.keys -> $k {
            %to{$k} /= $sum;
        }
    }

    # Compute the actual emission probabilities.
    for %!p-emission.kv -> $tag, %value {
        my $sum = [+] %value.values;
        for %value.keys -> $k {
            %value{$k} /= $sum;
        }
    }
}

=begin pod

=head1 NAME

Algorithm::Viterbi - Decoding HMMs

=head1 DESCRIPTION

This module is a fairly straightforward implementation of Viterbi's algorithm
for decoding hidden Markov models. The code is based on a Common Lisp
implementation I wrote as coursework, itself based on pseudo-code from
Jurafsky & Martin - Speech and language processing (2nd ed).

=head1 SYNOPSIS

=begin code

    use Algorithm::Viterbi;

    my Algorithm::Viterbi $hmm .= new(:alphabet<H C>);
    $hmm.train("training-data.tt"); # Train from file
    $hmm.train([ [a => 1, b => 2, a => 1],
                 [b => 3, c => 1, a => 2] ]); # Train from hardcoded data
    $hmm.decode(<a b c>);

=end code

=head1 FIELDS

=over 4

=item %.p-transition

The transition probabilities. A hash of hashes, indexed by tag name.

=item %.p-emission

The emission probabilities for a given tag. A hash of hashes, indexed first by
tag, then by observation.

=back

=head1 METHODS

=over 4

=item method new(:@alphabet!, :%p-transition, :%p-emission)

The alphabet parameter is required (an alphabet-less HMM doesn't make too much
sense). The transition and emission probabilities are also required for
correct operation of C<decode>, but can be specified either on construction,
with the C<train> method, or by manual specification via the corresponding
fields.

=item method decode(Str @input)

The C<decode> method decodes the input according to the probabilities
specified in the C<%.p-transition> and C<%.p-emission> fields.

=item method train(Str $file)

Computes unsmoothed bigram probabilities from an input file. The input format
is described by this grammar:

=begin code

    grammar G {
        token TOP { <chunk>+ }
        token chunk { <record>+ \n }
        token record { \w+ \t \w+ \n }
    }

=end code

The records are observation, then the associated tag.

=item method train(Array of Pair @data)

Computes unsmoothed bigram probabilities from an Array of Array of Pairs.
Each pair is a single observation-tag pair, and each element of the top-level
array is a sequence that is learnt.

=back

=head1 AUTHOR

Arne Skjærholt - L<mailto:arnsholt@gmail.com>.

=end pod
