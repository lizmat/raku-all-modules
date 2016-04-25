use v6;
use Acme::Skynet::DumbDown;
use Acme::Skynet::ChainLabel;
use Acme::Skynet::ID3;

=begin pod

=head1 NAME

Acme::Skynet

=head1 DESCRIPTION

Acme::Skynet provides the Intent class.  This acts as a router of string
commands to function calls.

=head2 Caveats

Currently, all subroutines routed to must take a list as the argument,
even if the subroutine will not use it.

=head2 Examples

    use v6;
    use Acme::Skynet;
    my $robotOverlord = Intent.new();

    my $time = sub (@args) {
        my $time = DateTime.now();
        say sprintf "It is currently %d:%02d", $time.hour, $time.minute;
    }

    # Route commands to actions.
    $robotOverlord.addKnowledge("what time is it", $time);
    $robotOverlord.addKnowledge("current time", $time);
    $robotOverlord.addKnowledge("time please", $time);

    my $stab = sub (@args) {
        say "Stabbed @args[0]";
    }

    # Basic support for commands with arguments
    $robotOverlord.addKnowledge("stab john -> john", $stab);
    $robotOverlord.addKnowledge("stab mike -> mike", $stab);
    $robotOverlord.addKnowledge("stuart deserves to be stabbed -> stuart", $stab);
    $robotOverlord.addKnowledge("stuart should get stabbed -> stuart", $stab);

    my $reminders = sub (@args) {
      say "Will remind you to '" ~ @args[1] ~ "' at '" ~ @args[0] ~ "'";
    }

    $robotOverlord.addKnowledge("remind me at 7 to strech -> 7, strech", $reminders);
    $robotOverlord.addKnowledge("at 6 pm remind me to shower -> 6 pm, shower", $reminders);
    $robotOverlord.addKnowledge("remind me to run at the robot apocalypse -> the robot apocalypse, run", $reminders);

    # Perform some training and learning
    $robotOverlord.meditate();

    # Provide some input
    $robotOverlord.hears("stab miles"); # Expected output: "Stabbed carlos"
    $robotOverlord.hears("what is the time"); # Expected output: the time
    $robotOverlord.hears("please remind me to hide at the zombie apobalypse");
    $robotOverlord.hears("please remind me at the zombie apobalypse to hide");

=end pod

module Acme::Skynet {
  my $emptySub = sub {
  }

  class Thingy does Featurized {
    has &.action;
    has $.command;
    has @.args;
    has @!dumbPhrase;
    has Bool $!built = False;
    has %!features;

    method new(&action, Str $command, *@args) {
      self.bless(:&action, :$command, :@args);
    }

    method build() {
      if ($!built) {
        return;
      }
      $!built = True;
      @!dumbPhrase = extraDumbedDown($.command).split(/\s+/);
      for @!dumbPhrase -> $feature {
        %!features{$feature}++;
      }
    }

    method getFeature($feature) {
      self.build();
      return %!features{$feature}:exists;
    }

    method getFeatures() {
      self.build();
      return %!features.keys();
    }

    method getLabel() {
      return &.action.gist();
    }
  }

  class Intent is export {
    has ID3Tree $!classifier;
    has %!labels;
    has %!features;
    has %!router;
    has %!labelers{Any}; # One for each class
    has @!data;
    has Bool $!built = False;
    has Bool $!learned = False;

    method add(&route, Str $sentence, *@arguments) {
      my $train = Thingy.new(&route, $sentence, @arguments);
      @!data.push($train);

      # Create the ID3Tree
      unless ($!built) {
        $!built = True;
        $!classifier = ID3Tree.new();
      }
      $!classifier.addItem($train);

      # Create a label
      %!labels{&route.gist()}++;
      %!router{&route.gist()} = &route;

      # Add words to list of features
      $train.getFeatures().map(-> $feat {
        %!features{$feat}++;
      });

      # Create a labeller if needed
      unless (%!labelers{&route.gist()}:exists) {
        %!labelers{&route.gist()} = ChainLabel.new();
      }

      %!labelers{&route.gist()}.add($train.command, $train.args);
    }

    method addKnowledge(Str $str, &route) {
      my ($phrase, @action) = $str.split(/\s*('->'|',')\s*/);
      self.add(&route, $phrase, @action);
    }

    method get(Str $whisper, $context = Nil) {
      self.hears($whisper, $context);
    }

    method learn() {
      self.meditate();
    }

    method meditate() {
      if ($!learned) {
        return;
      }

      $!learned = True;
      $!classifier.setLabels(%!labels.keys());
      $!classifier.setFeatures(%!features.keys());

      # During benchmarking, some of the labelers
      # didn't finish when using await?
      #my @learners;
      #@learners.push(start {$!classifier.learn()});
      $!classifier.learn();

      for %!labelers.values -> $labeller {
        #@learners.push(start {$labeller.learn()});
        $labeller.learn();
      }

      #await @learners;
    }

    method hears(Str $whisper, $context = Nil) {
      my $command = Thingy.new($emptySub, $whisper);
      my $action = $!classifier.get($command);
      my @args = %!labelers{$action}.get($command.command);
      my &route = %!router{$action};
      
      if (&route.count == 0) {
        route();
      } elsif (&route.count == 1) {
        if (@args.elems() == 0  && $context) {
          route($context);
        } else {
          route(@args);
        }
      } else {
        route(@args, $context);
      }
    }
  }
}
