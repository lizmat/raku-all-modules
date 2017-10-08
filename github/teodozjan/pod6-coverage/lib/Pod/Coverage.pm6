use v6;
use JSON::Tiny;

use Pod::Coverage::Anypod;
use Pod::Coverage::Full;

#| If You want to understand how module works start with
#| C<coverage> and C<@.results>
=begin pod 

=head1 NAME

 Pod::Coverage

=head1 SYNOPSIS

=begin code

git clone https://github.com/jonathanstowe/META6.git
cd META6
panda install ./
pod-coverage 

=end code 

or

=begin code

git clone https://github.com/jonathanstowe/META6.git
cd META6
pod-coverage --anypod

=end code 

=end pod

=cut

unit class Pod::Coverage;
#| place to start to command line
method use-meta($metafile,$anypod) {
    my @checks;
    my $mod = from-json slurp $metafile;
    for (flat @($mod<provides>//Empty)) -> $val {
        for $val.kv -> $k, $v {
            @checks.push: Pod::Coverage.coverage($k,$k, $v,$anypod);
        }
    }
    @checks
}

#| place to start for writting own tool  
method coverage($toload, $packageStr, $path, $anypod = False) {
    my $i;
    if $anypod {
        $i = Pod::Coverage::Anypod.new(packageStr => $packageStr, path => $path);
    }
    else {
        $i = Pod::Coverage::Full.new(
            packageStr => $packageStr, path => $path, toload => $toload);
        
    }
    $i.check;
    
    return $i;
}


