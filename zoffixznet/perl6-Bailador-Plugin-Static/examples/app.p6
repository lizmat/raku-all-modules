use lib '../lib';
use Bailador;
use Bailador::Plugin::Static;

Bailador::Plugin::Static.install: app;

baile;

# Assets in the ./assets/ directory will now be available
# At http://localhost:3000/assets/camelia.png
# and http://localhost:3000/assets/style.css
