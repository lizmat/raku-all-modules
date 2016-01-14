use nqp;
use QAST:from<NQP>;

=begin pod

=head1 Slang::Roman

C<Slang::Roman> lets you use Roman numerals in your code.

=head1 Synopsis

    use Slang::Roman;

    say 0rI + 0rIX; # 10
    my $i = 0rMMXVI; # $i = 2016

=head1 Documentation

This bit of admittedly twisted code let you use Roman numerals in your Perl 6 code. It patches the running grammar so you can use a Roman numeral anywhere you would use a regular integer.

Future enhancements will include expansions to printf/sprintf with a custom formatting type, and the equivalents of C<hex()> to handle string conversion.

While it handles both additive and subtractive Roman numerals, it doesn't check that they're properly formatted. For instance 'IC' should be a compile-time error but instead it'll generate 101 as if nothing of consequence happened.

=end pod

# This feels like something of a cheat, because I should be able to do it
# directly at the NQP level. But this method works for now.
#
# The short version: Slang::Roman::to-number takes the value it's given and
# returns a Roman numeral representing it.
#
# The Roman::Grammar and Roman::Actions are spliced into the running Perl 6
# grammar and augment the existing <number> type to include my <romanint>
# token.
#
# Roman::Grammar contains the token and related rule.
#
# Roman::Actions is where the fun starts, read that code for more explanation.
#
sub Slang::Roman::to-number(Str $value) is export
  {
  my %char-map =
    (
    I => 1, "\c[0x2160]" => 1,
            "\c[0x2161]" => 2,
            "\c[0x2162]" => 3,
            "\c[0x2163]" => 4,
    V => 5, "\c[0x2164]" => 5,
            "\c[0x2165]" => 6,
            "\c[0x2166]" => 7,
            "\c[0x2167]" => 8,
            "\c[0x2168]" => 9,
    X => 10, "\c[0x2169]" => 10,
             "\c[0x216a]" => 11,
             "\c[0x216b]" => 12,
    L => 50, "\c[0x216c]" => 50,
    C => 100, "\c[0x216d]" => 100,
    D => 500, "\c[0x216e]" => 500,
    M => 1_000, "\c[0x216f]" => 1_000,
                "\c[0x2180]" => 1_000, # C D
                "\c[0x2181]" => 5_000,
                "\c[0x2182]" => 10_000,
                # claudian antisigma
                #\c[0x2183] # ROMAN NUMERAL REVERSED ONE HUNDRED
                "\c[0x2187]" => 50_000,
                "\c[0x2188]" => 100_000,
    );
  my $num = $value;
  $num ~~ s/^0r//;

  # Just do it the simple way...
  #
  # IV => IIII ( 5 - 1 == 4 )
  # IX => VIIII ( 10 - 1 == 9 )
  # XL => XXXX ( 50 - 10 == 40 )
  # XC => LXXXX ( 100 - 10 == 90 )
  # CD => CCCC ( 500 - 100 == 400 )
  # CM => DCCCC ( 1000 - 100 == 900 )

  $num ~~ s:g/ <[ I \c[0x2160] ]> <[ V \c[0x2164] ]> /IIII/;
  $num ~~ s:g/ <[ I \c[0x2160] ]> <[ X \c[0x2169] ]> /VIIII/;

  $num ~~ s:g/ <[ X \c[0x2169] ]> <[ L \c[0x216c] ]> /XXXX/;
  $num ~~ s:g/ <[ X \c[0x2169] ]> <[ C \c[0x216d] ]> /LXXXX/;

  $num ~~ s:g/ <[ C \c[0x216d] ]> <[ D \c[0x216e] ]> /CCCC/;
  $num ~~ s:g/ <[ C \c[0x216d] ]> <[ M \c[0x216f] ]> /DCCCC/;

  my @chars = $num.split('');

  # Additive only for now...
  #
  my Int $final-value = 0;
  for @chars -> $x
    {
    next unless %char-map{$x}:exists;
    $final-value += %char-map{$x};
    }
  $final-value;
  }

sub EXPORT(|)
  {
  role Roman::Grammar
    {
    # Patch the <number> rule to add our own numeric type.
    #
    # This gets bound to a grammar action at runtime, so that we can capture
    # the string.
    #
    rule number:sym<roman>
      { <romanint> }

    # Describes a Roman number. Note that this includes the full Unicode range
    # of valid numbers - 1 .. 12 are there because some countries use formats
    # like '25-XII-2015' to represent Christmas, and they use the Unicode
    # roman numerals to fit in to forms.
    #
    token romanint
      { '0r' <[ I V X L C D M \c[0x2160] .. \c[0x2183] \c[0x2187] \c[0x2188] ]>+
      }
    }

  role Roman::Actions
    {
    sub lk(Mu \h, \k)
      { nqp::atkey(nqp::findmethod(h, 'hash')(h), k) }

    # This is called at compile-time, and replaces the '0rIIII' in the input
    # with a function call which converts the Roman numeral to its decimal
    # equivalent.
    #
    method number:sym<roman>(Mu $/)
      {
      my $number   := lk($/, 'romanint');
      my $block := QAST::Op.new(
                     :op<call>, 
                     :name<&Slang::Roman::to-number>, 
                     QAST::SVal.new(:value($number.Str))
                   );
      $/.'!make'($block);
      }
    }

  # Patch the running grammar with our Grammar and Actions roles.
  #
  nqp::bindkey(%*LANG,
               'MAIN',
               %*LANG<MAIN>.HOW.mixin(%*LANG<MAIN>,
               Roman::Grammar));
  nqp::bindkey(%*LANG,
               'MAIN-actions',
               %*LANG<MAIN-actions>.HOW.mixin(%*LANG<MAIN-actions>,
               Roman::Actions));
  {}
  }
