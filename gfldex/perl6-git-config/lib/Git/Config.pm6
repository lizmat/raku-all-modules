use v6.c;

grammar Config is export {
    token TOP { ^ <section>+ $ }
    token section { [ '[' <section-name> ']' \n [ <section-line>+ | <empty-line>+ ] ] | <empty-line>+ }
    token section-name { <-[\]]>+ }
    token section-line { \s* <identifier> \s* '=' \s* <value> \n }
    token empty-line { \n }
    token value { <-[\n]>+ }
    token identifier { \w+ }
}

sub git-config(IO::Path $file = "$*HOME/.gitconfig".IO --> Hash) is export {
    my %ret;

    my $parsed = Config.parse($file.slurp) or fail 'Failed to parse „~/.gitconfig“.';

    for $parsed.Hash<section>.list -> $section {
        next unless $section<section-name>;

        %ret{$section<section-name>.Str} = Hash.new(do for $section.hash<section-line> {
             .hash<identifier>.Str => .hash<value>.Str
        })
    }
    
    %ret
}
