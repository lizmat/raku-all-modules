use v6;

#| type agnostic result class;
unit class Pod::Coverage::Result;

has Str $.packagename;
has $.name;
has $.path;
has $.what;

has Bool $.is_ok is rw = False;

method gist {
    self.desc;
}

method Str {
    self.desc;
}
method desc {
    my $no = $!is_ok ?? "" !! " no";
    my $path = $!path ?? '(' ~ $!path ~ ')' !! "";
    my $name = $!name ?? '::' ~ $!name !! "";
    return "{$!packagename}{$name} has{$no} pod {$path}";
}

multi method Bool {$!is_ok}

sub new-result(Str :$packagename!, Str :$name?, :$path?, :$type?, :$what?) is export {
    Pod::Coverage::Result.new(
        packagename => $packagename,
        name => $name,
        path => $path,
        type => $type,
        what => $what,
        );
}
