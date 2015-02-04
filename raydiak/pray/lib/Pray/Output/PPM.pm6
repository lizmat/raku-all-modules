class Pray::Output::PPM;

use Pray::Scene::Color;

has Str $.filename;
has Int $.width;
has Int $.height;
has Channel $.channel = Channel.new;

has Thread $.thread = Thread.start(sub {
    my $fh = open($!filename, :w);

    CATCH { $fh.close; return; };

    $fh.print("P3\n$!width $!height\n255\n");

    loop {
        $fh.print: sprintf( '%3d %3d %3d ', $_.r*255, $_.g*255, $_.b*255 )
            given $!channel.receive;
    }
});

multi method new ($filename, $width, $height) {
    self.bless: :$filename, :$width, :$height;
}

method set_next (Pray::Scene::Color $color) {
    $!channel.send: $color;
    return;
}

method write () {
    $!channel.close;
    return;
}


