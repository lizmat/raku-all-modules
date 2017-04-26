[![Build Status](https://travis-ci.org/scriptkitties/p6-Hash-Merge.svg?branch=master)](https://travis-ci.org/scriptkitties/p6-Hash-Merge)

### method merge

```perl6
method merge(
    %b,
    Bool:D :$no-append-array = Bool::False
) returns Mu
```

Merges a second hash into the hash the method is called on. Hash given as the argument is not modified. Traverses the full tree, replacing items in the original hash with the hash given in the argument. Does not replace positional elements by default, and instead appends the items from the supplied hash's array to the original hash's array. The object type of positionals is not retained and instead becomes an Array type. Use :no-append-array to replace arrays and positionals instead, which will also retain the original type and not convert to an Array
