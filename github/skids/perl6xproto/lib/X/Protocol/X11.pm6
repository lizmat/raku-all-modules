use X::Protocol;

unit class X::Protocol::X11 is X::Protocol;

=NAME X::Protocol::X11 - Perl6 Exception class for X11 Protocol Errors

=begin SYNOPSIS
=begin code

    use X::Protocol::X11;

    X::Protocol::X11.new(:status(5), :bad_value(0x28000004),
                         :major_opcode<ChangeProperty(18)>).throw
    # Dies with:
    #

=end code
=end SYNOPSIS

=begin DESCRIPTION

The C<X::Protocol::X11> contains adjustments to X::Protocol for the
X11 protocol.  This includes standard human-readable strings, and
use of additional fields in X11 protocol structures.

=end DESCRIPTION

has $.status;
method code is rw { $!status }
has $.sequence;
has $.bad_value;
has $.major_opcode;

method protocol { 'X11' }

method bad_value_name {
    :{  2    => 'Value',
        3    => 'Window',
        4    => 'Pixmap',
        5    => 'Atom',
        6    => 'Cursor',
        7    => 'Font',
        9    => 'Drawable',
        12   => 'Colormap',
        13   => 'Context',
        14   => 'ID'
    }
}

method codes {
    :{
        1    => 'Bad Request',
        2    => 'Bad Value',
        3    => 'Bad Window',
        4    => 'Bad Pixmap',
        5    => 'Bad Atom',
        6    => 'Bad Cursor',
        7    => 'Bad Font',
        8    => 'No match',
        9    => 'Bad Drawable',
        10   => 'No access',
        11   => 'Alloc failed',
        12   => 'Bad Colormap',
        13   => 'Bad Graphics Context',
        14   => 'Bad IDChoice',
        15   => 'Bad name',
        16   => 'Incorrect Length',
        17   => 'Implementation Error'
    }
}

# TDB
# method severity { }

method message {
    ("$.protocol protocol error: {self.codes{self.status}}",
       "for request #{$.sequence.Str.fmt('0x%x')}",
       "(Opcode $.major_opcode)",
       (self.bad_value_name{self.status}:exists ?? 
        self.bad_value_name{self.status} ~ $.bad_value.Str.fmt("(0x%x)") !! |()),
       ).join(" ");
}

method gist {
    ("{self.codes{self.status}}",
       (self.bad_value_name{self.status}:exists ?? 
        self.bad_value_name{self.status} ~ $.bad_value.Str.fmt("(0x%x)") !! |()),
       ).join(" ");
}

=AUTHOR Brian S. Julin

=begin COPYRIGHT

Copyright (c) 2016 Brian S. Julin. All rights reserved.

=end COPYRIGHT

=begin LICENSE
This program is free software; you can redistribute it and/or modify
it under the terms of the Perl Artistic License 2.0.
=end LICENSE

=SEE-ALSO C<Exception::(pm3) X11(pm3)>
