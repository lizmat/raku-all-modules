# Load facts on demand

use v6;

use Facter::Debug;

unit class Facter::Util::Loader does Facter::Debug;

has $!loaded_all = False;

# Load all resolutions for a single fact.
method load($fact) {

    # Now load from the search path
    my $shortname = $fact.Str.lc;
    self.load_env($shortname);

    return self.load_file($shortname);

    # TODO: would be cool to also run the ".rb" facts
    my $filename = $shortname ~ ".pm";
    my $module = "Facter::$shortname";
    self.debug("Attempting to load $module");
    try {
        require $module;
    }
    CATCH {
        warn "Unable to load fact $shortname: $!";
        return False;
    }

    return True;

    for self.search_path -> $dir {
        # Load individual files
        my $file = join('/', $dir, $filename);

        self.load_file($file) if $file.IO ~~ :e;   # exists

        # And load any directories matching the name
        my $factdir = join('/', $dir, $shortname);
        self.load_dir($factdir) if $factdir.IO ~~ :d;
    }

}

# Load all facts from all directories.
method load_all {
    return if $!loaded_all;

    self.debug("Loading env facts");
    self.load_env();

    self.debug("Loading facts from search_path: " ~ self.search_path.perl);
    for self.search_path -> $dir {

        self.debug("    - $dir");

        next unless $dir.IO ~~ :d;

        for dir($dir) -> $file {
            my $path = join('/', $dir, $file);
            if $path.IO ~~ :d {
                self.load_dir($path);
            } elsif $file ~~ /\.pm$/ {
                self.load_file($path);
            }
        }
    }

    $!loaded_all = True;
}

# The list of directories we're going to search through for facts.
method search_path {

    my @result = map {"$_/Facter"}, @*INC;

    my $facter_lib = $*ENV<FACTERLIB>;
    if $facter_lib.defined {
        @result.push($facter_lib.split(":"));
    }

    # This allows others to register additional paths we should search.
    @result.push(Facter.new.search_path);

    return @result;
}

#private

method load_dir($dir) {

    return if $dir ~~ /\/\.+$/
        or $dir ~~ /\/Util$/
        or $dir ~~ /\/lib$/;

    for dir($dir) -> $f {
        next unless $f ~~ /\.pm$/;
        self.load_file(join('/', $dir, $f));
    }

}

method load_file($file) {

    # $file can be 'lib/Facter/kernel.pm'
    # We need to require 'Facter::kernel'
    # Only lowercase names!
    self.debug("Attempting to load $file in load_file");
    return unless $file ~~ /(<[a..z]>\w*)\.pm$/;

    my $fact-name = $0.Str;
    my $module-name = "Facter::$fact-name";

    self.debug("Fact file name $file triggers load of module $module-name");

    # TODO: would be cool to also run the ".rb" facts
    try {
        require $module-name;
    }
    CATCH {
        self.debug("Failed loading fact file $file ($module-name)");
        return False;
    }

    return True;
}

# Load facts from the environment.  If no name is provided,
# all will be loaded.
method load_env($fact = "") {

    # TODO Iterate over %*ENV not possible?
    return;

    # Load from the environment, if possible
    for %*ENV.kv -> $name, $value {

        # Skip anything that doesn't match our regex.
        next unless $name ~~ m:i/^facter_?(\w+)$/;
        my $env_name = $0;

        # If a fact name was specified,
        # skip anything that doesn't match it.
        next if $fact and $env_name != $fact;

        Facter.add($env_name, $value);

        # Short-cut, if we are only looking for one value.
        last if $fact;
    }

}

