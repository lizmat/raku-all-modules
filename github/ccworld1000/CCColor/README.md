## [CCColor](https://github.com/ccworld1000/CCColor)
    Simple and flexible color color conversion module for Perl 6 , 
    easy-to-use simple learning.


## HEX Color (use CCColor)

![colors](https://raw.githubusercontent.com/ccworld1000/CCColor/master/doc/screenshot/colors.svg?sanitize=true)



## See test

```perl
use CCColor;

my @list =
(
"   #FFFEA963 ",
"   #FF FE A9 63 ",
"   #FF # FE #   A9 #     63 ",
"   #",
"   #1",
"   #123",
"   #FFH",
"   #FHF",
"   #1234",
"   #12345",
"   #FFEE5",
"   #FFEE56",
"   #FFEE56A",
"   #FFEE56AH",
"   #FFEE56AA",
"   #FFEE56AA11",
"   #FFEE56AAFF11",
);

for @list -> $color {
  my ($r, $g, $b, $a) = hex2rgba($color);
  say "$r, $g, $b, $a";
}
```


Call test/test.p6

![test](https://raw.githubusercontent.com/ccworld1000/CCColor/master/doc/screenshot/test.png)



## Local installation and unloading

    zef install .
    zef uninstall CCColor

## Network install
    zef update
    zef install CCColor


