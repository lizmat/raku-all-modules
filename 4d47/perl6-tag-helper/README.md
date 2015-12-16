
# Tag

The tag string generator (Engineered for making XML or HTML5 soup). In Perl 6 !

## Warning

My friend, this is broken. It is implemented using FALLBACK method, unfortunatly it calls only _if all other attempts to locate a method fail_. Since parents provide plenty of methods this is not a good idea, eg. as of 2015-11 the tests broke because of a new `head` method.

## Why ?

To start writing Perl 6. Was learning the language and wanted something small
to play around with, so I thought it would be nice to compare with an an old
[PHP utility][1] I had.

    use Tag;
    Tag.a(:$href, :$title, Tag.b($name)).br;

Basically like the Html class described on [slide 37][2] of the [Perl 6: beyond dynamic vs. static][3] presentation.

## Ideas

- Its probably best to not output everything if very large gist
- use the power of macros to port [hiccup][4]

[1]: https://github.com/4d47/php-tag-helper
[2]: https://fosdem.org/2015/schedule/event/perl6_beyond_dynamic_vs_static/attachments/slides/724/export/events/attachments/perl6_beyond_dynamic_vs_static/slides/724/2015_fosdem_static_dynamic.pdf#page=37
[3]: https://fosdem.org/2015/schedule/event/perl6_beyond_dynamic_vs_static/
[4]: https://github.com/weavejester/hiccup
