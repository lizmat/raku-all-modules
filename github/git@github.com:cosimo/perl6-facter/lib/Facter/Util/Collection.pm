# Manage which facts exist and how we access them.  Largely just a wrapper
# around a hash of facts.

use Facter::Debug;

unit class Facter::Util::Collection does Facter::Debug;

#se Facter;
#se Facter::Util::Fact;
use Facter::Util::Loader;

# Private members
has %!facts = ();
has $!loader;

# Return a fact object by name.  If you use this, you still have to call
# 'value' on it to retrieve the actual value.
method get($name) {
    return $.value($name);
}

# Add a resolution mechanism for a named fact.  This does not distinguish
# between adding a new fact and adding a new way to resolve a fact.
method add($fact_name, $block) {

    # TODO add %options support
    my %options = ();

    self.debug("Facter::Util::Collection.add $fact_name: $block");

    my $name = self.canonize($fact_name);

    my $fact = %!facts{$name};
    unless $fact {
        self.debug("- new Fact '$name'");
        $fact = Facter::Util::Fact.new(name => $name);
        self.debug("- new Fact '$name' created: " ~ $fact.perl);
        %!facts{$name} = $fact;
        self.debug('%!facts{$name}' ~ " = '" ~ %!facts{$name});
    }

    # Set any fact-appropriate options.
    for %options.kv -> $opt, $value {
        my $method = $opt.Str;   # + "=" is a ruby fancyness
        if $fact.^can($method) {
            $fact.$method($value);
            %options{$opt}.delete;
        }
    }

    if $block {

        self.debug("Fact " ~ $fact ~ " adding block " ~ $block.perl);
        my $resolve = $fact.add($block);

        # Set any resolve-appropriate options
        for %options.kv -> $opt, $value {
            my $method = $opt.Str;  # again, + "="
            if $resolve.^can($method) {
                $resolve.$method($value);
                %options{$opt}.delete;
            }
        }
    }

    if %options.keys {
        die "Invalid facter option(s) " ~ %options.keys ==> map { $_.Str } ==> join(",");
    }

    self.debug("Facter::Util::Collection.add returns \$fact=$fact");
    return $fact;
}

# Iterate across all of the facts.
method each () {
    # XXX Can this even work??
    gather for %!facts.kv -> $name, $fact {
        my $value = $fact.value;
        if $value.defined {
            take($name.Str, $value);
        }
    }
}

# Return a fact by name.
method fact($name) {
    my $fact_name = self.canonize($name);

    unless %!facts{$fact_name}:exists {
        self.debug("Facter::Util::Collection.fact loading fact $fact_name through loader");
        self.loader.load($fact_name);
    }

    # self.debug("Facter::Util::Collection.fact fact $fact_name: " ~ %!facts{$fact_name});

    return %!facts{$fact_name};
}

# Flush all cached values.
method flush {
    for %!facts.values -> $fact {
        $fact.flush if $fact;
    }
}

method initialize {
    %!facts = ();
}

# Return a list of all of the facts.
method list {
    return %!facts.keys
}

# Load all known facts.
method load_all {
    self.loader.load_all
}

# The thing that loads facts if we don't have them.
method loader {
    $!loader //= Facter::Util::Loader.new;
    return $!loader;
}

# Return a hash of all of our facts.
method to_hash {
    my %result;

    for %!facts.kv -> $name, $fact {
        my $value = $fact.value;
        if $value.defined {
            %result{$name.Str} = $value;
        }
    }

    return %result;
}

method value($name) {
    if my $fact = self.fact($name) {
        return $fact.value
    }
}

# Provide a consistent means of getting the exact same fact name
# every time.
method canonize($name) {
    $name.Str.lc;  # TODO: lookup to_sym ??
}

