use v6;

use lib './lib';

use Web::App::Ballet;

use-template6 './test/views';

## The main page.
get '/' => sub ($c)
{
  $c.content-type: 'text/plain';
  my $name = $c.get(:default<World>, 'name');
  $c.send("Hello $name");
}

## A path with a placeholder.
get '/test/:name' => sub ($c)
{
  my $who = $c.get(':name');
  ### There is a bug, we should be able to do the following line:
  #template 'help', :$who;
  ### But until implicit content is working again, we have to use this:
  $c.send(template('help', :$who));
}

## The default response if nothing else matches.
get '*' => sub ($c)
{
  $c.content-type: 'text/plain';
  $c.send("Web::App::Ballet test script.");
}

dance;

