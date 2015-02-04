# Modular arithmetics in Perl6

Inspired from P5´s Math::ModInt

    use Modular;

    my $x = 6 Mod 10;
    my $y = 7 Mod 10;
    say $x + $y;  # should display 3 「mod 10」

    # using a verbose object notation
    # the modulus must be passed as a named argument
    my $x = Modulo.new: 6, :modulus(10);
    my $x = Modulo.new: 7, :modulus(10);
    say $x * $y;  # should display 2 「mod 10」
    say $x div $y; # should display 8 「mod 10」


## Note about vocabulary

I found that creating a Modular arithmetic module is not technically difficult
(after all most of the operators are already defined in Perl), but it's not easy
to chose the most convenient kind of notations about it.   And there is also the
vocabulary issue.

When talking about modular arithmetics, there are at least three different words
that come to mind:  "modular", "modulo" and "modulus".  Here is what I chose.  The
name of the module (in the perl6 sense) is 'Modular', as in "Modular arithmetic".
I chose this because this module exports a bunch of stuff that are related to modular
arithmetic, and I wanted to keep the name short, so I kept only the adjective.

'Modular' defines a class called 'Modulo'.  The constructor takes two
integers as argument:  a residue and a modulus, both of them being public
instance variables.

In latin, modulus means 'measure' and modulo is the ablative form.  Basically
this means that the modulo is what you get from the measure.  Hopefully with
this etymological hindsight, the choice of names for the class makes sense.


## Purpose of this module

The purpose of this module is to provide a class implementing Real in order to
define modular integers.  Most modular operators are already defined in perl6,
such as '%', 'mod' and 'expmod'.  But as far as I know, there is no class to
use them with generic functions.

For instance, say you defined the factorial function as such:

    sub postfix:<!>($n) { [*] 1 .. $n }

You can use such a function to compute 100! (mod 101) efficiently only
if you have defined a modular version of '*' and '..'.  That is the purpose
of this module:  to use modular integers as if there were normal integers.
