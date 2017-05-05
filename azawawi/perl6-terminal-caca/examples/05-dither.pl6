use v6;
use lib 'lib';
use Terminal::Caca;

sub read-ppm-image(Str $filename) {
    my $fh               = open $filename;
    my $format           = $fh.get;
    my ($width, $height) = ($fh.get.split(" "));
    $width               = $width.Int;
    $height              = $height.Int;
    my $depth            = $fh.get;
    my $data             = $fh.slurp-rest(:bin);

    $width, $height, $depth, $data
}

# Initialize library
given my $o = Terminal::Caca.new {
    # Set window title
    .title("Camelia - ASCii Art :)");

    my ($width, $height, $depth, $data) = read-ppm-image("camelia-logo.ppm");
    .dither-image($width, $height, $data);

    # Refresh display
    .refresh;

    # Wait for a key press event
    .wait-for-keypress;

    # Cleanup on scope exit
    LEAVE { $o.cleanup; }
}
