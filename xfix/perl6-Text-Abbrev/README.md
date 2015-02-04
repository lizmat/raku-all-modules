Text::Abbrev - create an abbreviation table from a list.

# Synopsis

```perl
use Text::Abbrev;

# You can say "y" or "n" too
my $option = abbrev(<yes no>){lc prompt "Y/N? "};
if $option {
    say "You have said {$option.titlecase}.";
}
else {
    say "Sorry, unknown option.";
}
```

# Functions

## `abbrev`

The only function exported by this module which will return unambigous
truncations of every option in list. For example, when you will call
`abbrev <break brick>` you will get following hash.

```perl
(
    # break
    "break" => "break",
    "brea"  => "break",
    "bre"   => "break",
    # brick
    "brick" => "brick",
    "bric"  => "brick",
    "bri"   => "brick",
)
```

# Author

GlitchMr <glitchmr@myopera.com>
