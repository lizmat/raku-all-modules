use v6;

=head1 TITLE
IO::String
=head1 SYNOPSIS
=begin code
    use IO::String;

    my $buffer = IO::String.new;
    {
        my $*OUT = $buffer;
        say "hello";
    }
    say ~$buffer; # T<hello>

=end code
=begin head1
DESCRIPTION

Sometimes you want to use code that deals with files (or other
file-like objects), but you don't want to mess around with creating
temporary files.  This includes uses like APIs that for some reason
don't accept strings as well as files as targets, mocking I/O,
or capturing output written to the terminal.  That's why this module
exists.  Loosely based on Perl 5's IO::String.

=end head1

=begin head1
TODO

=item Input as well as output
=item Handle encodings
=end head1


#| An L<IO::Handle> implementation that writes to memory.
class IO::String:ver<0.1.0>:auth<hoelzro> is IO::Handle {
    has @.contents;

    method print(*@what) {
        @.contents.push: @what.join('');
    }

    method print-nl {
        self.print($.nl);
    }

    #| Returns, as a string, everything that's been written to
    #| this object.
    method Str { @.contents.join('') }
}
