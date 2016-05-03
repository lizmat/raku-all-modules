use lib '../lib';
use Bailador;
use Bailador::Plugin::Static;
use Bailador::Template::Mojo::Extended;

app.location = '.';
renderer Bailador::Template::Mojo::Extended.new;

get '/'      => sub { template 'index.tt', :name<Zoffix> };
get '/email' => sub { template 'email.tt', 'Znet', :name<Zoffix> };

baile;