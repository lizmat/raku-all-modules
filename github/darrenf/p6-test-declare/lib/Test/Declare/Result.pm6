use v6.c;

unit class Test::Declare::Result;

has Str $.status is rw;
has %.streams is rw;
has Exception $.exception is rw;
has $.return-value is rw;
