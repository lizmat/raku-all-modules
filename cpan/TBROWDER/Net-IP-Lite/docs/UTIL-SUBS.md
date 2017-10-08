# title: Additional Subroutines Exported with Named Parameter ':util'

### bin2dec
- Purpose : Convert a binary number (string) to a decimal number
- Params  : Binary number (string), desired length (optional)
- Returns : Decimal number (or string)
```perl6
sub bin2dec(Str:D $bin where &binary, UInt $len = 0)
  returns Cool is export(:util) {#...}
```

### bin2hex
- Purpose : Convert a binary number (string) to a hexadecimal number (string)
- Params  : Binary number (string), desired length (optional)
- Returns : Hexadecimal number (string)
```perl6
sub bin2hex(Str:D $bin where &binary, UInt $len = 0)
  returns Str is export(:util) {#...}
```

### count-substrs
- Purpose : Count instances of a substring in a string
- Params  : String, Substring
- Returns : Number of substrings found
```perl6
sub count-substrs(Str:D $ip, Str:D $substr)
  returns UInt is export(:util) {#...}
```

### dec2bin
- Purpose : Convert a positive integer to a binary number (string)
- Params  : Positive decimal number, desired length (optional)
- Returns : Binary number (string)
```perl6
sub dec2bin(UInt $dec, UInt $len = 0)
  returns Str is export(:util) {#...}
```

### dec2hex
- Purpose : Convert a positive integer to a hexadecimal number (string)
- Params  : Positive decimal number, desired length (optional)
- Returns : Hexadecimal number (string)
```perl6
sub dec2hex(UInt $dec, UInt $len = 0)
  returns Str is export(:util) {#...}
```

### hex2bin
- Purpose : Convert a positive hexadecimal number (string) to a binary string
- Params  : Hexadecimal number (string), desired length (optional)
- Returns : Binary number (string)
```perl6
sub hex2bin(Str:D $hex where &hexadecimal, UInt $len = 0)
  returns Str is export(:util) {#...}
```

### hex2dec
- Purpose : Convert a positive hexadecimal number (string) to a decimal number
- Params  : Hexadecimal number (string), desired length (optional)
- Returns : Decimal number (or string)
```perl6
sub hex2dec(Str:D $hex where &hexadecimal, UInt $len = 0)
  returns Cool is export(:util) {#...}
```

### hexchar2bin
- Purpose : Convert a single hexadecimal character to a binary string
- Params  : Hexadecimal character
- Returns : Binary string
```perl6
sub hexchar2bin(Str:D $hexchar where &hexadecimalchar)
  is export(:util) {#...}
```

### hexchar2dec
- Purpose : Convert a single hexadecimal character to a decimal number
- Params  : Hexadecimal character
- Returns : Decimal number
```perl6
sub hexchar2dec(Str:D $hexchar is copy where &hexadecimalchar)
  returns UInt is export(:util) {#...}
```
