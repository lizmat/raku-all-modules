use v6.c;
unit module P5-X:ver<0.0.2>;

my role Subject-X { has $.subject }

my enum Index ( <r w x e d f l s z> );
BEGIN my @methods = Index.^enum_value_list.map( { IO::Path.can("$_")[0] } );

my sub io($io, $index) {
    my $result := @methods[$index]($io);
    $result ~~ Failure
      ?? Nil
      !! ($result ?? +$result !! "") but Subject-X($io)
}

sub chain($s, $i) { $s ~~ Int:D ?? $s && io($s.subject, $i) !! $s }

proto sub prefix:<-r>(|) is export {*}
multi sub prefix:<-r>()                { -r CALLERS::<$_> }
multi sub prefix:<-r>(IO::Handle:D $h) { io($h,r)        }
multi sub prefix:<-r>(IO() $io)        { io($io,r)        }
multi sub prefix:<-r>(Subject-X:D $s)  { chain($s,r)      }

proto sub prefix:<-w>(|) is export {*}
multi sub prefix:<-w>()                { -w CALLERS::<$_> }
multi sub prefix:<-w>(IO::Handle:D $h) { io($h,w)        }
multi sub prefix:<-w>(IO() $io)        { io($io,w)        }
multi sub prefix:<-w>(Subject-X:D $s)  { chain($s,w)      }

proto sub prefix:<-x>(|) is export {*}
multi sub prefix:<-x>()                { -x CALLERS::<$_> }
multi sub prefix:<-x>(IO::Handle:D $h) { io($h,x)        }
multi sub prefix:<-x>(IO() $io)        { io($io,x)        }
multi sub prefix:<-x>(Subject-X:D $s)  { chain($s,x)      }

proto sub prefix:<-e>(|) is export {*}
multi sub prefix:<-e>()                { -e CALLERS::<$_> }
multi sub prefix:<-e>(IO::Handle:D $h) { io($h,e)        }
multi sub prefix:<-e>(IO() $io)        { io($io,e)        }
multi sub prefix:<-e>(Subject-X:D $s)  { chain($s,e)      }

proto sub prefix:<-d>(|) is export {*}
multi sub prefix:<-d>()                { -d CALLERS::<$_> }
multi sub prefix:<-d>(IO::Handle:D $h) { io($h,d)        }
multi sub prefix:<-d>(IO() $io)        { io($io,d)        }
multi sub prefix:<-d>(Subject-X:D $s)  { chain($s,d)      }

proto sub prefix:<-f>(|) is export {*}
multi sub prefix:<-f>()                { -f CALLERS::<$_> }
multi sub prefix:<-f>(IO::Handle:D $h) { io($h,f)        }
multi sub prefix:<-f>(IO() $io)        { io($io,f)        }
multi sub prefix:<-f>(Subject-X:D $s)  { chain($s,f)      }

proto sub prefix:<-l>(|) is export {*}
multi sub prefix:<-l>()                { -l CALLERS::<$_> }
multi sub prefix:<-l>(IO::Handle:D $h) { io($h,l)        }
multi sub prefix:<-l>(IO() $io)        { io($io,l)        }
multi sub prefix:<-l>(Subject-X:D $s)  { chain($s,l)      }

proto sub prefix:<-s>(|) is export {*}
multi sub prefix:<-s>()                { -s CALLERS::<$_> }
multi sub prefix:<-s>(IO::Handle:D $h) { io($h,s)        }
multi sub prefix:<-s>(IO() $io)        { io($io,s)        }
multi sub prefix:<-s>(Subject-X:D $s)  { chain($s,s)      }

proto sub prefix:<-z>(|) is export {*}
multi sub prefix:<-z>()                { -z CALLERS::<$_> }
multi sub prefix:<-z>(IO::Handle:D $h) { io($h,z)        }
multi sub prefix:<-z>(IO() $io)        { io($io,z)        }
multi sub prefix:<-z>(Subject-X:D $s)  { chain($s,z)      }

=begin pod

=head1 NAME

P5-X - Implement Perl 5's -X built-ins

=head1 SYNOPSIS

  use P5-X; # exports -r -w -x -e -d -f -l -s -z

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<-X> built-ins of Perl 5 as
closely as possible.

=head1 PORTING CAVEATS

Other -X built-ins are in the process of being supported.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5-X . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
