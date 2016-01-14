#
# Facter::Util::Resolution
#
# An actual fact resolution mechanism.  These are largely just chunks of
# code, with optional confinements restricting the mechanisms to only working on
# specific systems.  Note that the confinements are always ANDed, so any
# confinements specified must all be true for the resolution to be
# suitable.
#

use Facter::Debug;

unit class Facter::Util::Resolution does Facter::Debug;

#equire 'timeout'
#equire 'rbconfig'

has $!value;
has $!suitable;

has $.code is rw;
has $.interpreter is rw;
has $.name is rw;
has $.timeout is rw;
has @.confines is rw;

our $WINDOWS = $*OS ~~ m:i/mswin|win32|dos|mingw|cygwin/;
our $INTERPRETER = $WINDOWS ?? 'cmd.exe' !! '/bin/sh';
our $HAVE_WHICH;

method have_which {
    if ! $HAVE_WHICH.defined {
        if Facter.value('kernel') eq 'windows' {
            $HAVE_WHICH = False;
        } else {
            $HAVE_WHICH = run('which which >/dev/null 2>&1') == 0;
        }
    }
    return $HAVE_WHICH;
}

# Execute a program and return the output of that program.
#
# Returns nil if the program can't be found, or if there is a problem
# executing the code.
#
method exec($code, $interpreter = $INTERPRETER) {

    unless $interpreter eq $INTERPRETER {
        die "invalid interpreter";
    }

    # Try to guess whether the specified code can be executed by looking at the
    # first word. If it cannot be found on the PATH defer on resolving the fact
    # by returning nil.
    # This only fails on shell built-ins, most of which are masked by stuff in 
    # /bin or of dubious value anyways. In the worst case, "sh -c 'builtin'" can
    # be used to work around this limitation
    #
    # Windows' %x{} throws Errno::ENOENT when the command is not found, so we 
    # can skip the check there. This is good, since builtins cannot be found 
    # elsewhere.
    if self.have_which and !$WINDOWS {
        my $path = Mu;
        my $binary = $code.split(" ").[0];
        if $code ~~ /^\// {
            $path = $binary;
        } else {
            self.debug("Trying to find which '$binary'");
            $path = qqx{which '$binary' 2>/dev/null}.chomp;
            # we don't have the binary necessary
            return if $path eq "" or $path.match(/"Command not found\."/);
        }
        self.debug("path=$path");
        return unless $path.IO ~~ :e;
    }

    my $out;

    self.debug("Running command $code");
    try {
        $out = qqx{$code}.chomp;
    }
    CATCH {
        self.debug("Command failed: $_");
        return;
    }

    return if $out eq "";
    return $out;
}

# Add a new confine to the resolution mechanism.
method confine(%confines) {
    require Facter::Util::Confine;
    for %confines.kv -> $fact, $value {
        self.debug("Adding confine '$fact' => '$value'");
        @.confines.push(Facter::Util::Confine.new($fact, $value));
    }
}

# Create a new resolution mechanism.
method initialize($name) {
    $.name = $name;
    @.confines = ();
    $!value = Mu;
    $.timeout = 0;
    return;
}

# Return the number of confines.
method length {
    @.confines.elems;
}

# We need this as a getter for 'timeout', because some versions
# of ruby seem to already have a 'timeout' method and we can't
# seem to override the instance methods, somehow.
method limit {
    $.timeout;
}

# Set our code for returning a value.
method setcode($string = "", $interp = "", $block = Mu) {
    if $string {
        $.code = $string;
        $.interpreter = $interp || $INTERPRETER;
    } elsif $block {
        $.code = $block;
    } else {
        die "You must pass either code or a block";
    }
}

# Is this resolution mechanism suitable on the system in question?
method suitable {
    unless $!suitable.defined {
        $!suitable = (any(@.confines) == False) ?? 0 !! 1;
    }
    return $!suitable;
}

method to_s {
    return self.value;
}

# How we get a value for our resolution mechanism.
method value {

    if ! $.code and ! $.interpreter {
        self.debug("No code and no interpreter. Can't get value of fact $.name");
        return;
    }

    my $result;
    my $starttime = time;

    self.debug("Getting value of fact $.name...");

    try {
        if "Sub()" eq $.code.WHAT {
            self.debug("   Running block $.code");
            $result = $.code();
        } else {
            self.debug("   Running command $.code through $.interpreter");
            $result = Facter::Util::Resolution.exec($.code, $.interpreter);
        }
    }
    CATCH {
        warn "Could not retrieve $.name: $!";
        return
    }

    my $finishtime = time;
    my $ms = ($finishtime - $starttime) * 1000;
    Facter.show_time("$.name: $ms ms");

    return if $result eq "";
    return $result;
}

