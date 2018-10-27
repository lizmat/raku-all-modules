Phaser-ATEXIT
=============

Simple implementation of ATEXIT for Perl 6.

    use Phaser::ATEXIT;

    ATEXIT { say "This will be run last" }
    ATEXIT { say "This will be run in the middle" }

    say "This will be run first";
