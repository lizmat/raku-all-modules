## Terminal::WCWidth

A Perl 6 port of [this module](https://github.com/jquast/wcwidth).

### Usage

`wcwidth` takes a single *codepoint* and outputs its width:

    wcwidth(0x3042) # "あ" - returns 2

Returns:

* `-1` for a control character
* `0` for a character that does not advance the cursor (NULL or combining)
* `1` for most characters
* `2` for full width characters

`wcswidth` takes a *string* and outputs its total width:

    wcswidth("*ウルヰ*") # returns 8 = 2 + 6

Returns -1 if any control characters are found.

Unlike the Python version, this module does not support getting the width of
only the first `n` characters of a string, as you can use the `substr` method.

### Acknowledgements

Thanks to Jeff Quast (jquast), the author of the
[Python module](https://github.com/jquast/wcwidth), which in turn is based on
the C library by Markus Kuhn.
