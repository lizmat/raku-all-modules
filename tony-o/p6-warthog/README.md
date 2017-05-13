# WELCOME TO WARTHOG

I does build decisions.

## Usage

```perl6
use System::Query;
use JSON::Fast;

my $json      = from-json("build.json".IO.slurp);
my $decisions = system-collapse($json);

qw<...>;
```

## Input

Calling `parse` with the following JSON will run through and choose what it thinks is the best options in the environment.

```json
{
  "nested": {
    "test": "data"
  },
  "nested2": {
    "test2": "data2"
  },
  "options": {
    "run": {
      "by-distro.name": {
        "macosx": {
          "by-distro.version": {
            "10.0+": "10make",
            "9.0+": "9make",
            "8.0+": "8make"
          }
        },
        "win32": {
          "by-distro.version": {
            "6+": "6winmake",
            "5+": "5winmake" 
          }
        },
        "": "null-make"
      }
    }
  },
  "default-test": {
    "second-test": "string-val, no decisions",
    "first-test": {
      "by-distro.name": {
        "": "default-option1"
      }
    }
  }
}
```

## Output

This is the result of the parse; notice that the distro/kernel/etc queries collapse to show the decisions based on variables.

```perl6
{
  default-test => {
    first-test  => "default-option1".Str,
    second-test => "string-val, no decisions".Str,
  },
  nested       => {
    test => "data".Str,
  },
  nested2      => {
    test2 => "data2".Str,
  },
  options      => {
    run => "10make".Str,
  },
}
```

