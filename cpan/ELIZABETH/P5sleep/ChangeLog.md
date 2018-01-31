# Version 0.0.1
Initial implementation.

# Version 0.0.2
Make sure we respect the Int-ness of sleep() on Perl 5.  Only the sleep()
exported by Time::Hires knows about fractional sleep times.  Zoffix++ for
pointing that out.

# Version 0.0.3
Resolve the original sleep() at compile time.
