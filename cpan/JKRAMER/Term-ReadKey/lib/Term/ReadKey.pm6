
module Term::ReadKey:ver<0.0.1> {
  use Term::termios;
  use NativeCall;

  sub getchar returns int32 is native { * }

  sub with-termios(Callable:D $fn, Bool:D :$echo = True --> Str) {
    my $original-flags := Term::termios.new(:fd($*IN.native-descriptor)).getattr;
    my $flags := Term::termios.new(:fd($*IN.native-descriptor)).getattr;

    $flags.unset_lflags('ICANON');
    $flags.unset_lflags('ECHO') unless $echo;
    $flags.setattr(:NOW);

    my $result = $fn();

    $original-flags.setattr(:NOW);

    return $result;
  }

  sub read-character returns Str {
    my Buf $buf .= new;
    my Str $ch = Nil;

    loop {
      # Catch decoding errors and read more bytes until we have a
      # complete/valid UTF-8 sequence.
      CATCH { default { next } }

      $_ != -1 and $ch = $buf.append($_).decode with getchar;

      last;
    }

    return $ch;
  }

  sub read-key(Bool:D :$echo = True --> Str) is export {
    return with-termios(&read-character, :$echo);
  }

  sub key-pressed(Bool:D :$echo = True --> Supply) is export {
    my Supplier $supplier .= new;

    my $done = False;
    my $supply = $supplier.Supply.on-close: { $done = True };

    start {
      with-termios(
        sub {
          until $done {
            my $ch = read-character;

            last if $ch ~~ Nil;

            $supplier.emit($ch);
          }
        },
        :$echo
      );
    }

    return $supply;
  }
}

=begin pod

=head1 NAME

Term::ReadKey

=head1 DESCRIPTION

Read single (unbuffered) keys from terminal.

=head1 SYNOPSIS

  use Term::ReadKey;

  react {
    whenever key-pressed(:!echo) {
      given .fc {
        when 'q' { done }
        default { .uniname.say }
      }
    }
  }

=head1 FUNCTIONS

=head2 read-key(Bool :$echo = True --> Str)

Reads one unbuffered (unicode) character from STDIN and returns it as Str or
Nil if nothing could be read. By default the typed character will be echoed to
the terminal unless C<<:!echo>> is passed as argument.

=head2 key-pressed(Bool :$echo = True --> Supply)

Returns a supply that emits characters as soon as they're typed (see example in
SYNOPSIS).  The named argument C<<:$echo>> can be used to enable/disable
echoing of the character (on by default).

=head1 AUTHOR

Jonas Kramer <jkramer@mark17.net>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Jonas Kramer.

This library is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod
