use Test;

plan(9);

my (@should-be-unlinked, @should-be-kept);

# Install this END phaser here before File::Temp has a chance to create it's END phaser
# so that we can check that files are unlinked properly
END {
    for @should-be-kept -> $f {
        ok($f.IO ~~ :e, "file $f still exists");
        unlink($f);
    }
    for @should-be-unlinked -> $f {
        ok(!($f.IO ~~ :e), "file $f was unlinked");
    }
}


# TODO Remove the EVAL; this is a hack to work around improper ordering
#      of END phasers in Rakudo

EVAL '
use File::Temp;

my ($name,$handle) = tempfile;
ok($name.IO ~~ :e, "tempfile created");
ok($handle.close, "tempfile closed");


ok($name.IO ~~ :e, "tempfile exists after closing the handle");
@should-be-unlinked.push: $name;

($name,$handle) = tempfile( :!unlink );
@should-be-kept.push: $name;

($name,$handle) = tempfile( :prefix("foo") );
@should-be-unlinked.push: $name;
ok($name ~~ /foo/, "name has foo in it");

($name,$handle) = tempfile( :suffix(".txt") );
@should-be-unlinked.push: $name;
ok($name ~~ / ".txt" $ /, "name ends in .txt");

'
