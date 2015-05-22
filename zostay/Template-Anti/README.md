# Template::Anti

[![Build Status](https://travis-ci.org/zostay/Template-Anti.svg)](https://travis-ci.org/zostay/Template-Anti)

## Synopsis

    use Template::Anti;
    my $tmpl = Template::Anti.load('<html><head><title>Hello World</title>...');

    # Now, apply your template rules from your Perl source
    $tmpl('title, h1').text('Sith Lords');
    $tmpl('h1').attrib(title => 'The Force shall free me.');
    $tmpl('ul.people').truncate(1).find('li').apply([
        { name => 'Vader',   url => 'http://example.com/vader' },
        { name => 'Sidious', url => 'http://example.com/sidious' },
    ]).via: -> $item, $sith-lord {
        my $a = $item.find('a');
        $a.text($sith-lord<name>);
        $a.attrib(href => $sith-lord<url>);
    });

    # Render the output:
    print $tmpl.render;

    # Or if you insist on mixing your code and presentation, you can embed the
    # rules within a <script/> tag in the source, which is still better than
    # mixing it all over your HTML:
    my $embt = Template::Anti.load(q:to/END_OF_TMPL/);
    <html>
        ...
        <script type="text/x-perl6" data-template="$anti">
        <![CDATA[
        $anti("h1").text("Sith");
        ]]>
        </script>
        ...
    </html>
    END_OF_TMPL

    $embt.process-scripts;
    print $empt.render;

## Description

Everyone knows that you should not mix your code with your presentation. Yet,
whenever a software engineer needs to render some custom HTML or text or
something, the first tool she pulls out of her toolbelt is a templating engine,
which does that very thing. Rather than building a file that is neither some
nice programming language like Perl6 nor a nice document language like HTML5,
she ends up with some evil hybrid that:

1. Confuses tools made to read either (or both) of those languages, 

2. Adds training overhead and burdensome syntax for your front-end developers to
   work around,

3. Generally uglifies your code making your templates hard to read as they mix
   two or three language syntaxes together inline.

Stop it!

There's a better way, Template::Anti, the anti-templating engine. This
library splits your presentation from your code in a way that is familiar to
many front-end developers, using a select-and-modify methodology similar to
jQuery.

