#!perl6 
 
use v6; 
use lib 'lib'; 
use lib 't'; 
 
use Test; 
 
plan 22; 

use Archive::SimpleZip::Utils;

  # input         output
    # .             '.'
    # ./a           a
    # ./a/b         a/b
    # ./a/b/        a/b
    # a/b/          a/b
    # /a/b/         a/b
    # c:\a\b\c.doc  a/b/c.doc      # on Windows
    # "i/o maps:whatever"   i_o maps/whatever   # on Macs

    #is Archive::SimpleZip::canonical-name("./a"), "a";

{

    my @tests = ( <fred           fred>,
                  </fred          fred>,
                  </fred/joe      fred/joe>,
                  </fred//joe     fred/joe>,
                  </fred/joe/     fred/joe/>,
                  </fred/./joe/   fred/joe/>,
                  </fred/../joe/  fred/../joe/>,
                );

    for @tests -> $r
    {
        my ($input, $expected) = |$r;

        my Bool $dir = $input.substr(*-1) eq '/' ;
        my $got = make-canonical-name($input, $dir);

        is $got, $expected, "'$input' => '$expected'";
    }

    for @tests -> $r
    {
        my ($input, $expected) = |$r;

        my Str $dir = $input.substr(*-1) eq '/' ?? "" !! "/" ;
        my $got = make-canonical-name($input, True);

        is $got, $expected ~ $dir, "got $expected$dir" ;
    }    

}

{
    my $SPEC = IO::Spec::Win32 ;
    my @tests = ( <fred           fred>,
                  <C:\\fred          fred>,
                  <C:fred          fred>,
                  <\\fred          fred>,
                  <\\fred\\joe      fred/joe>,
                  <\\fred\\joe\\     fred/joe/>,
                  <\\fred\\.\\joe\\   fred/joe/>,
                  <\\fred\\..\\joe\\  fred/../joe/>,
                );

    for @tests -> $r
    {
        my ($input, $expected) = |$r;

        my Bool $dir = $input.substr(*-1) eq '\\' ;
        my $got = make-canonical-name($input, $dir, :$SPEC);

        is $got, $expected, "'$input' => '$expected'";
    }
}

done-testing();
