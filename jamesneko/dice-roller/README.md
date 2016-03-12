# Dice::Roller

Roll RPG-style polyhedral dice.

# SYNOPSIS

```perl6
    use Dice::Roller;
    
    my $dice = Dice::Roller.new("2d6 + 1");
    $dice.roll;
    say $dice.total;    # 4. Chosen by fair dice roll.
    $dice.set-max;
    say $dice.total;    # 13
```

# DESCRIPTION

Dice::Roller is the second of my forays into learning Perl 6. The aim is simple - take a "dice string" representing a series of RPG-style dice to be rolled, plus any modifiers, parse it, and get Perl 6 to virtually roll the dice involved and report the total.

It is still under development, but in its present form supports varied dice expressions adding and subtracting fixed modifiers or additional dice, as well as the "keep highest *n*" notations.

# METHODS

## new

```perl6
    my $dice = Dice::Roller.new('3d6 + 6 + 1d4');
```

`.new` takes a single argument (a dice expression) and returns a Dice::Roller object representing that collection of dice.

The expression syntax used is the shorthand that is popular in RPG systems; rolls of a group of similar dice are expressed as \<quantity\>d\<faces\>, so 3d6 is a set of 3 six-sided dice, numbered 1..6. Additional groups of dice with different face counts can be added and subtracted from the total, as well as fixed integer values.

Preliminary support for some "selectors" is being added, and are appended to the dice identifier; rolling '4d6:kh3' stands for roll 4 d6, then keep the highest 3 dice. Selectors supported are:-

 * **:kh\<n\>** - keep the highest *n* dice from this group.
 * **:kl\<n\>** - keep the lowest *n* dice from this group.
 * **:dh\<n\>** - drop the highest *n* dice from this group.
 * **:dl\<n\>** - drop the lowest *n* dice from this group.

Selectors can be chained together, so rolling '4d6:dh1:dl1' will drop the highest and lowest value dice.

## roll

```perl6
    $dice.roll;
```

Sets all dice in the expression to new random face values. Returns the Dice::Roller object for convenience, so you can do:-

```perl6
    say $dice.roll.total;
```

## total

```perl6
    my $persuade-roll = Dice::Roller.new('1d20 -2').roll;
    my $persuade-check = $persuade-roll.total;
```

Evaluates the faces showing on rolled dice including any adjustments and returns an Int total for the roll.

# ERROR HANDLING

`Dice::Roller.new` throws an exception if the string failed to parse.

This behaviour might change in a future release.

# DEBUGGING

You can get the module to spew out a bit of debugging text by setting `$Dice::Roller::debug = True`. You can also inspect the Match object in a given roll: `say $roll.match.gist`;

# LATEST VERSION

The most current development version of this module can be found on BitBucket, https://bitbucket.org/jamesneko/dice-roller

It's only on GitHub because of Panda. Don't expect a timely response if you request that I give your git a pull, or whatever.

# COPYRIGHT AND LICENCE

Copyright 2016 James Clark <james@lazycat.com.au>

Dice::Roller is Free Software; it is available under the Aristic Licence 2.0. See the LICENSE file for details.
