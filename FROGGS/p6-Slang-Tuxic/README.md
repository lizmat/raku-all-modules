## Slang::Tuxic

This slang allows you to put whitespace between the name of a subroutine and the opening parenthesis.
Be aware that this introduces ambiguous situations, like when you want to pass a Parcel to a sub, or
when you need parens around the condition after the keywords `if`, `while` and so on...

```perl6
foo 3, 5;   # 15, as usual
foo(3, 5);  # also 15, as usual
foo (3, 5); # 15, /o\

# It also allows to put space before argument lists in method calls:
42.fmt('-%d-');  # -42-
42.fmt: '-%d-';  # -42-
42.fmt ('-%d-'); # -42-
```
