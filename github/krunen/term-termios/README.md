Term::termios
============

termios routines for Rakudo Perl 6

    use Term::termios;
    
    # Save the previous attrs
    my $saved_termios := Term::termios.new(fd => 1).getattr;
    
    # Get the existing attrs in order to modify them
    my $termios := Term::termios.new(fd => 1).getattr;
    
    # Set the tty to raw mode
    $termios.makeraw;
    
    # You could also do the same in the old-fashioned way
    $termios.unset_iflags(<BRKINT ICRNL ISTRIP IXON>);
    $termios.set_oflags(<ONLCR>);
    $termios.set_cflags(<CS8>);
    $termios.unset_lflags(<ECHO ICANON IEXTEN ISIG>);
    
    # Set the modified atributes, delayed until the buffer is emptied
    $termios.setattr(:DRAIN);
    
    # Loop on characters from STDIN
    loop {
        my $c = $*IN.getc;
        print "got: " ~ $c.ord ~ "\r\n";
        last if $c eq 'q';
    }
    
    # Restore the saved, previous attributes before exit
    $saved_termios.setattr(:DRAIN);

See the manpage termios(3) for information about the flags.
