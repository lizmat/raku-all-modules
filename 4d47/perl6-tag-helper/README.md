
# Tag

The tag string generator (Engineered for making XML or HTML5 soup). In Perl 6 !

## Why ?

To start writing Perl 6. Was learning the language and wanted something small
to play around with, so I thought it would be nice to compare with an an old
[PHP utility](https://github.com/4d47/php-tag-helper) I had.

    use Tag;
    Tag.a(:$href, :$title, Tag.b($name)).br;

## Ideas

- Make @.void-elements and @.boolean-attributes lookup case insensitive
- Its probably best to not output everything if very large gist
- use the power of macros and port [hiccup](https://github.com/weavejester/hiccup)

