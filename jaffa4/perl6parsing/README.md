Perl6::Parsing
==============


It is a wrapper around nqp Perl6 parsing methods.<br>
Known problem: if it is compiled into pir. (Panda does that), use Perl6::Parsing fails. It seems to be a Rakudo bug.<br>
Workaround: delete Parsing.pir.

Usage:

```perl
use Perl6::Parsing;


my $p=  Perl6::Parsing.new(); # create a new object

$p.parse("my \$p=3;");  # let us parse this text <br> 
say $p.parser.dump; # dumps parse tree 

$p.printree(); #prints the parse tree using a different format

my @tokens = $p.tokenise(); # extract tokens , requires $p.parse...
Instead of tokens, it would be more accurate to say parsed texts. It may be useful for all kind of Perl 6 analysis.

@tokens is a array of [hash (keys are tokentypes or parsing events, values are charpos where the token may ends), startpos in text, endpos in text ].
There are overlapping tokens but no overlaps are returned. Look at the values of the hash to determine overlaps. <br>
E.g. values in the previous line is not equal to endpos in text.

say $p.text.substr(@tokens[0][1],@tokens[0][2]-@tokens[0][1]); # prints first token


Tokens are derived from parse tree. It means the token boundaries may not be where you expect them to be. <br> 
For example, two consecutive comments may be returned as one token. Token boundaries are derived from what the parser considered to be important: code mainly.

say @tokens.perl; # look at the structure

say $p.dumptokens(); # shows better view
```
