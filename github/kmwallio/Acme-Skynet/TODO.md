# TODO:

Problems and thoughts related to Skynet.

## Intent

* Should probably add an option for a default handler.
* Add $context for passing in a context...?  That way the called knows what's up

## Chain Labelling

* Right now, if the word "in" is a cue word, and "in" is in an argument, the argument will break.  We need to look at performing multiple iterations over a phrase and find a "best" fit.  Currently we replace possible common phrases like "in to" with "into"
  * We could increase our training set size.  During training keep a count of is it as an argument and location in the string.
  * Pass to a better labelling system as an initial guess.

## DumbDown

* Currently, certain root words aren't going to the same root.  For instance 'probable' and 'probably'.
  * Look at implementing Porter2 or another stemming algorithm.

## Free Will and Thought

* *Investigating*
* Parse Wikipedia and Urbandictionary?
