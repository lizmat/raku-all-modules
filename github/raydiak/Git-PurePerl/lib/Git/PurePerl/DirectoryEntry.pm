unit class Git::PurePerl::DirectoryEntry;

has Str $.mode = die 'mode is required';
has Str $.filename = die 'filename is required';
has Str $.sha1 = die 'sha1 is required';
has $.git = die 'git is required';

method object {
    return $.git.get_object: $.sha1;
}

# vim: ft=perl6
