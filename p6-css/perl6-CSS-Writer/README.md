# perl6-CSS-Writer

AST writer/serializer module. Compatible with CSS:Module and CSS::Grammar.

## Examples


#### Serialize a declaration (ruleset); converting named colors to RGB masks 
    use CSS::Writer;
    my $css-writer = CSS::Writer.new( :terse, :color-values, :color-masks );
    say $css-writer.write(
        :ruleset{
            :selectors[ :selector[ { :simple-selector[ { :element-name<h1> } ] } ] ],
            :declarations[
                 { :ident<font-size>, :expr[ :pt(12) ] },
                 { :ident<color>,     :expr[ :ident<white> ] },
                 { :ident<z-index>,   :expr[ :num(-9) ] },
                ],
        });

    # output: h1 { font-size:12pt; color:#FFF; z-index:-9; }


#### Tidy and reduce size of CSS
    use CSS::Writer;
    use CSS::Grammar::CSS3;

    sub parse-stylesheet($css) {
        use CSS::Grammar::CSS3;
        use CSS::Grammar::Actions;
        my $actions = CSS::Grammar::Actions.new;
        CSS::Grammar::CSS3.parse($css, :$actions)
           or die "unable to parse: $css";

        return $/.ast
    }

    my $css-writer = CSS::Writer.new( :terse );
    my $stylesheet = parse-stylesheet( 'H1{  cOlor: RED; z-index  : -3}' );

    say $css-writer.write( $stylesheet );

    # output: h1 { color:red; z-index:-3; }


## Writer Options

- **`:ast`** Provide a default ast. This enables stringification, e.g.
    ```
    my $css = CSS::Writer.new( :ast( :string('Hello World!' ) ) );
    say ~$css;  # output: 'Hello World!'
    ```

- **`:color-masks`** Prefer hex mask notation for RGB values, .e.g. `#0085FF` instead of `rgb(0, 133, 255)`

- **`:color-names`** Convert RGB values to color names

- **`:color-values`** Convert color names to RGB values

- **`:terse`** write each stylesheet element on a single line, without indentation. Don't write comments.

## Usage Notes

- The initial version CSS::Writer is based on the objects, values and serialization rules described in http://dev.w3.org/csswg/cssom/.
