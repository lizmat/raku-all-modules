use v6;
use lib 'lib';
use Test;
use Acme::Skynet::ID3;

plan 28;
use-ok 'Acme::Skynet::ID3';

# Tree with 1 label
{
  my @labels = "A", "B", "C";
  my @features = "D", "E", "F";
  class SameSame does Featurized {
    method getFeature($feature) {
      return "H";
    }

    method getLabel() {
      return "B";
    }
  }

  my $ID = ID3Tree.new();
  $ID.setFeatures(@features);
  $ID.setLabels(@labels);
  for [0..10] -> $i {
    $ID.addItem(SameSame.new());
  }

  $ID.learn();

  ok $ID.get(SameSame.new()) eq "B", "All same label";
}

# 2 labels, 1 feature
{
  my @label = "even", "odd";
  my @feature = "mod2";

  class FeatNum does Featurized {
    has $.value;

    method new($value){
      self.bless(:$value);
    }

    method getFeature($feature) {
      return ($.value % 2 == 0);
    }

    method getLabel() {
      return (($.value %2 == 0)) ?? "even" !! "odd";
    }
  }

  my $EO = ID3Tree.new();
  $EO.setFeatures(@feature);
  $EO.setLabels(@label);
  for [1..10] -> $num {
    $EO.addItem(FeatNum.new($num));
  }
  $EO.learn();

  ok $EO.get(FeatNum.new(100)) eq "even", "100 is even";
  ok $EO.get(FeatNum.new(99)) eq "odd", "99 is odd";
}

# Multiple layer tree with 3 labels
{
  my @labels = "botheven", "bothodd", "what";
  my @features = "one", "two";

  class TwoNums does Featurized {
    has $.one;
    has $.two;

    method new($one, $two){
      self.bless(:$one, :$two);
    }

    method getFeature($feature) {
      return ($feature eq "one")
              ?? ($.one % 2 == 0)
              !! ($.two % 2 == 0);
    }

    method getLabel() {
      if ($.one % 2 == 0 && $.two % 2 == 0) {
        return "botheven";
      } elsif ($.one % 2 == 1 && $.two % 2 == 1) {
        return "bothodd";
      } else {
        return "what";
      }
    }
  }

  my $TW = ID3Tree.new();
  $TW.setFeatures(@features);
  $TW.setLabels(@labels);
  for [1..10] -> $o {
    for [1..10] -> $t {
      $TW.addItem(TwoNums.new($o, $t));
    }
  }
  $TW.learn();
  #die $TW.dumpTree();
  for [15..20] -> $o {
    for [11..14] -> $t {
      my $lb;
      if ($o % 2 == 0 && $t % 2 == 0) {
        $lb = "botheven";
      } elsif ($o % 2 == 1 && $t % 2 == 1) {
        $lb = "bothodd";
      } else {
        $lb = "what";
      }
      ok $TW.get(TwoNums.new($o, $t)) eq $lb, $o ~ " and " ~ $t ~ " are " ~ $lb;
    }
  }
}

done-testing;
