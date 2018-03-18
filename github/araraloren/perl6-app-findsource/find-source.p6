find-source-loading
#!/usr/bin/env perl6

use nqp;
use JSON::Fast;
use Getopt::Advance;
use Getopt::Advance::Parser;

class Config { ... }
class ConfigSearcher { ... }

my OptionSet $os .= new;
my $category = <w a>.SetHash;
my %configs  = &loadConfig();

&main();

sub main() {
    $os.push(
        'l=a',
        "load specify config, available config are < {%configs.keys.join(' ')} >.",
    );
    $os.push(
        'w=a',
        'match whole filename.',
    );
    $os.push(
        'a=a',
        'addition extension list.',
    );
    $os.push(
        'i=b',
        'enable ignore case mode.'
    );
    $os.append(
        'no|=a' => 'exclude file category.',
        'only|=s' => 'only search given category.',
        :radio
    );
    $os.push(
        'd|debug=b',
        'print debug message.'
    );
    $os.insert-pos(
        "directory",
        sub find-and-print-source($os, $dira) {
            my @stack = $dira.value;
            my (@t1, @t2);
            my %no := ($os<no> // []).SetHash;
            my ($debug, $ignore-case) = ($os<d>, $os<i>);

            @t1 = do {
                my @t;
                with $os<only> {
                    fail "Not recognized category: {$_}." unless $category{$_};
                    @t := $_ eq "w" ?? [] !! ($os{$_} // []);
                } else {
                    @t = [];
                    for @($category.keys) {
                        if not %no{$_} {
                            @t.append($os{$_} // []);
                        }
                    }
                }
                @t = @t>>.lc if $ignore-case;
                flat( @t Z, (True xx +@t));
            };
            @t2 = do {
                my @t;
                @t = ($os.get('only').has-value && $os<only> ne "w") ?? [] !! (
                    %no<w> ?? [] !! ($os<w> // [])
                );
                @t = @t>>.lc if $ignore-case;
                flat( @t Z, (True xx +@t));
            };
            my %ext := Map.new(@t1);
            my %whole := Map.new(@t2);

            note "GET ALL EXT => ", %ext if $debug;

            my $supplier = Supplier.new;

            $supplier.Supply.tap: {
                put Q :qq '"$_"';
            };

            while @stack {
                note "CURR FILES => ", @stack if $debug;
                my @stack-t = (@stack.race.map(
                                    sub ($_) {
                                        note "\t|GOT FILE => ", $_ if $debug;
                                        if nqp::lstat(nqp::unbox_s($_), nqp::const::STAT_ISDIR) == 1 {
                                            return .&getSubFiles;
                                        } else {
                                            my $fp  = &basename($_);
                                            my $ext = $fp.substr(($fp.rindex(".") // -1) + 1);

                                            note "\t=>GOT EXT = ", $ext if $debug;
                                            if %ext{$ignore-case ?? $ext.lc !! $ext} || (%whole{$ignore-case ?? $fp.lc !! $fp} ) {
                                                note "\t\t|SEND FILE ", $_ if $debug;
                                                $supplier.emit($_);
                                            }
                                        }
                                        return ();
                                    }
                                ).flat);
                @stack = @stack-t;
            };
        },
        :last
    );

    &getopt(&getopt($os, parser => &config_loader).noa, [ $os, ]);
}

sub config_loader(@args, $optset, |c) {
    my @loadop = [];
    my @config = [];
    my @noa = [];

    loop (my $i = 0;$i < +@args; $i++) {
        if @args[$i] eq '-l' {
            @loadop.push($i);
            @config.push(@args[++$i]);
        } else {
            @noa.push(@args[$i]);
        }
    }

    for @config.sort.unique -> $name {
        my @options := %configs{$name}<option>;

        for @options -> $option {
            my $short = $option<short>;

            $category{$short} = True;
            if $optset.has($short) {
                my $o = $optset.get($short);
                my @old := $o.default-value // [];

                @old.append($option<value>);
                @old = @old.sort.unique;
                $o.set-default-value(@old);
            } else {
                $optset.push(
                    "{$short}| = a",
                    $option<annotation>,
                    value => @($option<value>)
                );
            }
        }
    }

    return Getopt::Advance::ReturnValue.new(
        optionset => $optset,
        noa => @noa,
        return-value => %{},
    );
}

sub basename($filepath) {
    return $filepath.substr(($filepath.rindex('/') // -1) + 1);
}

sub getSubFiles($path) {
    my @ret := [];
    my $dh := nqp::opendir($path);

    while (my $f = nqp::nextfiledir($dh)) {
        @ret.push("$path/$f") if $f ne ".." && $f ne ".";
    }

    nqp::closedir($dh);

    return @ret;
}

sub loadConfig() {
    my ConfigSearcher $cs .= new(name => 'findsource');
    my %ret;

    $cs.search();
    for $cs.config {
        %ret{.config-name} = from-json($_.slurp);
    }

    return %ret;
}

class Config {
    has $.path;
    has $.name;

    method config-name() {
        $!name.substr(0, $!name.rindex('.'));
    }

    method Str() {
        return $!path ~ '/' ~ $!name;
    }

    method slurp() {
        return self.Str().IO.slurp;
    }
}

class ConfigSearcher {
    has $.path;
    has $.name is required;
    has @.config;

    sub determind-local-path() {
        given $*KERNEL {
            when /win32/ {
                return $*HOME.add('AppData/Local/');
            }
            default {
                return $*HOME.add('.config/');
            }
        }
    }

    submethod TWEAK(:$path) {
        $!path = $path.defined ?? $path.IO !! &determind-local-path();
    }

    multi method search() {
        self!do-search({ $_ ne "." && $_ ne ".." });
    }

    multi method search(Regex $regex) {
        self!do-search($regex);
    }

    method !do-search($r) {
        my @dirs = $!path.add($!name);
        
        while +@dirs > 0 {
            my $dir = @dirs.shift;

            for $dir.dir -> $f {
                if $f ~~ :d {
                    @dirs.push($f);
                } elsif $f.basename ~~ $r {
                    @!config.push(Config.new(
                        path => $dir.path,
                        name => $f.basename,
                    ));
                }
            }
        }
    }
}
