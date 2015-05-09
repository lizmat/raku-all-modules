use MONKEY_TYPING;
use File::Find;
use Shell::Command;

# needed to prevent warning now;
use nqp;

##### Functions for Export: path() variants ######
# because Str.path is already taken by IO::Path
multi sub path (Str:D $path) is export {
    IO::Path.new($path);
}
multi sub path (:$basename!, :$directory = '.', :$volume = '') is export {
    IO::Path.new(:$basename, :$directory, :$volume)
}
##################################################

augment class IO::Path {

method append (*@nextpaths) {
    my $lastpath = @nextpaths.pop // '';
    self.new($.SPEC.join($.volume, $.SPEC.catdir($.dirname, $.basename, @nextpaths), $lastpath));
}


method remove {
    if self.d { rmdir  ~self }
    else      { unlink ~self }
}


method rmtree {
    rm_rf($!path)
}
 
method mkpath {
    mkpath($!path)
}

method touch {
    fail "Not Yet Implemented: requires utime()";
}

method stat {
    fail "Not Yet Implemented: requires stat()";
}

method find (:$name, :$type, Bool :$recursive = True) {
    find(dir => $!path, :$name, :$type, :$recursive);
    #find(dir => ~self, :$name, :$type)
}

# Some methods added in the absence of a proper IO.stat call
method inode() {
    $*OS ne any(<MSWin32 os2 dos NetWare symbian>)   #this could use a better way of asking "am I posixy?
    && self.e
    && nqp::p6box_i(nqp::stat(nqp::unbox_s(self.Str), nqp::const::STAT_PLATFORM_INODE))
}

method device() {
    self.e && nqp::p6box_i(nqp::stat(nqp::unbox_s(self.Str), nqp::const::STAT_PLATFORM_DEV))
}

method next {
    my @dir := self.parent.dir;
    if self.e {
        while (@dir.shift ne self.basename) { ; }
        @dir[0];
    }
    else {
        first { self.basename leg $_ ~~ Less }, @dir.sort;
    }
}

method previous {
    my @dir := self.parent.dir;
    if self.e {
        my $previtem := Nil;
        for @dir -> $curritem {
            last if $curritem eq $.basename;
            $previtem := $curritem;
        };
        $previtem;
    }
    else {
        first { self.basename leg $_ ~~ More }, @dir.sort.reverse;
    }
}



}
