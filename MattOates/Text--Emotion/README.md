Text::Emotion
=============

Perl6 package for scoring the emotional content of a piece of text from its word use.

Sentiment Data
==============

Currently the AFINN data set from Twitter usage is used to give base word scores for sentiment.
http://fnielsen.posterous.com/afinn-a-new-word-list-for-sentiment-analysis

AFINN is a list of English words rated for valence with an integer between minus five (negative) and plus five (positive). The words have been manually labeled by Finn Årup Nielsen in 2009-2011. The file is tab-separated.

Example Use
===========

'emobot' included is an example IRC bot using Text::Emotion::Scorer and Net::IRC::Bot.

```perl
#!/usr/bin/env perl6
use v6;

#Create a Scorer object and all of the sentiment data is loaded for your use
use Text::Emotion::Scorer;
my $emotion = Text::Emotion::Scorer.new;

#Score a whole passage of positive sounding text
say $emotion.score("I really love Perl6. Hurrah!");

#Score a whole passage of negative sounding text
say $emotion.score("I hate Monday's they suck!");

#Just get the word scores the passage score is working with
say $emotion.score_word("failure");
```
