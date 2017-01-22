TITLE
=====

class Pod::Render

SUBTITLE
========

Render POD documents to HTML, PDF or MD

    class Pod::Render { ... }

Synopsis
========

    use Pod::Render;
    my Pod::Render $pr .= new;
    $pr.render( 'html', 'my-excellent-pod-document.pod6');

Methods
=======

render
------

    multi method render ( 'html', Str:D $pod-file, Str :$style )
    multi method render ( 'pdf', Str:D $pod-file, Str :$style )
    multi method render ( 'md', Str:D $pod-file )

Render the document given by `$pod-file` to one of the output formats html, pdf or markdown. To generate pdf the program `wkhtmltopdf` is used so that program must be installed. The style is one of the following styles; pod6 default desert doxy sons-of-obsidian sunburst.
