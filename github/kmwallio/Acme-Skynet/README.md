# Skynet for Perl6

Skynet is a collection of AI for your Perls6. [![Build Status](https://travis-ci.org/kmwallio/Acme-Skynet.svg?branch=master)](https://travis-ci.org/kmwallio/Acme-Skynet)

## Installation

Using [panda](https://github.com/tadzik/panda):

```
panda install Acme::Skynet
```

## Slightly Usable

* [Intent](#intent)
* [Chain Labelling](#chain-labelling)
* [DumbDown](#dumbing-down)
* [ID3Tree](#id3tree)

## Intent

Attempts to determine your intended action from a command phrase.  Look at [examples/stabbing_reminders.p6](examples/stabbing_reminders.p6) for more information.

The more knowledge you add, the hopefully better it will be able to parse.

Other than dumbing down, there's no additional text preprocessing yet.  Punctuation can throw things off...

There's an option for passing contexts.  I'll add some documentation later, but you can see us using it for testing in [t/intent.t](t/intent.t).

``` perl6
use v6;
use Acme::Skynet;

my $robotOverlord = Intent.new();

my $time = sub () {
    say now;
}

# Route commands to actions.
$robotOverlord.add($time, "what time is it");
$robotOverlord.add($time, "current time");

my $stab = sub (@args) {
    say "Stabbed @args[0]";
}

# Basic support for commands with arguments
$robotOverlord.add($stab, "stab john", "john");
$robotOverlord.add($stab, "stuart deserves to be stabbed", "stuart");

# Perform some training and learning
$robotOverlord.learn();

# Provide some input
$robotOverlord.hears("stab carlos"); # Expected output: "stabbed carlos"
$robotOverlord.hears("what is the time"); # Expected output: the time
```

## Chain Labelling

Does labeling have 1 l or 2?  Spell check okays both... this is how it all starts...

You need a classifier in front of this.  If you run a completely unrelated phrase through the labeler, your results will be completely unrelated.  That's unexpected.

``` perl6
use v6;
use Acme::Skynet::ChainLabel;

# Create a new labeler
my $reminders = ChainLabel.new();

# Tell it some facts
$reminders.add("remind me at 7 to strech", "7", "strech");
$reminders.add("at 6 pm remind me to shower", "6 pm", "shower");
$reminders.add("remind me to run at the robot apocalypse", "the robot apocalypse", "run");

# Let it learn those facts.
$reminders.learn();

my @ret = $reminders.get("at 6 pm remind me to let's shower");
say @ret[0]; # => "6 pm"
say @ret[1]; # => "let's shower"

@ret = $reminders.get("remind me to feed my cats at lunch time");
say @ret[0]; # => "lunch time"
say @ret[1]; # => "feed my cats"
```

## Dumbing Down

AIs think in simpler terms than us humans.  It's a process called "dumbing down".  We needs to make things easier for them to understand.

``` perl6
use v6;
use Acme::Skynet::DumbDown;

say dumbdown("cats"); # => "cat"

say dumber('he eats cats'); # => "he eat cat"

say extraDumbedDown("what's the current o'clock"); # => "what is the current of the clock"

say labeledExtraDumbedDown("we're so cool"); # => [[we're, so, cool] [we are, so, cool]]
```

## ID3Tree

This is a rapid basic (or overly complicated) implementation of an [ID3 Tree](https://en.wikipedia.org/wiki/ID3_algorithm).  It's how our robot overlords will identify what's going on around them and determine the action to take.

``` perl6
use v6;
use Acme::Skynet::ID3; # Should I rename this?

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
```

## What about the 3 laws of robotics?

Rules were made to be broken.

## TODO

* [ ] Write Skynet V1
* [ ] Add multiple layers of Machine Learning, supposed to make things better
* [ ] Ability to save state. It'd be bad if our supreme leaders forgot things
* [ ] Convince everyone I know what I'm doing
* [ ] Acquire government funding and live it up
* [ ] Add in 3 laws of robotics
* [ ] Have no regrets

### Acknowledgements

Uses:

* [Perl 6](http://perl6.org)
* [Lingua::EN::Stem::Porter](https://github.com/johnspurr/Lingua-EN-Stem-Porter)
* [ID3 Algorithm](https://en.wikipedia.org/wiki/ID3_algorithm)
