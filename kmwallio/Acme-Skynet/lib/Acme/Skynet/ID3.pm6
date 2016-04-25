use v6;
=begin pod

=head1 NAME

Acme::Skynet::ID3

=head1 DESCRIPTION

Acme::Skynet::ID3 is a basic implementation for generating an ID3 tree.

=head2 Examples

    use v6;
    use Acme::Skynet::ID3;

    # We need to create a thingy so our classifier and
    # thingy can talk and read each other

    class FeatNum does Featurized {
      has $.value;
      method new($value){
        self.bless(:$value);
      }
      method getFeature($feature) {
        return ($.value % 2 == 0);
      }
      # In training, label known, when querying,
      # this isn't used and can be left blank
      method getLabel() {
        return (($.value %2 == 0)) ?? "even" !! "odd";
      }
    }

    my $Classifier = ID3Tree.new();
    my @features = "value";
    my @labels = "even", "odd";
    $Classifier.setFeatures(@features);
    $Classifier.setLabels(@labels);
    for [1..10] -> $num {
      $Classifier.addItem(FeatNum.new($num));
    }
    $Classifier.learn();

    say $Classifier.get(FeatNum.new(100); # => "even"
    say $Classifier.get(FeatNum.new(99)); # => "odd"

=end pod

############################################################
#          DON'T
#                LOOK
#             OR
#                  JUDGE
#           I'm really bad at programming... okay...
############################################################

module Acme::Skynet::ID3 {
  role Featurized is export {
    method getFeature($feature) {
      die("Overwrite this method in your class");
    }

    method getLabel() {
      die("Overwrite this method in your class");
    }
  }

  class ID3Tree is export {
    has @!trainingSet;
    has ID3Tree %!children;
    has @!values;
    has @!features;
    has @!labels;
    has $!feature;
    has $!label;
    has $!bestGuess;

    method addItem(Featurized $item) {
      @!trainingSet.push($item);
    }

    method dumpTree($d = 0) {
      return ($!label)
        ?? $!label
        !! "(" ~ %!children.map({$!feature ~ '~' ~ .key ~ ":" ~ .value.dumpTree($d+1)}).join(' ') ~  ")";
      # return ($!label)
      #   ?? $!label
      #   !! "\n" ~ ([0..$d].map({"\t"})).join('') ~ "(" ~ %!children.map({$!feature ~ '~' ~ .key ~ ":" ~ .value.dumpTree($d+1)}).join(' ') ~  ")";
    }

    method elems() {
      return @!features.elems();
    }

    method entropy() {
      my %probabilities;
      for @!trainingSet -> $trainer {
        %probabilities{$trainer.getLabel()}++;
      }

      %probabilities.values.map(-> $c {
        ($c / @!trainingSet.elems()) * ($c / @!trainingSet.elems()).log(2)
      }).reduce(*+*) * -1;
    }

    method get(Featurized $item) {
      if ($!label) {
        return $!label;
      }

      my $return = %!children{$item.getFeature($!feature)}:exists
              ?? %!children{$item.getFeature($!feature)}.get($item) !! $!bestGuess;

      return $return;
    }

    method informationGain() {
      my $entropy = self.entropy();
      my $maxGain = -9999;

      for @!features -> $feature {
        my %options;
        my @kidsFeatures;
        for @!features -> $feat {
          unless ($feat eq $feature) {
            @kidsFeatures.push($feat);
          }
        }

        for @!trainingSet -> $trainer {
          unless (%options{$trainer.getFeature($feature)}:exists) {
            %options{$trainer.getFeature($feature)} = ID3Tree.new();
            %options{$trainer.getFeature($feature)}.setFeatures(@kidsFeatures);
            %options{$trainer.getFeature($feature)}.setLabels(@!labels);
          }
          %options{$trainer.getFeature($feature)}.addItem($trainer);
        }

        my $possibleEntropy = %options.values.map(-> $possibleKid {
          $possibleKid.entropy() * ($possibleKid.elems() / self.elems())
        }).reduce(*+*);

        my $infoGain = $entropy - $possibleEntropy;
        if ($infoGain > $maxGain) {
          %!children = %options;
          $!feature = $feature;
          $maxGain = $infoGain;
        }
      }

      for %!children.values -> $kid {
        $kid.learn();
      }
    }

    method learn() {
      if (%!children.values.elems() != 0 || $!label) {
        return;
      }

      # All items are of the same label
      if (self.entropy() == 0) {
        $!label = @!trainingSet[0].getLabel();
        return;
      }

      # We can't look at anything else to help
      # us label...
      my %trainCount;
      my $maxCount = 0;
      for @!trainingSet -> $trainer {
        %trainCount{$trainer.getLabel()}++;
        if (%trainCount{$trainer.getLabel()} > $maxCount) {
          $!bestGuess = $trainer.getLabel();
        }
      }
      if (@!features.elems() == 0) {
        $!label = $!bestGuess;
        return;
      }

      self.informationGain();
    }

    method setFeatures(@features) {
      @!features = @features;
    }

    method setLabels(@labels) {
      @!labels = @labels;
    }
  }
}
