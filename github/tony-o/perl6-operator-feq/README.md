#```feq``` Operator

Provides ```feq``` operator for clean fuzzy string comparisons.

Includes a precanned wrapper for Text::Levenshtein::Damerau (the wrapper uses just the Levenshtein algorithm by default)

#Usage

##Out of the Box™

```perl6
use Operator::feq;

if '1234567890' feq '1234567899' {
  'I\'m here!'.say;
}

if '12345' feq '123' {
  'I don\'t get here'.say;
}

#outputs:
#I'm here!
```

See the tests for an example of how to extend/create custom comparison routines.

#Configuration

##```$*FEQLIB```

Defaults: ```Text::Levenshtein::Damerau```

Set this dynamic variable to control which library 'feq' uses

##```$*FEQTHRESHOLD```

Defaults: ```0.10``` # 10%

Set this dynamic variable to control the threshold for the matching.  Setting this variable to 0 will always cause ```feq``` to return ```False```.  Conversely, a value of ```1``` will always return ```True```.



#Credit Cards

[@tony-o](https://www.gittip.com/tony-o/)

Nick Logan \<ugexe\>
