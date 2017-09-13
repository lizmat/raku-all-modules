# Subroutines Exported by the `:ALL` Tag

### Contents

| Col 1 | Col 2 | Col 3 |
| --- | --- | --- |
| [commify](#commify) | [count-substrs](#count-substrs) | [normalize-string](#normalize-string) |
| [split-line](#split-line) | [split-line-rw](#split-line-rw) | [strip-comment](#strip-comment) |
| [write-paragraph](#write-paragraph) | [write-paragraph2](#write-paragraph2) |  |
### sub commify
- Purpose: Add commas to a number to separate multiples of a thousand
- Params : An integer or number with a decimal fraction
- Returns: The input number with commas added, e.g., 1234.56 => 1,234.56
```perl6
sub commify($num)
   is export(:commify) {#...}
```
### sub count-substrs
- Purpose: Count instances of a substring in a string
- Params : String, Substring
- Returns: Number of substrings found
```perl6
sub count-substrs(Str:D $ip, Str:D $substr --> UInt)
   is export(:count-substrs) {#...}
```
### sub normalize-string
- Purpose: Trim a string and collapse multiple whitespace characters to single ones
- Params : The string to be normalized
- Returns: The normalized string
```perl6
sub normalize-string(Str:D $str is copy --> Str)
   is export(:normalize-string) {#...}
```
### sub split-line
- Purpose: Split a string into two pieces
- Params : String to be split, the split character, maximum length, a starting position for the search, search direction
- Returns: The two parts of the split string; the second part will be empty string if the input string is not too long
```perl6
sub split-line(Str:D $line is copy, Str:D $brk, UInt :$max-line-length = 0,
                UInt :$start-pos = 0, Bool :$rindex = False --> List)
   is export(:split-line) {#...}
```
### sub split-line-rw
- Purpose: Split a string into two pieces
- Params : String to be split, the split character, maximum length, a starting position for the search, search direction
- Returns: The part of the input string past the break character, or an empty string (the input string is modified in-place if it is too long)
```perl6
sub split-line-rw(Str:D $line is rw, Str:D $brk, UInt :$max-line-length = 0,
                   UInt :$start-pos = 0, Bool :$rindex = False --> Str)
   is export(:split-line-rw) {#...}
```
### sub strip-comment
- Purpose: Strip comments from an input text line
- Params : String of text, comment char ('#' is default)
- Returns: String of text with any comment stripped off. Note that the designated char will trigger the strip even though it is escaped or included in quotes.
```perl6
sub strip-comment(Str $line is copy, Str $comment-char = '#' --> Str)
   is export(:strip-comment) {#...}
```
### multi write-paragraph
- Purpose: Wrap a list of words into a paragraph with a maximum line width (default: 78) and update the input list with the results
- Params : List of words, max line length, paragraph indent, first line indent, pre-text
- Returns: List of formatted paragraph lines
```perl6
multi write-paragraph(@text, UInt :$max-line-length = 78,
                       UInt :$para-indent = 0, UInt :$first-line-indent = 0,
                       Str :$pre-text = '' --> List)
   is export(:write-paragraph) {#...}
```
### multi write-paragraph
- Purpose: Wrap a list of words into a paragraph with a maximum line width (default: 78) and print it to the input file handle
- Params : Output file handle, list of words, max line length, paragraph indent, first line indent, pre-text
- Returns: Nothing
```perl6
multi write-paragraph($fh, @text, UInt :$max-line-length = 78,
                       UInt :$para-indent = 0, UInt :$first-line-indent = 0,
                       Str :$pre-text = '')
   is export(:write-paragraph2) {#...}
```
