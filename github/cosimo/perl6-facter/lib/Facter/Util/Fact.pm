use Facter::Debug;

unit class Facter::Util::Fact does Facter::Debug;

use Facter::Util::Resolution;

our $TIMEOUT = 5;

has $!value;
has $!suitable;

has $.name is rw = "";
has $.ldapname is rw = "";
has @.resolves is rw = ();
has $!searching = False;

# Create a new fact, with no resolution mechanisms.
method initialize($name, %options = ()) {
    $.name = $name.Str.lc;   # XXX .intern ?

    if %options<ldapname>.exists {
        $.ldapname = %options<ldapname>;
    }

    $.ldapname //= $.name.Str;

    @.resolves = ();
    $!searching = False;
    $!value = Mu;
}

# Add a new resolution mechanism.  This requires a block, which will then
# be evaluated in the context of the new mechanism.
method add ($block) {

    #raise ArgumentError, "You must pass a block to Fact<instance>.add" unless block_given?
    if ! $block {
        die "You must pass a block to Fact<instance>.add";
    }

    self.debug("Fact.add($.name, $block)");
    my $resolve = Facter::Util::Resolution.new(name => $.name);
    self.debug("\$resolve = " ~ $resolve.perl);

    # ruby: resolve.instance_eval(block);
    $block($resolve);

    @.resolves.push($resolve);

    self.debug("\$resolve = " ~ $resolve.perl);

    # Immediately sort the resolutions, so that we always have
    # a sorted list for looking up values.
    #  We always want to look them up in the order of number of
    # confines, so the most restricted resolution always wins.
    @.resolves = sort { $^b.elems <=> $^a.elems }, @.resolves;

    return $resolve;
}

# Flush any cached values.
method flush {
    $!value =
    $!suitable = Mu;
}

# Return the value for a given fact.  Searches through all of the mechanisms
# and returns either the first value or nil.
method value {

    if $!value.defined {
        self.debug("Fact value already defined: $!value");
        return $!value;
    }

    if @.resolves.elems == 0 {
        self.debug("No resolves for $!name");
        return;
    }

    $!value = self.searching(sub {

        self.debug("Facter::Util::Fact.value for $!name. Searching.");

        $!value = Mu;
        my $foundsuits = False;

        while @.resolves {
            my $resolve = @.resolves.shift;
            self.debug("- Evaluating resolve $resolve");

            unless $resolve.suitable {
                self.debug("- Resolve $resolve unsuitable");
                next;
            }

            $foundsuits = True;
            my $candidate_value = $resolve.value;
            self.debug("- Candidate value from resolve $resolve is $candidate_value");

            if $candidate_value.defined and $candidate_value ne "" {
                return $candidate_value;
            }
        }

        unless $foundsuits {
            self.debug("Found no suitable resolves of "
                ~ @.resolves.elems ~ " for " ~ $!name
            );
        }

    });

    if ! $!value.defined {
        self.debug("value for $!name is still undef");
        return;
    } else {
        return $!value
    }
}

# Are we in the midst of a search?
method are-we-searching {
    $!searching
}

# Lock our searching process, so we never ge stuck in recursion.
method searching (Sub $block) {

    if self.are-we-searching {
        self.debug("Caught recursion on $!name");

        # return a cached value if we've got it
        if $!value {
            return $!value
        } else {
            return
        }
    }

    # If we've gotten this far, we're not already searching, so go ahead and do so.
    $!searching = True;

    self.debug("Facter::Util::Fact.searching for $!name: start");

    my @fact-values = gather {
        #self.debug("- Block is " ~ $block.perl);
        my $next-value = $block();
        #self.debug("- 1 Got next value: " ~ $next-value ~ " (" ~ $next-value.perl ~ ")");
        $next-value = $next-value();
        #self.debug("- 2 Got next value: " ~ $next-value ~ " (" ~ $next-value.perl ~ ")");
        take $next-value;
        $!searching = False;
    };

    #begin
    #    yield
    #ensure
    #    @searching = false
    #end;

    return @fact-values;
}

