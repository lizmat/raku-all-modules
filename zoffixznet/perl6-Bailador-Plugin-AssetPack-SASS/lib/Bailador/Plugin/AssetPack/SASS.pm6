unit class Bailador::Plugin::AssetPack::SASS:ver<1.001001>;

use Bailador;

method install {
    my $sass = Proc::Async.new: 'sass',  '--style', 'compressed',
        '--watch', $*SPEC.catdir('assets', 'sass');

    $sass.stdout.tap: -> $v { $*OUT.print: $v };
    $sass.stderr.tap: -> $v { $*ERR.print: $v };
    $sass.start;

    get rx{ ^ '/assets/sass/' (.+) $ } => sub ($name) {
        my $file = $*SPEC.catdir('assets', 'sass', $name).IO;
        return status 404 unless .extension eq 'css' and .f and .r given $file;
        content_type 'text/css';
        return $file.IO.slurp: :bin;
    };
}
