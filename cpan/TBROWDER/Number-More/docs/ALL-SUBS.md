# Subroutines Exported by the `:ALL` Tag

### Contents

| Col 1 | Col 2 | Col 3 |
| --- | --- | --- |
| [bin2dec](#bin2dec) | [bin2hex](#bin2hex) | [bin2oct](#bin2oct) |
| [dec2bin](#dec2bin) | [dec2hex](#dec2hex) | [dec2oct](#dec2oct) |
| [hex2bin](#hex2bin) | [hex2dec](#hex2dec) | [hex2oct](#hex2oct) |
| [oct2bin](#oct2bin) | [oct2dec](#oct2dec) | [oct2hex](#oct2hex) |
| [rebase](#rebase) |  |  |


### sub bin2dec
- Purpose: Convert a binary number (string) to a decimal number.
- Params : Binary number (string), desired length (optional).
- Returns: Decimal number (or string).
```perl6
sub bin2dec(Str:D $bin where &binary,
            UInt $len = 0
            --> Cool) is export(:bin2dec) {#...}
```
### sub bin2hex
- Purpose: Convert a binary number (string) to a hexadecimal number (string).
- Params : Binary number (string), desired length (optional), prefix (optional), lower-case (optional).
- Returns: Hexadecimal number (string).
```perl6
sub bin2hex(Str:D $bin where &binary,
            UInt $len = 0,
            Bool :$prefix = False,
            Bool :$LC = False
	    --> Str) is export(:bin2hex) {#...}
```
### sub bin2oct
- Purpose: Convert a binary number (string) to an octal number (string).
- Params : Binary number (string), desired length (optional), prefix (optional).
- Returns: Octal number (string).
```perl6
sub bin2oct($bin where &binary,
            UInt $len = 0,
            Bool :$prefix = False
            --> Str) is export(:bin2oct) {#...}
```
### sub dec2bin
- Purpose: Convert a non-negative integer to a binary number (string).
- Params : Non-negative decimal number, desired length (optional), prefix (optional).
- Returns: Binary number (string).
```perl6
sub dec2bin($dec where &decimal,
            UInt $len = 0,
            :$prefix = False
            --> Str) is export(:dec2bin) {#...}
```
### sub dec2hex
- Purpose: Convert a non-negative integer to a hexadecimal number (string).
- Params : Non-negative decimal number, desired length (optional), prefix (optional), lower-case (optional).
- Returns: Hexadecimal number (string).
```perl6
sub dec2hex($dec where &decimal,
            UInt $len = 0,
            Bool :$prefix = False,
            Bool :$LC = False
	    --> Str) is export(:dec2hex) {#...}
```
### sub dec2oct
- Purpose: Convert a non-negative integer to an octal number (string).
- Params : Decimal number, desired length (optional), prefix (optional).
- Returns: Octal number (string).
```perl6
sub dec2oct($dec where &decimal,
            UInt $len = 0,
            Bool :$prefix = False
            --> Cool) is export(:dec2oct) {#...}
```
### sub hex2bin
- Purpose: Convert a non-negative hexadecimal number (string) to a binary string.
- Params : Hexadecimal number (string), desired length (optional), prefix (optional).
- Returns: Binary number (string).
```perl6
sub hex2bin(Str:D $hex where &hexadecimal,
            UInt $len = 0,
            Bool :$prefix = False
            --> Str) is export(:hex2bin) {#...}
```
### sub hex2dec
- Purpose: Convert a non-negative hexadecimal number (string) to a decimal number.
- Params : Hexadecimal number (string), desired length (optional).
- Returns: Decimal number (or string).
```perl6
sub hex2dec(Str:D $hex where &hexadecimal,
            UInt $len = 0
            --> Cool) is export(:hex2dec) {#...}
```
### sub hex2oct
- Purpose: Convert a hexadecimal number (string) to an octal number (string).
- Params : Hexadecimal number (string), desired length (optional), prefix (optional).
- Returns: Octal number (string).
```perl6
sub hex2oct($hex where &hexadecimal, UInt $len = 0,
            Bool :$prefix = False
            --> Str) is export(:hex2oct) {#...}
```
### sub oct2bin
- Purpose: Convert an octal number (string) to a binary number (string).
- Params : Octal number (string), desired length (optional), prefix (optional).
- Returns: Binary number (string).
```perl6
sub oct2bin($oct where &octal, UInt $len = 0,
            Bool :$prefix = False
            --> Str) is export(:oct2bin) {#...}
```
### sub oct2dec
- Purpose: Convert an octal number (string) to a decimal number.
- Params : Octal number (string), desired length (optional).
- Returns: Decimal number (or string).
```perl6
sub oct2dec($oct where &octal, UInt $len = 0
            --> Cool) is export(:oct2dec) {#...}
```
### sub oct2hex
- Purpose: Convert an octal number (string) to a hexadecimal number (string).
- Params : Octal number (string), desired length (optional), prefix (optional), lower-case (optional).
- Returns: Hexadecimal number (string).
```perl6
sub oct2hex($oct where &octal, UInt $len = 0,
            Bool :$prefix = False,
            Bool :$LC = False
            --> Str) is export(:oct2hex) {#...}
```
### sub rebase
- Purpose: Convert any number (integer or string) and base (2..62) to a number in another base (2..62).
- Params : Number (string), desired length (optional), prefix (optional), lower-case (optional).
- Returns: Desired number (decimal or string) in the desired base.
```perl6
sub rebase($num-i,
           $base-i where &all-bases,
           $base-o where &all-bases,
           UInt $len = 0,
           Bool :$prefix = False,
           Bool :$LC = False
           --> Cool) is export(:baseM2baseN) {#...}
```
