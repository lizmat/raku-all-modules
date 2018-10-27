use v6;
use Acme::Skynet::DumbDown;
=begin pod

=head1 NAME

Acme::Skynet::ChainLabel

=head1 DESCRIPTION

Acme::Skynet::ChainLabel attempts to find arguments from a given
phrase.

For example, if say "Remind me at 7 to strech", it could correspond
to a function call remindMe(7, "stretch").  Given a series of inputs,
we try to come up with a graph to handle various inputs.

ChainLabel is a very basic.  If you use certain cue words multiple
times, it can mess up the labeling.  ChainLabel will be used as a
preprocessor in the future.

=head2 Examples

    use Acme::Skynet::ChainLabel;

    my $reminders = ChainLabel.new;
    $reminders.add("remind me at 7 to strech -> 7, strech");
    $reminders.add("at 6 pm remind me to shower -> 6 pm, shower");
    $reminders.add("remind me to take out the chicken in 15 minutes -> 15 minutes, take out the chicken");
    $reminders.learn();

    my @args = $reminders.get("remind me in 10 minutes to e-mail jim"); # (10 minutes, e-mail jim)

=end pod

module Acme::Skynet::ChainLabel {
  class Node {
    has Str @.entry;
    has Bool $!visited;

    method collect(Str $word) {
      @.entry.push($word);
    }

    method reset() {
      @.entry = ();
      $!visited = False;
    }

    method gist() {
      @.entry.join(' ');
    }

    method isEmpty() {
      (@.entry.elems() == 0);
    }

    method visit() {
      $!visited = True;
    }

    method visited() {
      return $!visited;
    }
  }

  class ChainLabel is export {
    has @!commands;
    has $!args;
    has %!nodes;
    has %.paths;

    multi method add(Str $command) {
      # Remove arguments from phrase and replace with tokens
      my ($phrase, @action) = $command.split(/\s*('->'|',')\s*/);
      self.add($phrase, @action);
    }

    multi method add(Str $sentence, *@arguments) {
      my $phrase = $sentence;
      $!args = @arguments.elems();
      my $arg = 0;
      for @arguments -> $values {
        $phrase ~~ s:i/$values/ARG:$arg/;
        $arg++;
      }

      @!commands.push(extraDumbedDown($phrase));
    }

    method nextArg(Str $position) {
      my $next = False;

      for %!paths{$position}.values -> $possible {
        if ($possible ~~ m/^ARG/ && $next) {
          if (%!nodes{$next}.visited()) {
            $next = $possible;
          }
        } elsif ($possible ~~ m/^ARG/) {
          $next = $possible;
        }
      }

      return $next;
    }

    method pathExists(Str $position, Str $nextPosition) {
      for %!paths{$position}.values -> $possible {
        if ($possible eq $nextPosition) {
          return True;
        }
      }

      return False;
    }

    method learn() {
      # Generate a graph based on the phrases
      %!nodes{'.'} = Node.new();
      for @!commands -> $command {
        my $previousWord = '.';
        for $command.split(/\s+/) -> $word {
          %!nodes{$word} = Node.new();
          unless (self.pathExists($previousWord, $word)) {
            %!paths.push: ($previousWord => $word);
          }
          $previousWord = $word;
        }
      }
    }

    method get(Str $phrase) {
      # Reset node states
      for %!nodes.values -> $node {
        $node.reset();
      }

      # Traverse the graph
      my $position = '.';
      my @labeled = labeledExtraDumbedDown($phrase);
      my @original = @labeled[0].flat();
      my @command = @labeled[1].flat();
      my $originalPosition = 0;

      # $commandPosition can contain multiple elements since
      # we're tracking with the original.
      for @command -> $commandPosition {
        # We only want to push the original phrase into each node once.
        my %pushed;
        for $commandPosition.split(/\s+/) -> $nextPosition {
          my $gotoArg = self.nextArg($position);
          if (self.pathExists($position, $nextPosition)) {
            $position = $nextPosition;
          } elsif ($gotoArg) {
            $position = $gotoArg;
            %pushed{$gotoArg}++;
            %!nodes{$gotoArg}.collect(@original[$originalPosition]);
          } elsif(!(%pushed{$position}:exists)) {
            %pushed{$position}++;
            %!nodes{$position}.collect(@original[$originalPosition]);
            %!nodes{$position}.visit();
          }
        }
        $originalPosition++;
      }

      # Collect the args into our return list
      my @args;
      for [0..($!args - 1)] -> $arg {
        @args.push(%!nodes{"ARG:$arg"}.gist());
      }

      return @args;
    }
  }
}
