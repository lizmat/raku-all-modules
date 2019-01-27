

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

sub determind-local-path() is export {
    given $*KERNEL {
        when /win32/ {
            return $*HOME.add('AppData/Local/');
        }
        default {
            return $*HOME.add('.config/');
        }
    }
}

class ConfigSearcher {
    has $.path;
    has $.name is required;
    has @.config;
    has $!config-path;

    submethod TWEAK(:$path, :$create-if-not-exists) {
        $!path = $path.defined ?? $path.IO !! &determind-local-path();
        $!config-path = $!path.add($!name);
        $!config-path.mkdir if $create-if-not-exists && ! $!config-path.e;
    }

    method e() {
        return $!config-path ~~ :e;
    }

    multi method search() {
        self!do-search({ $_ ne "." && $_ ne ".." });
    }

    multi method search(Regex $regex) {
        self!do-search($regex);
    }

    method !do-search($r) {
        my @dirs = $!config-path;
        
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