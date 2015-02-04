#
# Facter::Util::Confine
#
# A restricting tag for fact resolution mechanisms.  The tag must be true
# for the resolution mechanism to be suitable.
#

class Facter::Util::Confine;

use Facter::Util::Values;

has $.fact is rw;
has @.values is rw;

# Add the restriction.  Requires the fact name, an operator, and the value
# we're comparing to.
method BUILD ($fact, *@values) {

    Facter.debug("Building confine for " ~ $fact ~ " = " ~ @values.perl);

    die "The fact name must be provided" unless $fact; # ArgumentError
    die "One or more values must be provided" if @values.elems == 0;
    $.fact = $fact;
    @.values = @values;
}

method Str {   # ruby: to_s
    my $fact = $.fact;
    my $values = @.values.join(',');
    return "'$fact' '$values'";
}

# Evaluate the fact, returning true or false.
method Bool {

    Facter.debug("Confine processing: checking truth for fact " ~ $.fact ~ " = " ~ @.values.perl);

    unless my $fact = Facter.get_fact($.fact) {
        Facter.debug("No fact for $.fact");
        return False;
    }

    my $value = Facter::Util::Values.convert($fact.value);
    return False unless $value.defined;

    for @.values -> $v {
        $v = Facter::Util::Values.convert($v);
        next unless $v.WHAT == $value.WHAT;    # ruby's .class
        return True if $value eq $v;
    }

    return False
}

