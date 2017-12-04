# v0.1.2
* Use Pod::To::HTML for formatting tables

# v0.1.1
* Add support for properly escaping  backticks inside `C<code tags>`

# v0.1.0
* Add support for :no-fenced-codeblocks argument inside of sub and method signatures
* Add support for nested bullet points
* Use ```` ```lang```` for code blocks if lang is set in the config of the code block
```perl6
=begin code :lang<perl6
foo
=end code
```
Will result in:
````
```perl6
foo
```
````
* Various bugfixes related to rakudo changes
