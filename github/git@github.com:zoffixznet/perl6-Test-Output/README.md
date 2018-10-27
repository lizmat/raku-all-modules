[![Build Status](https://travis-ci.org/zoffixznet/perl6-Test-Output.svg)](https://travis-ci.org/zoffixznet/perl6-Test-Output)

# NAME

Test::Output - Test the output to STDOUT and STDERR your program generates

# TABLE OF CONTENTS
- [NAME](#name)
- [SYNOPSIS](#synopsis)
- [DESCRIPTION](#description)
- [EXPORTED SUBROUTINES](#exported-subroutines)
    - [`is` Tests](#is-tests)
        - [`output-is`](#output-is)
        - [`stdout-is`](#stdout-is)
        - [`stderr-is`](#stderr-is)
    - [`like` Tests](#like-tests)
        - [`output-like`](#output-like)
        - [`stdout-like`](#stdout-like)
        - [`stderr-like`](#stderr-like)
    - [Output Capture](#output-capture)
        - [`output-from`](#output-from)
        - [`stdout-from`](#stdout-from)
        - [`stderr-from`](#stderr-from)
- [REPOSITORY](#repository)
- [BUGS](#bugs)
- [AUTHOR](#author)
- [LICENSE](#license)

# SYNOPSIS

```perl6
    use Test;
    use Test::Output;

    my &test-code = sub {
        say 42;
        note 'warning!';
        say "After warning";
    };

    # Test code's output using exact match ('is')
    output-is   &test-code, "42\nwarning!\nAfter warning\n", 'testing output';
    stdout-is   &test-code, "42\nAfter warning\n",  'testing stdout';
    stderr-is   &test-code, "warning!\n", 'testing stderr';

    # Test code's output using regex ('like')
    output-like &test-code, /42.+warning.+After/, 'testing output (regex)';
    stdout-like &test-code, /42/, 'testing stdout (regex)';
    stderr-like &test-code, /^ "warning!\n" $/, 'testing stderr (regex)';

    # Just capture code's output and do whatever you want with it
    is output-from( &test-code ), "42\nwarning!\nAfter warning\n";
    is stdout-from( &test-code ), "42\nAfter warning\n";
    is stderr-from( &test-code ), "warning!\n";

```

# DESCRIPTION

This module allows you to capture the output (STDOUT/STDERR/BOTH) of a
piece of code and evaluate it for some criteria.

# EXPORTED SUBROUTINES

## `is` Tests

### `output-is`

![][sub-signature]
```perl6
    sub output-is (&code, Str $expected, Str $desc? );
```

![][sub-usage-example]
```perl6
    output-is { say 42; note 43; say 44 }, "42\n43\n44\n",
        'Merged output from STDOUT/STDERR looks fine!';
```

Uses `is` function from `Test` module to test whether the combined
STDERR/STDOUT output from a piece of code matches the given string. Takes
an **optional** test description.

----

### `stdout-is`

![][sub-signature]
```perl6
    sub stdout-is (&code, Str $expected, Str $desc? );
```

![][sub-usage-example]
```perl6
    stdout-is { say 42; note 43; say 44 }, "42\n44\n", 'STDOUT looks fine!';
```

Same as [`output-is`](#output-is), except tests STDOUT only.

----

### `stderr-is`

![][sub-signature]
```perl6
    sub stderr-is (&code, Str $expected, Str $desc? );
```

![][sub-usage-example]
```perl6
    stderr-is { say 42; note 43; say 44 }, "43\n", 'STDERR looks fine!';
```

Same as [`output-is`](#output-is), except tests STDERR only.

----

## `like` Tests

### `output-like`

![][sub-signature]
```perl6
    sub output-like (&code, Regex $expected, Str $desc? );
```

![][sub-usage-example]
```perl6
    output-like { say 42; note 43; say 44 }, /42 .+ 43 .+ 44/,
        'Merged output from STDOUT/STDERR matches the regex!';
```

Uses `like` function from `Test` module to test whether the combined
STDERR/STDOUT output from a piece of code matches the given `Regex`. Takes
an **optional** test description.

----

### `stdout-like`

![][sub-signature]
```perl6
    sub stdout-like (&code, Regex $expected, Str $desc? );
```

![][sub-usage-example]
```perl6
    stdout-like { say 42; note 43; say 44 }, /42 \n 44/,
        'STDOUT matches the regex!';
```

Same as [`output-like`](#output-like), except tests STDOUT only.

----

### `stderr-like`

![][sub-signature]
```perl6
    sub stderr-like (&code, Regex $expected, Str $desc? );
```

![][sub-usage-example]
```perl6
    stderr-like { say 42; note 43; say 44 }, /^ 43\n $/,
        'STDERR matches the regex!';
```

Same as [`output-like`](#output-like), except tests STDERR only.

----

## Output Capture

### `output-from`

![][sub-signature]
```perl6
    sub output-from (&code) returns Str;
```

![][sub-usage-example]
```perl6
    my $output = output-from { say 42; note 43; say 44 };
    say "Captured $output from our program!";

    is $output, "42\nwarning!\nAfter warning\n",
        'captured merged STDOUT/STDERR look fine';
```

Captures and returns merged STDOUT/STDERR output from the given piece of code.

----

### `stdout-from`

![][sub-signature]
```perl6
    sub stdout-from (&code) returns Str;
```

![][sub-usage-example]
```perl6
    my $stdout = stdout-from { say 42; note 43; say 44 };
    say "Captured $stdout from our program!";

    is $stdout, "42\nAfter warning\n", 'captured STDOUT looks fine';
```

Same as [`output-from`](#output-from), except captures STDOUT only.

----

### `stderr-from`

![][sub-signature]
```perl6
    sub stderr-from (&code) returns Str;
```

![][sub-usage-example]
```perl6
    my $stderr = stderr-from { say 42; note 43; say 44 };
    say "Captured $stderr from our program!";

    is $stderr, "warning\n", 'captured STDERR looks fine';
```

Same as [`output-from`](#output-from), except captures STDERR only.

----

# REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Test-Output

# BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Test-Output/issues

# AUTHOR

Zoffix Znet (http://zoffix.com/)

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

[sub-signature]: _chromatin/sub-signature.png
[sub-usage-example]: _chromatin/sub-usage-example.png