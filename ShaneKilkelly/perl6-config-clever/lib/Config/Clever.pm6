use v6;
use JSON::Tiny;
unit class Config::Clever;

method load (:$environment = "default", :$config-dir = "./config") {
    my %config;
    my @paths = (
        "$config-dir/default.json",
        "$config-dir/$environment.json",
        "$config-dir/local-$environment.json"
    );
    for @paths -> $path {
        if "$path".IO ~~ :e {
            my $content = $path.IO.slurp;
            my %data = from-json($content);
            hash-merge(%config, %data);
        }
    }

    return %config;
}

our &hash-merge is export = sub (%one, %two) {
    sub walk (%left, %right) {
        for %right.kv -> $k, $v {
            if $v ~~ Hash {
                if %left{$k} ~~ Any {
                    %left{$k} = %();
                }
                walk(%left{$k}, $v);
            } else {
                %left{$k} = $v;
            }
        }
    }
    walk(%one, %two);
    %one;
}
