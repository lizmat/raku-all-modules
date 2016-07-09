unit module Quantum::Collapse;

sub process ($how, $v) {
    my @stuff = |$v;
    for @stuff {
        next if $_ ~~ Junction or $_ !~~ IntStr|NumStr|RatStr|ComplexStr;
        $_ = $how eq 'n' ?? .Numeric !! .Str;
    }

    my $name = try $v.^name;
    return |@stuff unless $name and $name eq 'List' | 'Array' | 'Slip';
    @stuff."$name"();
}

sub prefix:«n<-» (|c) is equiv(&prefix:<|>) is export { process 'n', |c; }
sub prefix:«s<-» (|c) is equiv(&prefix:<|>) is export { process 's', |c; }
