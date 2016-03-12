# PackUnpack

An attempt at implementing Perl 5's pack/unpack functionality
efficiently in Perl 6, if for no other reason we're going to need
it to support "use v5".

#Description
Exports 3 subroutines:
* pack
* unpack
* parse-pack-template

##pack
Provide functionality of Perl 5's pack statement.  Currently supported
directives are: a A c C h H i I l L n N q Q s S U v V x Z

## unpack
Provide functionality of Perl 5's pack statement.  Currently supported
directives are: a A c C h H i I l L n N q Q s S U v V x Z

##parse-pack-template
Parses a given template into an internal format.  If many calls are made
to pack/unpack with the same template, efficiency will improve by parsing
the template only once and feeding its result to pack/unpack instead of
the original template string.

 use PackUnpack;

 say pack("ccxxcc",65,66,67,68); # "AB\0\0CD";

 my @template = parse-pack-template("ccxxcc");
 say pack(@template,65,66,67,68); # same

#Copying
Copyright (c) 2016 Elizabeth Mattijsen.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

Recent changes can be (re)viewed in the public GIT repository at
https://github.com/lizmat/PackUnpack

Feel free to clone your own copy:
 $ git clone https://github.com/lizmat/PackUnpack

#Prerequisites
* perl6 v6.c

#Build/Installation

 $ panda install PackUnpack

#Author
Elizabeth Mattijsen <liz@dijkmat.nl>
