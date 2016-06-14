use lib '../lib';
use Bailador;
use Bailador::Plugin::Static;

Bailador::Plugin::Static.install: app;

baile;
