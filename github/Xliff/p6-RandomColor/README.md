# p6-RandomColor
A port of the RandomColor JavaScript library for Perl6.

# [Random Color](https://randomcolor.lllllllllllllllll.com)

A tiny script for generating attractive random colors.

## Options

You can pass an options object to influence the type of color it produces. The options object accepts the following properties:

```hue``` – Controls the hue of the generated color. You can pass a string representing a color name: ```red```, ```orange```, ```yellow```, ```green```, ```blue```, ```purple```, ```pink``` and ```monochrome``` are currently supported. If you pass a  hexidecimal color string such as ```#00FFFF```, randomColor will extract its hue value and use that to generate colors.

```luminosity``` – Controls the luminosity of the generated color. You can specify a string containing ```bright```, ```light``` or ```dark```.

```count``` – An integer which specifies the number of colors to generate.

```seed``` - An integer or string which when passed will cause randomColor to return the same color each time.

```format``` – A string which specifies the format of the generated color. Possible values are ```rgb```, ```rgba```, ```rgbArray```, ```hsl```, ```hsla```, ```hslArray``` and ```hex``` (default).

```alpha``` – A decimal between 0 and 1. Only relevant when using a format with an alpha channel (```rgba``` and ```hsla```). Defaults to a random value.

## Examples

```perl6

# Returns a hex code for an attractive color
RandomColor.new.list;

# Returns an array of ten green colors
RandomColor.new(
   count => 10,
   hue => 'green'
}).list;

# Returns a hex code for a light blue
RandomColor.new(
   luminosity => 'light',
   hue => 'blue'
).list;

# Returns a hex code for a 'truly random' color
RandomColor(
   luminosity => 'random',
   hue  => 'random'
).list;

# Returns a bright color in RGB
RandomColor.new(
   luminosity => 'bright',
   format => 'rgb' # e.g. 'rgb(225,200,20)'
).list;

# Returns a dark RGB color with random alpha
RandomColor.new(
   luminosity => 'dark',
   format => 'rgba' # e.g. 'rgba(9, 1, 107, 0.6482447960879654)'
});

# Returns a dark RGB color with specified alpha
RandomColor.new(
   luminosity => 'dark',
   format => 'rgba',
   alpha => 0.5 # e.g. 'rgba(9, 1, 107, 0.5)',
);

# Returns a light HSL color with random alpha
RandomColor.new(
   luminosity => 'light',
   format => 'hsla' # e.g. 'hsla(27, 88.99%, 81.83%, 0.6450211517512798)'
);

```

For more information, see the [homepage](https://randomcolor.lllllllllllllllll.com/)
