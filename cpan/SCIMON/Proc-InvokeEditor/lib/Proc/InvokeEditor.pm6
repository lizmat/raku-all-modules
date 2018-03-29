use v6.c;
use File::Temp;

unit class Proc::InvokeEditor:ver<0.0.2>:auth<Simon Proctor "simon.proctor@gmail.com">;

=begin pod

=head1 NAME

Proc::InvokeEditor - Edit strings in an external editor. 

=head1 SYNOPSIS

    use Proc::InvokeEditor;

    my $editor = Proc::InvokerEditor( :editors( [ "/usr/bin/emacs" ] ) );
    my $text = $editor->edit( "Edit text below\n" );

=head1 DESCRIPTION

Proc::InvokeEditor is a port of the Perl5 module of the same name. The API is intended to be as close as possible to the original.
Later versions of the module will add additional functionality

=head1 METHODS

=end pod

sub DEFAULT_EDITORS() {
    Array[Str].new( |( <<VISUAL EDITOR>>.grep( { defined %*ENV{$_} } ).map( { %*ENV{$_} } ) ),
                    '/usr/bin/vi', '/bin/vi',
                    '/usr/bin/emacs', '/bin/emacs',
                    '/bin/ed', );
}
    
has Str @!editors;

submethod BUILD( :@editors = DEFAULT_EDITORS ) {
    @!editors = @editors;
}

=begin pod

=head2 new( :editors )

Create a new Proc::InvokeEditor object, takes an optional list of paths to editors to attempt to use.
Note: currently all paths given must be complete paths, the system doesn't attempt an checking of the path environment for files.

Editor strings can include command line arguments to pass and should expect to take a filename as there final argument.
                                                            
=head2 editors()

Getter / Setter for the array of editors accepts a postional arguments or an postitional and sets the list of editors to that.
If called with no values gives the current list in the order they will be checked.

Can be called as a getter as a class method but will error if you try and set the editors as a class method.
                                                            
=end pod

multi method editors(Proc::InvokeEditor:U: --> Array[Str]) {
    DEFAULT_EDITORS;
}

multi method editors(Proc::InvokeEditor:U: *@ --> Array[Str]) {
    fail("Can't edit editor list in class, perhaps you'd like to create an object?");
}

multi method editors(Proc::InvokeEditor:D: --> Array[Str]) {
    @!editors;
}

multi method editors(Proc::InvokeEditor:D: +@new-editors where { $_.all ~~ Str } --> Array[Str]) {
    @!editors = @new-editors;
}

=begin pod

=head2 first_usable()

Class or object method. Returns an array of executable path string and then optional parameters for the editor the system will use when edit() is called.

=end pod

multi method first_usable(Proc::InvokeEditor:D: --> Array[Str]) {
    find-usable( @!editors );
}

multi method first_usable(Proc::InvokeEditor:U: --> Array[Str]) {
    find-usable( DEFAULT_EDITORS );
}

my sub find-usable( Str @possible --> Array[Str] ) {
    my Str @out;
    for @possible -> Str $test {
        my ( $test-file, @args ) = $test.split( / \s / );

        if $test-file.IO ~~ :e & :x {
            @out.push($test-file, |@args);
            return @out;
        }
    }
    fail("Unable to find a useable editor in : {@possible.gist}");
}

=begin pod

=head2 edit( $string )

Class or object method, takes a string or list of strings. Fires up the external editor specifed by first_usable() and waits for it to complete then returns the updated result.

=end pod

multi method edit(Proc::InvokeEditor:U: *@lines --> Str ) {
    Proc::InvokeEditor.new().edit( @lines.join("\n") );
}

multi method edit(Proc::InvokeEditor:U: Str() $text --> Str ) {
    Proc::InvokeEditor.new().edit( $text );
}

multi method edit(Proc::InvokeEditor:D: *@lines --> Str ) {
    self.edit( @lines.join("\n") );
}

multi method edit(Proc::InvokeEditor:D: Str() $text --> Str ) {
    my ( $file, $handle ) = tempfile;
    
    $handle.spurt( $text );
    $handle.close();
    
    my $proc = Proc::Async.new( |self.first_usable() , $file );
    
    await $proc.start();

    $file.IO.slurp;
}

=begin pod

=head1 AUTHOR

Simon Proctor <simon.proctor@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Simon Proctor

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
