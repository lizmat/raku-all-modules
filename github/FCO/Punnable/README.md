[![Build Status](https://travis-ci.org/FCO/Punnable.svg?branch=master)](https://travis-ci.org/FCO/Punnable)
## Usage

```
$ perl6 -Ilib -MPunnable -e 'role R {method r {...}}; make-punnable(R); my $or = R.new; say $or; $or.r'
R.new
Stub code executed
  in block <unit> at -e line 1

Actually thrown at:
  in block <unit> at -e line 1
```
