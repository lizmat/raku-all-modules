unit class Git::PurePerl::Object;

my Str enum ObjectKind is export (:commit<commit>, :tree<tree>, :blob<blob>, :tag<tag>);

has $.kind = die 'kind is required';
has $.size = die 'size is required';
has $.content is rw = die 'content is required';
has $.sha1 = die 'sha1 is required';
has $.git = die 'git is required';

submethod BUILD (:$!kind, :$!size, :$content is copy, :$!sha1, :$!git) {
    $content .= decode: 'latin-1' if $content ~~ Blob;
    $!content = $content;
}

# vim: ft=perl6
