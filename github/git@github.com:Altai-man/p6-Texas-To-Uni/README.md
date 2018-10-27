Texas::To::Uni
====================

**WORK IN PROGRESS**

This package provides you a basic(and incomplete) way to convert operators in your Perl 6-related files from Texas(ASCII-based) version to Unicode symbol version.

It doesn't support some operators and have some limitations, but it will be improved in the future.

Usage
====================

The most simple example is:

``` perl6
use Texas::To::Uni;

convert-file($filename);
```

This module has two basic subroutines:

 * `convert-file` - it takes file name and by default points output to a new file with extension like `old-file-name.uni.old-extension`. New path can be set in `:$new-path` named argument. It can rewrite file if `:$rewrite` flag was set. However, rewriting is not recommended, since this module is still buggy and can mess up your work.

 * `convert-string` - internal function that takes read-write string and converts it accordingly to operator table.

Contribution
====================

Pull requests are welcome: new tests, fixes, improvements or just suggestions in the Issue.
