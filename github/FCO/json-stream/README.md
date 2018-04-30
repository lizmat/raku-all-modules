[![Build Status](https://travis-ci.org/FCO/JSON-Stream.svg?branch=master)](https://travis-ci.org/FCO/JSON-Stream)

JSON::Stream
============

A JSON stream parser

```perl6
    react whenever json-stream "a-big-json-file.json".IO.Supply, [["\$", "employees", *],] -> (:$key, :$value) {
       say "[$key => $value.perl()]"
    }
```

Warning
-------

It doesn't validate the json. If the json isn't valid, it may have unusual behavior.

