#Slang::Roman

Allow your integers to be Roman numerals.

* my Int $r = 0rMMXVI; # $r == 2016
* Eventually: printf "%{roman}d", $r; # MMXVI

What it doesn't do [yet]

* printf

#Use

```perl6
use Slang::Roman;

say 0rXIV;
```

```Output:

14
```

##Better Examples

Check out ```t/01_basic.t```
