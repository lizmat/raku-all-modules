use v6;
use Test;
use Test::Junkie;

# tracker directory initialization
{ 
    my @directory_list = <directory1 directory2 directory3>;
    my Test::Junkie::Tracker $directory_tracker = Test::Junkie::Tracker.new(@directory_list);
    my Test::Junkie::Tracker $default_tracker = Test::Junkie::Tracker.new;

    is $default_tracker.directories, <lib t>, "default directories should be are 'lib' and 't'";
    is $directory_tracker.directories, @directory_list , "tracked directories should be configurable at instanciation";
}

# resolving tracked files
{
    my Test::Junkie::Tracker $tracker = Test::Junkie::Tracker.new();

    my @actual = $tracker.files.map({.path});
    my @expected = <lib/Test/Junkie.pm t/tracker.t>;
    
    is @actual, @expected, "should track .pm and .t files in the configured directory trees";
}

# refreshing tracked files
{
    my Test::Junkie::Tracker $tracker = Test::Junkie::Tracker.new();
    my $num_tracked_files = $tracker.files.elems; 

    my $tempfile = 't/temporary_file-' ~ $*PID ~ '.t';
    create_temporary_file($tempfile);

    is $tracker.files.elems, $num_tracked_files + 1, "should update tracked files if new file added";

    remove_temporary_file($tempfile);
}

# checking for changed files
{
    my $tempfile = 't/temporary_file-' ~ $*PID ~ '.t';
    my Test::Junkie::Tracker $tracker = Test::Junkie::Tracker.new();

    $tracker.update_timer;
    sleep 2; 

    create_temporary_file($tempfile);

    is $tracker.changed.map({.path}), $tempfile, 'should return file(s) changed since last timer update';

    remove_temporary_file($tempfile);
}

sub create_temporary_file(Str $file) {
    my $fh = open $file, :w orelse die "Could not create $file"; 
    $fh.close; 
}

sub remove_temporary_file(Str $file) {
    unlink $file;
    ok($file.IO ~~ :!e, "cleanup: removed test file $file"); 
}

done-testing;
