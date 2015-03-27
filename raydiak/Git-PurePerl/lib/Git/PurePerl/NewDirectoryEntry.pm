class Git::PurePerl::NewDirectoryEntry;

has Str $.mode = die 'mode is required';
has Str $.filename = die 'filename is required';
has Str $.sha1 = die 'sha1 is required';

# vim: ft=perl6
