unit module Test::Output;
use Test;

my class IO::Bag {
    has @.err-contents;
    has @.out-contents;
    has @.all-contents;

    method err { @.err-contents.join: '' }
    method out { @.out-contents.join: '' }
    method all { @.all-contents.join: '' }
}

my class IO::Capture::Single is IO::Handle {
    has Bool    $.is-err =  False   ;
    has IO::Bag $.bag    is required;

    method print-nl { self.print($.nl-out); }
    method print (*@what) {
                    $.bag.all-contents.push: @what.join: '';
        $!is-err ?? $.bag.err-contents.push: @what.join: ''
                 !! $.bag.out-contents.push: @what.join: '';

        True;
    }
}

my sub capture (&code) {
    my $bag = IO::Bag.new;
    my $out = IO::Capture::Single.new: :$bag        ;
    my $err = IO::Capture::Single.new: :$bag :is-err;

    my $saved-out = $PROCESS::OUT;
    my $saved-err = $PROCESS::ERR;
    $PROCESS::OUT = $out;
    $PROCESS::ERR = $err;

    &code();

    $PROCESS::OUT = $saved-out;
    $PROCESS::ERR = $saved-err;

    return {:out($bag.out), :err($bag.err), :all($bag.all)};
}

sub output-is   (*@args) is export { test |<all is>,   &?ROUTINE.name, |@args }
sub output-like (*@args) is export { test |<all like>, &?ROUTINE.name, |@args }
sub stdout-is   (*@args) is export { test |<out is>,   &?ROUTINE.name, |@args }
sub stdout-like (*@args) is export { test |<out like>, &?ROUTINE.name, |@args }
sub stderr-is   (*@args) is export { test |<err is>,   &?ROUTINE.name, |@args }
sub stderr-like (*@args) is export { test |<err like>, &?ROUTINE.name, |@args }

sub output-from (&code)  is export { return capture(&code)<all> }
sub stderr-from (&code)  is export { return capture(&code)<err> }
sub stdout-from (&code)  is export { return capture(&code)<out> }

sub test (
    Str:D $output-type where { any <all err out>  },
    Str:D $op-name     where { any <is like from> },
    Str:D $routine-name,
    &code,
    $expected where Str|Regex,
    Str $test-name? is copy
)
{
    $test-name //= "$routine-name on line {callframe(4).line}";
    if ( $op-name eq 'from' ) {
        return capture(&code){ $output-type };
    }
    else {
        return &::($op-name)(
            capture(&code){ $output-type },
            $expected,
            $test-name,
        );
    }
}
