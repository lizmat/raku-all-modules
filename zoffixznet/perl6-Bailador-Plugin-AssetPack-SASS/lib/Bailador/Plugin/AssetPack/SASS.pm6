unit class Bailador::Plugin::AssetPack::SASS:ver<2.001001>;

method install ($app) {
    my $sass = Proc::Async.new: 'sass',  '--style', 'compressed',
        '--watch', $*SPEC.catdir('assets', 'sass');

    $sass.stdout.tap: -> $v { $*OUT.print: $v };
    $sass.stderr.tap: -> $v { $*ERR.print: $v };
    $sass.start;

    $app.get: rx{ ^ '/assets/sass/' (.+) $ } => sub ($name) {
        my $file = $*SPEC.catdir('assets', 'sass', $name).IO;
        return $app.response.code: 404 unless .extension eq 'css' and .f and .r given $file;
        $app.response.headers<Content-Type> = 'text/css';
        $app.render: $file.IO.slurp: :bin;
    };
}
