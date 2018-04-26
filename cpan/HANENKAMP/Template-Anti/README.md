NAME
====

Template::Anti - The anti-template templating tool

[![Build Status](https://travis-ci.org/zostay/Template-Anti.svg)](https://travis-ci.org/zostay/Template-Anti)

SYNOPSIS
========

    use Template::Anti;

    class MyApp::View {
        has $.token; # custom attributes, if you want them

        method hello($dom, :$title, :$welcome-message) is anti-template(:source<welcome.html>) {
            $dom('title', :one).content($title);
            $dom('.welcome-message', :one).content($welcome-message);
            $dom('input#api_token', :one).val($!token);
        }

        # Or put the logic into people.html:
        # <script type="application/anti+perl6">
        #   $dom('input#api_token', :one).val($!token);
        #   $dom('title, h1')».content(.<title>);
        #   $dom('h1')».attr(title => .<motto>);
        #   $dom('ul.people li:not(:first-child)')».remove;
        #   $dom('ul.people li:first-child', :one)\
        #       .duplicate(.<sith-lords>, -> $item, $_ {
        #           $item('a', :one).content(.<name>).attr(href => .<url>);
        #       });
        # </script>
        method sith($dom, $_) is anti-template(:source<people.html>) {
            ... # yada signals embedded logic
        }
    }

    # The source files are just plain old HTML. Nothing special about them.

    # Construct a library of templates
    my $ta = Template::Anti::Library.new(
        path  => </var/myapp/template-root/ /var/myapp/other-template-root/>,
        views => {
            main => MyApp::View.new(:token<secret>),
        },
    );

    # Use .process() to render the templates with input
    say $ta.process('main.hello', :title<Hello World>, :welcome-message<Welcome!>);
    say $ta.process('main.site', %sith-lords);

DESCRIPTION
===========

It is a generally accepted principle that you should avoid mixing code with presentation. Yet, whenever a software engineer needs to render some custom HTML or text or something, the first tool she pulls out of her toolbelt is a templating engine, which does that very thing. Rather than building a file that is either some nice programming language like Perl 6 or a decent document language like HTML5, she ends up with some evil hybrid that:

  * Confuses tools made to read either of those languages,

  * Adds training overhead and burdensome syntax for your front-end developers to work around,

  * Generally uglifies your code making your templates harder to read as they mix two or three language syntaxes together inline.

This "templating" engine allows you to put an end to that.

This module, [Template::Anti](Template::Anti), is the anti-templating engine. This tool splits your presentation from your code in a way that is familiar to many front-end developers, using a select-and-modify methodology similar to jQuery.

It borrows a few ideas from tools like [Template::Pure](https://metacpan.org/pod/HTML::Zoom), [Template::Semantic](https://metacpan.org/pod/Template::Semantic), and [pure.js](https://beebole.com/pure/).

Template Source
===============

To build a template you need two components:

  * You need some HTML or XML source to work with.

  * You need a block of code to execute against the parsed representation of that source.

From there, Template::Anti provides two different ways to process your templates, inline (a.k.a. embedded) and out-of-line. Let's consider the latter first.

Out-of-Line Processing
----------------------

This is the "pure" use-case that completely separates your template from your view processor, which should maximize reuse for most applications. To do this, you create an HTML original and then a method to apply a set of rules and modifications to it, like this:

    class MyTemplate {
        method index($dom, :$title) is anti-template(:source<index.html>) {
            $dom('title')».content($title);
        }
    }

The `is anti-template` trait associates a source file name with your method. When it comes time to process the template, this will be found within the search paths setup in [/Template::Anti::Library](/Template::Anti::Library). The trait takes two optional named parameters:

  * The `source` parameter will name the original file to associate with this processing method.

  * The `format` parameter names the format to use when parsing the original. It defaults to "html" but may be set to "xml" instead.

The first positional argument to the method will always be the DOM object parsed from the original source file. The remaining parameters are whatever you want to pass to your views.

Inline Processing
-----------------

At times, it may be convenient to keep your processing code within the original file. In this case, your original file will include zero or more `<script></script>` blocks with the type attribute set to "application/anti+perl6". For example, here is a simple template you might have in your assets directory:

    <html>
        <head>
            <title>Hello</title>
            <script type="application/anti+perl6" data-dom="$tmpl" data-stash="$data">
            $tmpl('title', h1').text($data<title>);
            </script>
        </head>
        <body>
            <h1>Hello</h1>
        </body>
    </html>

The `type="application/anti+perl6"` attirbute is required. The `data-dom` and `data-stash` attributes are optional. These attributes the names of the template variables the engine will provide to the block.

The `data-dom` names the variable to use for the DOM representation within the script-tag. (The DOM will be provided without these script-tags present.) The default `data-dom` name is `"$dom"`.

The `data-stash` attribute names the variable to use for the remaining captured arguments. The default `data-stash` name is `"$_"`. It is up to the code within the script-tag to handle any further argument handling.

This works whether the template is HTML or XML. However, when templating with XML, it is also recommended that you wrap your code in a `<![CDATA[ ]]>` section to avoid problems with greater than signs (">"), less than signs ("<"), and ampersands in your code confusing the parser.

Finally, the processing method for this template looks like the following:

    class MyTemplate {
        method index(|) is anti-template(:source<index.html>) {
            ...
        }
    }

The yada (...) signals that this the method logic will be filled in by scripts embedded within the original. The capture bar (|) is shown here because the method itself is just a placeholder and won't actually be called or used. The arguments you set here do not matter at all, so it is recommended you leave them blank in whichever way you prefer.

Template::Anti::Library
=======================

This class provides tools for locating original source files for parsing and for grouping your processing methods together. You do not have to use it. If you only need a single template or want to provide your own mechanism for locating and reading the files and calling the templates, see [/One-off Templates](/One-off Templates) for details.

method path
-----------

    method path() returns Array:D

This is the accessor for the paths set when Template::Anti::Library is constructed.

    my $ta = Template::Anti::Library.new(
        path => </var/www /var/www2>,
        ...
    );

These paths name the directories that are searched when locating an original source file.

method views
------------

    method views() returns Hash:D

This is the accessor for the views set when Template::Anti::Library is constructed.

    my $ta = Template::Anti::Library.new(
        views => {
            user => MyApp::View::User.new,
            page => MyApp::View::Page.new,
            book => MyApp::View::Book.new,
        },
        ...
    );

This is a map of names to objects that each should contain one or more methods that have been tagged with the `is anti-template` trait. The names are used by the [/method process](/method process) as part of the name used to look up the template to process.

method process
--------------

    method process(Str $template, |c) returns Str:D

This is the workhorse of the system. If the named template has never been processed before, the source template will be located, read, and parsed according to the format for that template. This setup happens once and the result is then cached. It will then process the arguments passed (any arguments after the template name are passed as is through to the processing method).

The `$template` name itself should be composed of two names separated by a period ("."). The first name is name given to the [/method views](/method views) parameter. The second is the name of the processing method to call on that object.

Exported Routines
=================

trait is anti-template
----------------------

    sub trait_mod:<is> (Routine $r, :$anti-template)

This marks a method as being a Template::Anti processing method. It takes two named arguments.

    method tmpl($dom, *%stash) is anti-template(
        :source<file.html>,
        :format<html>,
    ) { ... }

The `:source` is the name of the file to load. The location of the file is relatives to the paths set on the `path` attribute on [/Template::Anti::Library](/Template::Anti::Library).

The `:format` is the format to use, usually "html" or "xml" unless you have defined your own custom formats.

A method declared with this trait that is a yada-method (i.e., it has no code in the block, just a yada (...), will cause Template::Anti to assume that the code is embedded within the original source file named in `:source`.

multi get-anti-format-object
----------------------------

    multi get-anti-format-object('html')
    multi get-anti-format-object('xml')

These each return a format object that will parse the source using a slightly extended version of [DOM::Tiny](DOM::Tiny) and return it. They will also extract embedded processing code from `<script>` tags in the source.

New multis can be defined to extend the formats available to Template::Anti. See [/Advanced Formats](/Advanced Formats) for details.

These two multi implementations are always exported.

sub anti-template
-----------------

    use Template::Anti :one-off;
    sub anti-template(&process?, Str:D :$source!, Str:D :$format = 'html') returns Routine:D

This is exported in the `:one-off` group. This routine builds a template routine and returns it. The returned routine completely encapsulates the processing of the template.

See [/One-off Templates](/One-off Templates) for a full example of this routine in action.

The `&process` is optional. When given, it names the routine to call to transform a template source and stash into a final version of the template source. If not given, it is assumed that any processing will be embedded within the template. When given, it should expect at least one positional argument, which will be the DOM object parsed from the original in `$source`. Any remaining arguments are whatever will be passed to the returned routine.

    sub ($dom, |c) { ... }

The return value of this routine is ignored. It may modify the `$dom` object in place. The type of that `$dom` object will be a subclass of [DOM::Tiny](DOM::Tiny) when `$format` is set to "html" and "xml".

The `$source` is required and contains the complete contents of the original file source. For "html" formats, this would be a regular HTML file. For "xml" formats, it would be a regular XML file.

The `$format` tells the `anti-template` routine which format the file is in and how to parse and process it. Template::Anti provides two built-in formats, "html" and "xml", both use a slightly extended [DOM::Tiny](DOM::Tiny) to parse and process the file. Custom formats can also be crafted. See [/Advanced Formats](/Advanced Formats).

The format also determines how to extract embedded templates. In the case of "xml" and "html", the embedding is handled via `<script>` tags that have the type set to "application/anti+perl6". These actually support the use of multiple `<script>` tags, which are process in order they appear in the file, each getting it's own `data-dom` and `data-stash` settings (see [/Inline Processing](/Inline Processing)).

The returned routine will work something like this:

    sub (|c) returns Str:D { ... }

Here the `|c` capture will be passed through to the `&process` routine. Here are a few quick examples:

    sub process1($dom) { ... }
    my &process1-template = anti-template(&process1, ...);
    say process1-template();

    sub process2($dom, $user, :$title, :$name) { ... }
    my &process2-template = anti-template(&process2, ...);
    say process2-template(MyUser.new(0), :title<Hello>, :name<Bob>);

    sub process3($dom, %stash) { ... }
    my &process3-template = anti-template(&process3, ...);
    say process3-template(%myapp-stash);

The arguments are passed through in just that fashion.

Once the `&process` passed to `anti-template` has been called, the template object (`$dom` in the signature above), will be stringified by calling the `Str` method on it. That stringified version of the value is returned.

DOM::Tiny Customization
=======================

Template::Anti uses a slightly customized subclass of [DOM::Tiny](DOM::Tiny) that provide a couple additional features that are useful when processing the original source file. Some or all of these might be rolled up into DOM::Tiny in the future, but they are here for now.

(It should be noted that where the signatures here show [DOM::Tiny](DOM::Tiny), this is really returning the slightly extended subclass that Template::Anti provies. The name of that subclass is not documented because it is expected to change in the future.)

method postcircumfix:<( )>
--------------------------

    multi method postcircumfix:<( )> ($selector) returns Seq:D
    multi method postcircumfix:<( )> ($selector, Bool :$one) returns DOM::Tiny:D

This allows for a sometimes shortened notation when using [DOM::Tiny](DOM::Tiny). Basically, the following are equivalent:

    # Long notation
    @ps = $dom.find('p');
    $p  = $dom.at('p');

    # Short notation
    @ps = $dom('p');
    $p  = $dom('p', :one);

Use whichever you prefer.

method duplicate
----------------

    method duplicate(@items, &dup) returns DOM::Tiny:D

This performs a complicated operation that is useful when you want to loop over several stash values and duplicate some part of your DOM using variants. Here's a simple example to illustrate:

    $dom.at('li').duplicate([ 1, 2, 3 ], -> $li, $number {
        $li.content($number);
    });

If our source started out as:

    <ul>
        <li>demo</li>
    </ul>

It would now rea:

    <ul>
        <li>1</li>
        <li>2</li>
        <li>3</li>
    </ul>

One-Off Templates
=================

If you just need a quick template and don't need to worry about building a complete library of methods, there is also a mechanism for creating one-off template routines. This requires using the `anti-template` routine, which is exported when the `:one-off` flag is passed during import.

    use Template::Anti :one-off;

    my $source = q:to/END_OF_SOURCE/;
    <html><head><title>Hello World</title></head>
    <body>
        <h1>Hello World</h1>
        <ul class="people">
            <li><a href="/person1'>Alice</a></li>
            <li><a href="/person2'>Bob</a></li>
            <li><a href="/person3'>Charlie</a></li>
        </ul>
    </body></html>
    END_OF_SOURCE

    my &hello = anti-template :$source, -> $dom, $_ {
        $dom('title, h1')».content(.<title>);
        $dom('h1')».attr(title => .<motto>);
        $dom('ul.people li:not(:first-child)')».remove;
        $dom('ul.people li:first-child', :one)\
            .duplicate(.<sith-lords>, -> $item, $_ {
                $item('a', :one).content(.<name>).attr(href => .<url>);
            });
    }

    # Render the output:
    print hello(
        title      => 'Sith Lords',
        motto      => 'The Force shall free me.',
        sith-lords => [
            { name => 'Vader',   url => 'http://example.com/vader' },
            { name => 'Sidious', url => 'http://example.com/sidious' },
        ],
    );

    # Or if you must mix your code and presentation, you can embed the rules
    # within a <script/> tag in the source, which is still better than mixing it
    # all over your HTML:
    my $emb-source = q:to/END_OF_SOURCE/;
    <html><head><title>Hello World</title></head>
    <body>
        <h1>Hello World</h1>
        <ul class="people">
            <li><a href="/person1">Alice</a></li>
            <li><a href="/person2">Bob</a></li>
            <li><a href="/person3">Charlie</a></li>
        </ul>
        <script type="application/anti+perl6" data-dom="$dom">
            $dom('title, h1')».content(.<title>);
            $dom('h1')».attr(title => .<motto>);
            $dom('ul.people li:not(:first-child)')».remove;
            $dom('ul.people li:first-child', :one)\
                .duplicate(.<sith-lords>, -> $item, $_ {
                    $item('a', :one).content(.<name>).attr(href => .<url>);
                });
        </script>
    </body></html>
    END_OF_SOURCE

    my &hello-again = anti-template :source($emb-source), :html, :embedded;
    print hello-again(%vars);

Advanced Formats
================

While this library has been built using [DOM::Tiny](DOM::Tiny) to implement XML and HTML parsing and rendering of template sources, it is possible to extend Template::Anti to support parsing sources in any other format. To do this, you need to define a custom `multi sub` named `get-anti-format-object` in your code. For example, here is one built with a couple anonymous classes that will work with plain text files that contain specially formatted blanks.

    multi sub get-anti-format-object('blanktext') {
        class {
            method parse($source) {
                class {
                    has $.source is rw;

                    method set($blank, $value) {
                        $!source ~~ s:g/ < "_$blank_" > /$value/;
                        Mu
                    }

                    method Str { $.source }
                }.new(:$source);
            }

            method embedded-source($struct) {
                my $code;
                ($struct.source, $code) = $struct.source.split("\n__CODE__\n", 2);

                use MONKEY-SEE-NO-EVAL;
                my $sub = $code.EVAL;

                $sub;
            }
        }
    }

This also adds support for embedding the code part of the template in the source following a `__CODE__` annotation. Here's a couple examples using this custom object.

In `welcome.txt`, we could have this:

    Subject: Welcome _name_ to the Dark Side

    _name_

    Welcome to the Dark Side. Enclosed you will find instructions on how
    to reach the Sith planet to begin your training.

    Love,
    _dark-lord_

And in `welcome-embedded.html`, we could have this:

    Subject: Welcome _name_ to the Dark Side

    _name_

    Welcome to the Dark Side. Enclosed you will find instructions on how
    to reach the Sith planet to begin your training.

    Love,
    _dark-lord_

    __CODE__
    sub ($email, *%data) {
        $email.set($var, %data{ $var }) for <name dark-lord>;
    }

And in our code, we can write this:

    use Template::Anti;

    class MyEmails {
        method hello($email, *%data) is anti-template(:source<welcome.html>) {
            $email.set($var, %data{ $var }) for <name dark-lord>;
        }

        method hello-embedded($email, %adata) is anti-template(:source<welcome-embedded.html>) {
            ...
        }
    }

    my $ta = Template::Anti::Library.new(
        path  => </var/myapp/root>,
        views => { :email(MyEmails.new) },
    );

    say $ta.process('email.welcome', :name<Starkiller>, :dark-lord<Darth Vader>);
    say $ta.process('email.welcome-embedded', :name<Starkiller>, :dark-lord<Darth Vader>);

This way, you can get code separated from your templates in any format you like.

If your format object does not have an `embedded-source` method defined, attempting to us the embedded form of `anti-template` will result in an exception.

Finally, whatever object is used as the parsed structure for your template (i.e., takes the place of the [DOM::Tiny](DOM::Tiny) object provided with the built-in "xml" and "html" formats) must supply a `Str` method to render the object to string.
