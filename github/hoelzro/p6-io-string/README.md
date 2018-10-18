# TITLE

IO::String

# SYNOPSIS

```perl6
        use IO::String;

        my $buffer = IO::String.new;
        {
            my $*OUT = $buffer;
            say "hello";
        }
        say ~$buffer; # hello
```


# DESCRIPTION

Sometimes you want to use code that deals with files (or other file-like objects), but you don't want to mess around with creating temporary files. This includes uses like APIs that for some reason don't accept strings as well as files as targets, mocking I/O, or capturing output written to the terminal. That's why this module exists. Loosely based on Perl 5's IO::String.

# TODO

  * Input as well as output
  * Handle encodings
