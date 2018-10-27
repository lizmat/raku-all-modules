[![Build Status](https://travis-ci.org/tmtvl/Zodiac-Chinese.svg?branch=master)](https://travis-ci.org/tmtvl/Zodiac-Chinese)
# NAME

Zodiac::Chinese - Generate Chinese Zodiac

# SYNOPSIS

```Perl6
use Zodiac::Chinese;
my ChineseZodiac $zodiac .= new(DateTime.new(year => $year, month => $month));
```

# DESCRIPTION

The Zodiac::Chinese module provides a ChineseZodiac class, which generates a Chinese zodiac sign from a given date. It currently doesn't account for differences between the lunar calendar and Gregorian calendar, so signs generated for late January or early February may be off.

# AUTHOR

Tim Van den Langenbergh <tmt_vdl@gmx.com>

Source can be located at: https://github.com/tmtvl/Chinese-Zodiac. Comments and Pull Requests are welcome.

# COPYRIGHT AND LICENSE

Original author: Lady_Aleena. Re-imagined from Perl 5.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
