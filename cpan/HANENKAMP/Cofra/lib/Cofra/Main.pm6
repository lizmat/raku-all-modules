use v6;

unit class Cofra::Main;

use Cofra::IOC;

use Cofra::Logger::Screen;
has Cofra::Logger $.logger is constructed(Cofra::Logger::Screen);

use Cofra::Biz;
has Hash[Cofra::Biz] $.bizzes is constructed;

use Cofra::App;
has Cofra::App $.app is constructed(dep('app-class')) is construction-args({
    logger => dep,
    bizzes => dep,
}) is post-initialized(anon method initialize-app(Cofra::App:D:) {
    .app = self for %.bizzes.values;
});

method app-class(Cofra::Main:D:) { Cofra::App }
