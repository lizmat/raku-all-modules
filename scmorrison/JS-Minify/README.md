# JS::Minify [![Build Status](https://travis-ci.org/scmorrison/JS-Minify.svg?branch=master)](https://travis-ci.org/scmorrison/JS-Minify)

JS::Minify removes comments and unnecessary whitespace from JavaScript files. It typically reduces filesize by half, resulting in faster downloads. This is a Perl 6 port of [JSMin](https://github.com/douglascrockford/JSMin) originally created by Douglas Crawford. JS::Minify incorporates several bug-fixes that have been resolved in various JSMin ports from other languages (Perl, Python, etc.).

JS::Minify is considered safe:

* Quoted strings and regular expression literals are not modified
* No obfuscation or renaming occurs.

# Synopsis

Minify a JavaScript file and have the output written directly to another file:

```perl6
use JS::Minify;

my $js = slurp 'myScript.js';
spurt 'myScript-min.js', js-minify(input => $js);
```

Minify a JavaScript string literal:

```perl6
my $minified_javascript = js-minify(input => 'var x = 2;');
```

Include a copyright comment at the top of the minified code:

```
js-minify(input => 'var x = 2;', copyright => 'BSD License');
```

Treat ';;;' as '//' so that debugging code can be removed. This is a common JavaScript convention for minification:

```perl6
js-minify(input => "var x = 2;\n;;;alert('hi');\nvar x = 2;", stripDebug => 1)
# output: 'var x=2;var x=2;'
```

The `input` parameter is mandatory. The `copyright` and `strip_debug` parameters are optional and can be used in any combination.

# Description

This module removes unnecessary whitespace from JavaScript code. The primary requirement developing this module is to not break working code: if working JavaScript is in input then working JavaScript is output. It is ok if the input has missing semi-colons, snips like '++ +' or '12 .toString()', for example. Internet Explorer conditional comments are copied to the output but the code inside these comments will not be minified.

The ECMAScript specifications allow for many different whitespace characters: space, horizontal tab, vertical tab, new line, carriage return, form feed, and paragraph separator. This module understands all of these as whitespace except for vertical tab and paragraph separator. These two types of whitespace are not minimized.

For static JavaScript files, it is recommended that you minify during the build stage of web deployment. If you minify on-the-fly then it might be a good idea to cache the minified file. Minifying static files on-the-fly repeatedly is wasteful.

## Export

Exported by default: `js-minifiy()`

# See Also

[JavaScript::Minifier](https://metacpan.org/pod/JavaScript::Minifier) (Perl)

# Repository

You can obtain the latest source code and submit bug reports on the github repository for this module:
[https://github.com/scmorrison/JS-Minify](https://github.com/scmorrison/JS-Minify).

# Author

* Sam Morrison, [scmorrison](https://github.com/scmorrison/)

## JS::Minify is based on the Perl *Javascript::Minifier* module developed by the following:

* Zoffix Znet, <zoffix@cpan.org> [https://metacpan.org/author/ZOFFIX](https://metacpan.org/author/ZOFFIX)
* Peter Michaux, <petermichaux@gmail.com>
* Eric Herrera, <herrera@10east.com>
* Miller 'tmhall' Hall
* Вячеслав 'vti' Тихановский

The original JSMin was developed by Douglas Crockford:

* [JSMin](https://github.com/douglascrockford/JSMin)

# License Information

"JS::Minify" is free software; you can redistribute it and/or modify it under the terms of the Artistic License 2.0. (Note that, unlike the Artistic License 1.0, version 2.0 is GPL compatible by itself, hence there is no benefit to having an Artistic 2.0 / GPL disjunction.) See the file LICENSE for details.

