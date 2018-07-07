use v6;
unit class HTTP::Tinyish::FileTempFactory;
use File::Temp;

has @.tempfile;

method tempfile(Bool :$unlink = True) {
    my ($file, $fh) = tempfile(:!unlink);
    @!tempfile.push( ($file, $fh) ) if $unlink;
    $file, $fh
}

method cleanup() {
    for @!tempfile -> ($file, $fh) {
        $file.IO.unlink if $file.IO.e;
        $fh.close if $fh;
    }
    @!tempfile = Empty;
}

submethod DESTROY {
    self.cleanup if @!tempfile;
}
