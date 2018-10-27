This is a Perl 6 module that makes it easy to write Scalable Vector Graphic
files, short SVG.

Right now it is a shallow wrapper around XML::Writer, adding only the xmlns
attributes that identifies an XML file as SVG.

For building an running the tests, we recommend to obtain [zef](http://modules.perl6.org/dist/zef) and then run

    $ zef install SVG

You can then use it like this:

    use SVG;
    say SVG.serialize(
        svg => [
            width => 100, height => 10,
            :rect[:x<5>, :y<5>, :width<90>, :height<90>, :stroke<black>],
        ],
    );

Author: Moritz Lenz
License: Artistic License 2.0
