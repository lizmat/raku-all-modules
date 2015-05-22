use v6;

use XML;

use Template::Anti::Template;

=begin pod

=TITLE class Template::Anti

=SUBTITLE The anti-template templating tool

=begin SYNOPSIS

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

=end SYNOPSIS

=begin DESCRIPTION

Everyone knows that you should not mix your code with your presentation. Yet, whenever a software engineer needs to render some custom HTML or text or something, the first tool she pulls out of her toolbelt is a templating engine, which does that very thing. Rather than building a file that is neither some nice programming language like Perl6 nor a nice document language like HTML5, she ends up with some evil hybrid that:

=item 1. Confuses tools made to read either (or both) of those languages, 

=item 2. Adds training overhead and burdensome syntax for your front-end developers to work around,

=item 3. Generally uglifies your code making your templates hard to read as they mix two or three language syntaxes together inline.

Stop it!

There's a better way, L<Template::Anti>, the anti-templating engine. This library splits your presentation from your code in a way that is familiar to many front-end developers, using a select-and-modify methodology similar to jQuery.

=end DESCRIPTION

=head1 Templates

Currently, the templates input must be in XML format. This is more of a limitation than intended, mostly because no one has written a full-featured HTML parser for Perl6 yet, at least not to my knowledge. 

On the other hand, it is also a feature that you can template XML files as well as HTML. If you want to render XML files for output, you may extract the C<$.template> object from L<Template::Anti::Template> and stringify it. If you want HTML files as output, use the C<render> method of that class.

There are two different ways to process your templates, inline and out-of-line. Let's consider the latter first.

=head2 Out-of-Line Processing

This is the original use-case I had planned. This is the pure method that completely separates your template from your view processor, which maximizes reuse. It works like the L</SYNOPSIS> where you create a template and then apply a set of rules and node-set modifications, like this:

    my $at = Template::Anti.load('index.html'.IO);
    $at('title').text('Star Wars');
    say $at.render;

This is generally the preferred method of using this module.

=head2 Inline Processing

However, it is sometimes convenient to keep your processing code with the template itself. It would still be appalling to mix template code with code willy-nilly, but HTML provides a reasonable interface for scripting. Therefore, if your template contains one or more C«<script></script>» tags formatted properly, you may use this style instead. For example, here is a simple template you might have in your assets folder:

    <html>
        <head>
            <title>Hello</title>
            <script type="text/x-perl6" data-template="$tmpl"><![CDATA[
            $tmpl('title', h1').text('Star Wars');
            ]]></script>
        </head>
        <body>
            <h1>Hello</h1>
        </body>
    </html>

Both the C<type="text/x-perl6"> and C<data-template> attributes are required. The value in C<data-templates> is up to you. It gives the name of the template variable to use within the block. You can use any Perl code you like.

It is also recommended that you wrap your code in a C«<![CDATA[ ]]>» section to avoid problems with greater than signs (">"), less than signs ("<"), and ampersands in your code confusing the parser.

To process this template, you can run something like this:

    my $at = Template::Anti.load('index.html'.IO);
    $at.process-scripts;
    say $at.render;

The C<process-scripts> method removes all the template script elements from the document and then evaluates each after lexically setting the variable named in the element's own C<data-template> attribute to the L<Template::Anti::Template> object. Each script tag may have its own variable name.

There is nothing preventing you from using a combination of both styles, but the scripts in the document are only processed if the C<process-scripts> method is run.

=head1 Methods

=head2 multi method load

    multi method load(Template::Anti: Str $source) returns Template::Anti::Template

Reads the XML template from the text in C<$source> and returns a L<Template::Anti::Template> for processing and rendering.

    multi method load(Template::Anti: IO::Path $file) returns Template::Anti::Template

Reads the XML template from the file named C<$file> and returns a L<Template::Anti::Template>.

    multi method load(Template::Anti: IO $handle) returns Template::Anti::Template

Reads the XML file from the file handle in C<$handle> and returns a L<Template::Anti::Template>.

    multi method load(Template::Anti: XML::Node $xml) returns Template::Anti::Template

Uses the given XML node to build a template and returns that in L<Template::Anti::Template>. The given C<$xml> node is cloned before use.

    multi method load(Template::Anti: Template::Anti::Template $tmpl) returns Template::Anti::Template

Uses the given template, C<$tmpl>, as the template. That is, it grabs the L<XML::Node> that the template wraps, clones it, and then returns a new L<Template::Anti::Template> for it.

=end pod

class Template::Anti {

    #| Use a string as the XML source.
    multi method load(Str $source) {
        my $template = from-xml($source);
        return Template::Anti::Template.new(:$template);

        CATCH {
            when 'could not parse XML' {
                die "Input templates must be valid XML documents.";
            }
        }
    }

    #| Use a filename as the XML source.
    multi method load(IO::Path $file) {
        my $template = from-xml-file($file.Str); # .Str is silliness
        return Template::Anti::Template.new(:$template);

        CATCH {
            when 'could not parse XML' {
                die "Input templates must be valid XML documents.";
            }
        }
    }

    #| Use a file handle as the XML source.
    multi method load(IO $stream) {
        my $template = from-xml-stream($stream);
        return Template::Anti::Template.new(:$template);

        CATCH {
            when 'could not parse XML' {
                die "Input templates must be valid XML documents.";
            }
        }
    }

    #| Use an existing XML object as the XML source (cloned to avoid changing an original).
    multi method load(XML::Node $xml) {
        my $template = $xml.cloneNode;
        return Template::Anti::Template.new(:$template);

        CATCH {
            when 'could not parse XML' {
                die "Input templates must be valid XML documents.";
            }
        }
    }

    #! Grab the template from another Template object (cloned to avoid changing that template object's template).
    multi method load(Template::Anti::Template $tmpl) {
        my $template = $tmpl.template.cloneNode;
        return Template::Anti::Template.new(:$template);

        CATCH {
            when 'could not parse XML' {
                die "Input templates must be valid XML documents.";
            }
        }
    }
}

