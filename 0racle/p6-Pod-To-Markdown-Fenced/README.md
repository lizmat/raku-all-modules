NAME
====
Pod::To::Markdown::Fenced - Render POD code blocks as fenced (```) code blocks

SYNOPSIS
========
Do you like syntax highlighting?

Do you hate maintaining POD and Markdown seperately if you want language specific fenced code blocks in your README so GitHub (GFM) does syntax highlighting.

If so, this module is for you.

This module overrides `Pod::To::Markdown`'s multi-sub that handles `Pod::Block::Code`. In the resulting output, that code block will now be fenced rather than indented. In this case, it is no longer strict Markdown, but something closer to CommonMark.

If that's all it did this module would be pretty pointless, so in addition, you can define a `info` config option, which will be set as the [info string](http://spec.commonmark.org/0.12/#info-string) on the code block. This will allow syntax highlighting of the code block where supported (like Github).

USAGE
=====
From command line:

    $ perl6 --doc=Markdown::Fenced lib/MyClass.pm

From Perl 6:

    Use Pod::To::Markdown::Fenced;

    Here is some perl

    =begin code :info<perl6>
    say [>] ('apples', 'oranges')».chars;
    =end code

    Some not perl

    =begin code :info<javascript>
    console.log('apples'.length > 'oranges'.length)
    =end code

    And a normal code block

    =begin code
    Stop comparing apples to oranges.
    =end code

    say pod2markdown($=pod);

Which produces the following output

    Here is some perl

    ```perl6
    say [>] ('apples', 'oranges')».chars;
    ```

    And some not perl

    ```javascript
    console.log('apples'.length > 'oranges'.length)
    ```

    And a normal code block
    
    ```
    Stop comparing apples and oranges.
    ```

EXAMPLE 
=======

This README contains uses of literal POD and Markdown, so trying to render that correctly with a POD-to-Markdown renderer doesn't work too well. For a better example, refer to my [Net::Netmask](https://github.com/0racle/p6-Net-Netmask) module. The README.md file in that repo is generated completely by this module from the embedded POD in the module file.

LIMITATIONS AND ISSUES
======================
This module depends on [Pod::To::Markdown](https://github.com/softmoth/perl6-pod-to-markdown) which handles nested `Pod::FormattingCode` by setting a lexical Boolean variable `$in-code-block`. As my multi-sub cannot influence that lexical variable, you may run into issues when using `Pod::FormattingCode` blocks with this module.

This could be solved a number of ways (submitting a pull for `Pod::To::Markdown` to expose that variable to the outside world, or copying parts/all of `Pod::To::Markdown` into this module) but for what I need it works well enough. If people really need nested `Pod::FormattingCode` blocks, I'm happy to respond to an issue or accept a pull request that resolves it.

This module works by setting a (currently) non-existant config option. The POD spec does not specify any `info` config option, and with luck that won't change in the future.

LICENCE
=======

    The Artistic License 2.0 

See LICENSE file in the repository for the full license text.


