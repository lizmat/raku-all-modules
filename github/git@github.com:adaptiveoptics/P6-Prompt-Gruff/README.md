# NAME

Prompt::Gruff - uncomplicated yet functional and terse user input

# SYNOPSIS

```perl
    use Prompt::Gruff::Export;

    # Input is required by default
    my $name = prompt-for('Enter name (required): ');

    # You can make it not so
    my $mail = prompt-for('Email: ', required => False);

    # Multi-line is terminated with a hideous but effective ctrl_d
    my $desc = prompt-for('Description (end with ^D)', multi-line => True);

    # Make your user verify their input as many times as you like
    my $haha = prompt-for('Complicated thing: ', :verify(4));

    # For purely object-oriented inteface, just omit the
    # "::Export" bit in your use statement.

    use Prompt::Gruff;

    # Prompt for Name and make them verify everything prompted for with that
    # object henceforth until the verify attribute is changed.

    my $gruff = Prompt::Gruff.new;
    $gruff->verify(2);
    my $name  = $gruff.prompt-for('Name: ');
```

# DESCRIPTION

Quick and dirty (and simple (for us)) user prompting.

If you don't want to learn anything new, this module's for you.

Supports crude multi-line input and re-type verification, along with
default values.

You can also define arbitrary regexes for fun.

# ATTRIBUTES

## required (default: True)

The "required" attribute, True by default, will forever hound the user
until they respond with something or destroy the machine.

## multi-line (default: False)

The "multi-line" argument, False by default, opens up STDIN from the
user so that they may continuously type all they want until they enter
a ^D character to terminate their input, or they manage to exhaust the
computer's memory.

Multi-line input places the prompt on a line of its own, then starts
the input below.

## verify (UInt) (default: 1)

Takes a number, and forces the user to type in their input that many
times!

If it's set to more than 1, then each time they re-enter it, their
input will be verified against the last thing they entered -- and if
they didn't enter it in exactly the same, they get asked again.

I strongly recommend a verify setting of at least 5. For
everything. All the time.

## regex (Str)

You can pass a string (without the enclosing '/'s) representing a
regex and your user will be constrained to your exacting
specifications.

## default (Str)

Setting or passing in a 'default' string will allow your user to just
hit enter without having to look at anything or even think in the
slightest.

They can just pound the enter key, and your pre-made default string
will be used.

## yn (Bool)

If your user can handle choosing between yes or no questions and
typing a 'y' or an 'n' on the keyboard, setting :yn True might be nice.

You can choose a :default value too.

The return value is True or False.

## no-escape (Bool) (default: True)

Trap your user in an endless loop until they satisfactorily bend to
your will. This is the default.

:no-escape(False) will cause errors to fail out instead of re-prompting.

# METHODS

## prompt-for ($prompt_text,
              [Bool :required (True)],
              [Bool :multi-line (False)]),
              [Str  :regex],
              [Str  :default],
              [Bool :yn],
              [Bool :no-escape],
              [UInt :verify (1)],
			  );

Takes the required positional $prompt_text string as the user prompt and
returns what the user decided to input.

Arguments passed to `prompt-for()` will override their corresponding
attributes.

# AUTHOR

Mark Rushing <mark@orbislumen.net>

# LICENSE

This is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.
