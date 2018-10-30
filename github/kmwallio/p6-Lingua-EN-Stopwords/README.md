# Lingua::EN::Stopwords

Provides methods to see if word is contained in a list of English stop words. [![Build Status](https://travis-ci.org/kmwallio/p6-Lingua-EN-Stopwords.svg?branch=master)](https://travis-ci.org/kmwallio/p6-Lingua-EN-Stopwords)

## Installation

```
panda install Lingua::EN::Stopwords
```

## Usage

``` perl6
use Lingua::EN::Stopwords::Short;

# Now we have an array:
say %stop-words;

# We can also check for words
say 'is dog a stop word? ' ~ is-stop-word('dog');
```

Options are Short, Long, and SQL.

## Acknowledgements

 * [Ranks NL](http://www.ranks.nl/stopwords) - List of stop words
