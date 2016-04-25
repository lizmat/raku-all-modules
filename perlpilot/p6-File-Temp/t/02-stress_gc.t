use Test;

plan(2);

my (@should-be-unlinked);
my (@failed-not-unlinked);

# Install this END phaser here before File::Temp has a chance to create it's END phaser
# so that we can check that files are unlinked properly
END {
    my $ok = True;
    for @should-be-unlinked -> $f {
        if $f.IO ~~ :e {
            $ok = False;
            $f.IO.unlink;
            @failed-not-unlinked.push($f);
        }
    }
    ok $ok, "All files were unlinked";
    unless $ok {
        diag "{+@failed-not-unlinked} files left over.";
    }
}

# TODO Remove the EVAL; this is a hack to work around improper ordering
#      of END phasers in Rakudo

EVAL '
use File::Temp;

# Standardized force-gc needed lest this need recurring adjusting
for 1..300 {
    my ($fn, $fh) = tempfile;
    @should-be-unlinked.push($fn);
}

# This causes trouble with the s/// in make-temp
#await (for 1..100 {
#    start {
#        my ($fn, $fh) = tempfile;
#        @should-be-unlinked.push($fn);
#    }
#});

my $already-unlinked = False;
for @should-be-unlinked -> $f {
    unless $f.IO ~~ :e {
        $already-unlinked = True;
    }
}
ok $already-unlinked, "Some files were unlinked by GC";

'

