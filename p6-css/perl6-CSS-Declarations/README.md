# perl6-CSS-Declarations
CSS::Declarations is a class for managing CSS property lists, including parsing, inheritance, default handling and serialization.


## Basic Construction
```
use v6;
use CSS::Declarations::Units;
use CSS::Declarations;

my $style = "color:red !important; padding: 1pt";
my $css = CSS::Declarations.new( :$style );
say $css.important("color"); # True
$css.border-color = 'red';

$css.margin = [5pt, 2pt, 5pt, 2pt];
$css.margin = 5pt;  # set margin on all 4 sides

# output the style
say $css.Str; # border-color:red; color:red!important; margin:5pt; padding:1pt;
```

## CSS Property Accessors 

- color values are converted to Color objects
- other values are converted to strings or numeric, as appropriate
- the .type method returns additional type information
- box properties are arrays that contain four sides. For example, 'margin' contains 'margin-top', 'margin-right', 'margin-bottom' and 'margin-left';
- there are also some compound properties that may be accessed directly or via a hash; for example, The 'font' accessor returns a hash containing 'font-size', 'font-family', and other font properties.

```
use CSS::Declarations;

my $css = CSS::Declarations.new: :style("color: orange; text-align: CENTER; margin: 2pt; font: 12pt Helvetica");

say $css.color.hex;       # (FF A5 00)
say $css.color.type;      # 'rgb'
say $css.text-align;      # 'center'
say $css.text-align.type; # 'keyw' (keyword)

# access margin-top, directly and through margin container
say $css.margin-top;      # '2'
say $css.margin-top.type; # 'pt'
say $css.margin;          # [2 2 2 2]
say $css.margin[0];       # '2'
say $css.margin[0].type;  # 'pt'

# access font-family directly and through font container
say $css.font-family;       # 'Helvetica'
say $css.font-family.type;  # 'ident'
say $css.font<font-family>; # 'Helvetica;
```

The simplest ways of setting a property is to assign a string value.  The value will be parsed as CSS. This works for both simple and container properties. Unit values are also recognized. Also the type and value can be assigned as a pair.

```
use CSS::Declarations::Units;
my $css = (require CSS::Declarations).new;

# assign to container
$css.font = "14pt Helvetica";

# assign to simple properties
$css.font-weight = 'bold'; # string
$css.line-height = 16pt;   # unit value
$css.font-style = :keyw<italic>; # type/value pair

say ~$css; # font:italic bold 14pt/16pt Helvetica;
```

## CSS Modules

## Conformance Levels

Processing defaults to CSS level 3 (class CSS::Module::CSS3). This can be configured via the :module option:

```
use CSS::Declarations;
use CSS::Module::CSS1;
use CSS::Module::CSS21;

my $style = 'color: red; azimuth: left';

my $module = CSS::Module::CSS1.module;
my $css1 = CSS::Declarations.new( :$style, :$module);
## warnings: dropping unknown property: azimuth

$module = CSS::Module::CSS21.module;
my $css21 = CSS::Declarations.new( :$style, :$module);
## (no warnings)
```

### '@font-face' Declarations

`@font-face` is a sub-module of `CSS3`. To process a set of `@font-face` declarations, such as:

```
@font-face {
    font-family: myFirstFont;
    src: url(sansation_light.woff);
}
```

```
use CSS::Declarations;
use CSS::Module::CSS3;

my $style = "font-family: myFirstFont; src: url(sansation_light.woff)";
my $module = CSS::Module::CSS3.module.sub-module<@font-face>;
my $font-face-css = CSS::Declarations.new( :$style, :$module);
```

## Default values


Most properties have a default value. If a property is reset to its default value it will be omitted from stringification:

    my $css = (require CSS::Declarations).new;
    say $css.background-image; # none
    $css.background-image = 'url(camellia.png)';
    say ~$css; # "background-image: url(camellia.png);"
    $css.background-image = $css.info("background-image").default;
    say ~$css; # ""

## Inheritance

A child class can inherit from one or more parent classes. This follows CSS standards:

- Note all properties are inherited by default; for example `color` is inherited, but `margin` is not.

- the `inherit` keyword can be used in the child property to ensure inheritance.

- `initial` will reset the child property to the default value

- the `!important` modifier can be used in parent properties to force the parent value to override the child. The property becomes 'important' in the child and will be passed on to any CSS::Declarations objects that inherit from it.

```
my $parent-css = CSS::Declarations.new: :style("margin-top:5pt; margin-left: 15pt; color:rgb(0,0,255) !important");

my $css = CSS::Declarations.new: :style("margin-top:25pt; margin-right: initial; margin-left: inherit; color:purple"), :inherit($parent-css);

say $parent-css.important("color"); # True
say $css.color; # #FF0000 (red)

say $css.handling("margin-left");   # inherit
say $css.margin-left; # 15pt
```

## Serialization

The `.write` or `.Str` methods can be used to produce CSS. Properties are optimized and normalized:

- properties with default values are omitted

- simple properties are consolidated to containers (e.g. `font-family` to `font`).

- rgb masks are translated to color-names, if possible

```
use CSS::Declarations;
my $css = CSS::Declarations.new( :style("border-style: groove; border-width: 2pt 2pt; color: rgb(255,0,0);") );
say $css.write;  # "border: 2pt; color: red;"
```

Notice that:

- `border-style` was omitted because it has the default value

- `border-width` has been consolidated to the `border` container property. This was possible
because all four borders had the common value `2pt`

- `color` has been translated from a color mask to a color

`$.write` Options include:

- `:!optimize` - turn off optimization. Don't, combine simple properties into compound properties (`border-style`, `border-width`, ... => `border`), or combine edges (`margin-top`, `margin-left`, ... => `margin`).

- `:!terse` - enable multi-line output

- `:!color-names` - don't translate RGB values to color-names

## Property Meta-data

The `info` method gives property specific meta-data, on all simple of compound properties. It returns an object of type CSS::Declarations::Property:

```
use CSS::Declarations;
my $css = CSS::Declarations.new;
my $margin-info = $css.info("margin");
say $margin-info.synopsis; # <margin-width>{1,4}
say $margin-info.edges;    # [margin-top margin-right margin-bottom margin-left]
say $margin-info.inherit;  # True (property is inherited)
```

## Data Introspection

The `properties` method, gives a list of current properties. Only simple properties
are returned. E.g. `font-family` is, if it has a value; but `font` isn't.

```
use CSS::Declarations;

my $style = "margin-top: 10%; margin-right: 5mm; margin-bottom: auto";
my $css = CSS::Declarations.new: :$style;

for $css.properties -> $prop {
    my $val = $css."$prop"();
    say "$prop: $val {$val.type}";
}

```
Gives:
```
margin-top: 10 percent
margin-bottom: auto keyw
margin-right: 5 mm
```

## Length Units

CSS::Declaration::Units is a convenience module that provides some simple postfix length unit definitions, plus overriding of the '+' and '-'
operators. These are understood by the CSS::Declarations class.

The '+' and '-' operators convert to the left-hand operand's units.

```
use CSS::Declarations::Units;
my $css = (require CSS::Declarations).new: :margin[5pt, 10px, .1in, 2mm];

# display margins in millimeters
say "%.2f mm".sprintf(0mm + $_) for $css.margin.list;
```

## Appendix : CSS3 Properties

Name | Default | Inherit | Type | Synopsis
--- | --- | --- | --- | ---
azimuth | center | Yes |  | \<angle\> \| [[ left-side \| far-left \| left \| center-left \| center \| center-right \| right \| far-right \| right-side ] \|\| behind ] \| leftwards \| rightwards
background |  |  | hash | ['background-color' \|\| 'background-image' \|\| 'background-repeat' \|\| 'background-attachment' \|\| 'background-position']
background-attachment | scroll |  |  | scroll \| fixed
background-color | transparent |  |  | \<color\> \| transparent
background-image | none |  |  | \<uri\> \| none
background-position | 0% 0% |  |  | [ [ \<percentage\> \| \<length\> \| left \| center \| right ] [ \<percentage\> \| \<length\> \| top \| center \| bottom ]? ] \| [ [ left \| center \| right ] \|\| [ top \| center \| bottom ] ]
background-repeat | repeat |  |  | repeat \| repeat-x \| repeat-y \| no-repeat
border |  |  | hash,box | [ 'border-width' \|\| 'border-style' \|\| 'border-color' ]
border-bottom |  |  | hash | [ 'border-bottom-width' \|\| 'border-bottom-style' \|\| 'border-bottom-color' ]
border-bottom-color | the value of the 'color' property |  |  | \<color\> \| transparent
border-bottom-style | none |  |  | \<border-style\>
border-bottom-width | medium |  |  | \<border-width\>
border-collapse | separate | Yes |  | collapse \| separate
border-color |  |  | box | [ \<color\> \| transparent ]{1,4}
border-left |  |  | hash | [ 'border-left-width' \|\| 'border-left-style' \|\| 'border-left-color' ]
border-left-color | the value of the 'color' property |  |  | \<color\> \| transparent
border-left-style | none |  |  | \<border-style\>
border-left-width | medium |  |  | \<border-width\>
border-right |  |  | hash | [ 'border-right-width' \|\| 'border-right-style' \|\| 'border-right-color' ]
border-right-color | the value of the 'color' property |  |  | \<color\> \| transparent
border-right-style | none |  |  | \<border-style\>
border-right-width | medium |  |  | \<border-width\>
border-spacing | 0 | Yes |  | \<length\> \<length\>?
border-style |  |  | box | \<border-style\>{1,4}
border-top |  |  | hash | [ 'border-top-width' \|\| 'border-top-style' \|\| 'border-top-color' ]
border-top-color | the value of the 'color' property |  |  | \<color\> \| transparent
border-top-style | none |  |  | \<border-style\>
border-top-width | medium |  |  | \<border-width\>
border-width |  |  | box | \<border-width\>{1,4}
bottom | auto |  |  | \<length\> \| \<percentage\> \| auto
caption-side | top | Yes |  | top \| bottom
clear | none |  |  | none \| left \| right \| both
clip | auto |  |  | \<shape\> \| auto
color | depends on user agent | Yes |  | \<color\>
content | normal |  |  | normal \| none \| [ \<string\> \| \<uri\> \| \<counter\> \| \<counters\> \| attr(\<identifier\>) \| open-quote \| close-quote \| no-open-quote \| no-close-quote ]+
counter-increment | none |  |  | none \| [ \<identifier\> \<integer\>? ]+
counter-reset | none |  |  | none \| [ \<identifier\> \<integer\>? ]+
cue |  |  | hash | [ 'cue-before' \|\| 'cue-after' ]
cue-after | none |  |  | \<uri\> \| none
cue-before | none |  |  | \<uri\> \| none
cursor | auto | Yes |  | [ [\<uri\> ,]* [ auto \| crosshair \| default \| pointer \| move \| e-resize \| ne-resize \| nw-resize \| n-resize \| se-resize \| sw-resize \| s-resize \| w-resize \| text \| wait \| help \| progress ] ]
direction | ltr | Yes |  | ltr \| rtl
display | inline |  |  | inline \| block \| list-item \| inline-block \| table \| inline-table \| table-row-group \| table-header-group \| table-footer-group \| table-row \| table-column-group \| table-column \| table-cell \| table-caption \| none
elevation | level | Yes |  | \<angle\> \| below \| level \| above \| higher \| lower
empty-cells | show | Yes |  | show \| hide
float | none |  |  | left \| right \| none
font |  | Yes | hash | [ [ \<‘font-style’\> \|\| \<font-variant-css21\> \|\| \<‘font-weight’\> \|\| \<‘font-stretch’\> ]? \<‘font-size’\> [ / \<‘line-height’\> ]? \<‘font-family’\> ] \| caption \| icon \| menu \| message-box \| small-caption \| status-bar
font-family | depends on user agent | Yes |  | [ \<generic-family\> \| \<family-name\> ]\#
font-feature-settings | normal | Yes |  | normal \| \<feature-tag-value\>\#
font-kerning | auto | Yes |  | auto \| normal \| none
font-language-override | normal | Yes |  | normal \| \<string\>
font-size | medium | Yes |  | \<absolute-size\> \| \<relative-size\> \| \<length\> \| \<percentage\>
font-size-adjust | none | Yes |  | none \| auto \| \<number\>
font-stretch | normal | Yes |  | normal \| ultra-condensed \| extra-condensed \| condensed \| semi-condensed \| semi-expanded \| expanded \| extra-expanded \| ultra-expanded
font-style | normal | Yes |  | normal \| italic \| oblique
font-synthesis | weight style | Yes |  | none \| [ weight \|\| style ]
font-variant | normal | Yes |  | normal \| none \| [ \<common-lig-values\> \|\| \<discretionary-lig-values\> \|\| \<historical-lig-values\> \|\| \<contextual-alt-values\> \|\| stylistic(\<feature-value-name\>) \|\| historical-forms \|\| styleset(\<feature-value-name\> \#) \|\| character-variant(\<feature-value-name\> \#) \|\| swash(\<feature-value-name\>) \|\| ornaments(\<feature-value-name\>) \|\| annotation(\<feature-value-name\>) \|\| [ small-caps \| all-small-caps \| petite-caps \| all-petite-caps \| unicase \| titling-caps ] \|\| \<numeric-figure-values\> \|\| \<numeric-spacing-values\> \|\| \<numeric-fraction-values\> \|\| ordinal \|\| slashed-zero \|\| \<east-asian-variant-values\> \|\| \<east-asian-width-values\> \|\| ruby ]
font-variant-alternates | normal | Yes |  | normal \| [ stylistic(\<feature-value-name\>) \|\| historical-forms \|\| styleset(\<feature-value-name\>\#) \|\| character-variant(\<feature-value-name\>\#) \|\| swash(\<feature-value-name\>) \|\| ornaments(\<feature-value-name\>) \|\| annotation(\<feature-value-name\>) ]
font-variant-caps | normal | Yes |  | normal \| small-caps \| all-small-caps \| petite-caps \| all-petite-caps \| unicase \| titling-caps
font-variant-east-asian | normal | Yes |  | normal \| [ \<east-asian-variant-values\> \|\| \<east-asian-width-values\> \|\| ruby ]
font-variant-ligatures | normal | Yes |  | normal \| none \| [ \<common-lig-values\> \|\| \<discretionary-lig-values\> \|\| \<historical-lig-values\> \|\| \<contextual-alt-values\> ]
font-variant-numeric | normal | Yes |  | normal \| [ \<numeric-figure-values\> \|\| \<numeric-spacing-values\> \|\| \<numeric-fraction-values\> \|\| ordinal \|\| slashed-zero ]
font-variant-position | normal | Yes |  | normal \| sub \| super
font-weight | normal | Yes |  | normal \| bold \| bolder \| lighter \| 100 \| 200 \| 300 \| 400 \| 500 \| 600 \| 700 \| 800 \| 900
height | auto |  |  | \<length\> \| \<percentage\> \| auto
left | auto |  |  | \<length\> \| \<percentage\> \| auto
letter-spacing | normal | Yes |  | normal \| \<length\>
line-height | normal | Yes |  | normal \| \<number\> \| \<length\> \| \<percentage\>
list-style |  | Yes | hash | [ 'list-style-type' \|\| 'list-style-position' \|\| 'list-style-image' ]
list-style-image | none | Yes |  | \<uri\> \| none
list-style-position | outside | Yes |  | inside \| outside
list-style-type | disc | Yes |  | disc \| circle \| square \| decimal \| decimal-leading-zero \| lower-roman \| upper-roman \| lower-greek \| lower-latin \| upper-latin \| armenian \| georgian \| lower-alpha \| upper-alpha \| none
margin |  |  | box | \<margin-width\>{1,4}
margin-bottom | 0 |  |  | \<margin-width\>
margin-left | 0 |  |  | \<margin-width\>
margin-right | 0 |  |  | \<margin-width\>
margin-top | 0 |  |  | \<margin-width\>
max-height | none |  |  | \<length\> \| \<percentage\> \| none
max-width | none |  |  | \<length\> \| \<percentage\> \| none
min-height | 0 |  |  | \<length\> \| \<percentage\>
min-width | 0 |  |  | \<length\> \| \<percentage\>
opacity | 1.0 |  |  | \<number\>
orphans | 2 | Yes |  | \<integer\>
outline |  |  | hash | [ 'outline-color' \|\| 'outline-style' \|\| 'outline-width' ]
outline-color | invert |  |  | \<color\> \| invert
outline-style | none |  |  | [ none \| hidden \| dotted \| dashed \| solid \| double \| groove \| ridge \| inset \| outset ]
outline-width | medium |  |  | thin \| medium \| thick \| \<length\>
overflow | visible |  |  | visible \| hidden \| scroll \| auto
padding |  |  | box | \<padding-width\>{1,4}
padding-bottom | 0 |  |  | \<padding-width\>
padding-left | 0 |  |  | \<padding-width\>
padding-right | 0 |  |  | \<padding-width\>
padding-top | 0 |  |  | \<padding-width\>
page-break-after | auto |  |  | auto \| always \| avoid \| left \| right
page-break-before | auto |  |  | auto \| always \| avoid \| left \| right
page-break-inside | auto |  |  | avoid \| auto
pause |  |  |  | [ [\<time\> \| \<percentage\>]{1,2} ]
pause-after | 0 |  |  | \<time\> \| \<percentage\>
pause-before | 0 |  |  | \<time\> \| \<percentage\>
pitch | medium | Yes |  | \<frequency\> \| x-low \| low \| medium \| high \| x-high
pitch-range | 50 | Yes |  | \<number\>
play-during | auto |  |  | \<uri\> [ mix \|\| repeat ]? \| auto \| none
position | static |  |  | static \| relative \| absolute \| fixed
quotes | depends on user agent | Yes |  | [\<string\> \<string\>]+ \| none
richness | 50 | Yes |  | \<number\>
right | auto |  |  | \<length\> \| \<percentage\> \| auto
size | auto |  |  | \<length\>{1,2} \| auto \| [ \<page-size\> \|\| [ portrait \| landscape] ]
speak | normal | Yes |  | normal \| none \| spell-out
speak-header | once | Yes |  | once \| always
speak-numeral | continuous | Yes |  | digits \| continuous
speak-punctuation | none | Yes |  | code \| none
speech-rate | medium | Yes |  | \<number\> \| x-slow \| slow \| medium \| fast \| x-fast \| faster \| slower
stress | 50 | Yes |  | \<number\>
table-layout | auto |  |  | auto \| fixed
text-align | a nameless value that acts as 'left' if 'direction' is 'ltr', 'right' if 'direction' is 'rtl' | Yes |  | left \| right \| center \| justify
text-decoration | none |  |  | none \| [ underline \|\| overline \|\| line-through \|\| blink ]
text-indent | 0 | Yes |  | \<length\> \| \<percentage\>
text-transform | none | Yes |  | capitalize \| uppercase \| lowercase \| none
top | auto |  |  | \<length\> \| \<percentage\> \| auto
unicode-bidi | normal |  |  | normal \| embed \| bidi-override
vertical-align | baseline |  |  | baseline \| sub \| super \| top \| text-top \| middle \| bottom \| text-bottom \| \<percentage\> \| \<length\>
visibility | visible | Yes |  | visible \| hidden \| collapse
voice-family | depends on user agent | Yes |  | [\<generic-voice\> \| \<specific-voice\> ]\#
volume | medium | Yes |  | \<number\> \| \<percentage\> \| silent \| x-soft \| soft \| medium \| loud \| x-loud
white-space | normal | Yes |  | normal \| pre \| nowrap \| pre-wrap \| pre-line
widows | 2 | Yes |  | \<integer\>
width | auto |  |  | \<length\> \| \<percentage\> \| auto
word-spacing | normal | Yes |  | normal \| \<length\>
z-index | auto |  |  | auto \| \<integer\>


The above markdown table was produced with the following code snippet

```
use v6;
say <Name Default Inherit Type Synopsis>.join(' | ');
say ('---' xx 5).join(' | ');

my $css = (require CSS::Declarations).new;

for $css.properties(:all).sort -> $name {
    with $css.info($name) {
        my @type;
        @type.push: 'hash' if .children;
        @type.push: 'box' if .box;
        my $synopsis-escaped = .synopsis.subst(/<?before <[ < | > # ]>>/, '\\', :g); 

        say ($name,
             .default // '',
             .inherit ?? 'Yes' !! '',
             @type.join(','),
             $synopsis-escaped,
            ).join(' | ');
    }
}

```
