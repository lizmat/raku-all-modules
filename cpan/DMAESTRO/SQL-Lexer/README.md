# SQL::Lexer #

** Under Construction - Pull requests welcome **

## Description ##

This grammer is a foundation for SQL Language parsers. It handles the common
lexical constructs of SQL.

## Primary Tokens ##

### Special Characters ###

* `singlequote`
* `doublequote`
* `quote` - either single or double
* `backquote`
* `period`
* `underscore`
* `plus-sign`
* `minus-sign`
* `left-paren`
* `right-paren`
* `colon`
* `semicolon`
* `comma`
* `solidus` - ordinary forward slash

### Comments ###

* `simple-comment` - '--' or '#' to end-of-line
* `bracketed-comment` - '/\*' to '\*/' multi-line comment
* `comment` - either of the above

### Literals ###

* `literal`
* `signed-numeric-literal`
* `unsigned-numeric-literal`
* `char-sting-literal`
* `datetime-literal`
* `interval-literal`
* `date-string`
* `time-string`
* `timestamp-string`
* `boolean-literal`

### Operators ###

* `operator-symbol`
* `equals-operator`
* `non-equals-operator`
* `less-than-operator`
* `greater-than-operator`
* `plus-operator`
* `minus-operator`
* `multiply-operator`
* `divide-operator`
* `greater-than-or-equals-operator`
* `less-than-or-equals-operator`

### Identifiers ###

* `quoted-label` quoted with backtick
* `regular-identifier`
* `keyword`
* `non-reserved-word`
* `reserved-word`

=== Other ===

* `variable`
