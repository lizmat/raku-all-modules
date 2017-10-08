use v6;

unit module Sparrowdo::Ruby::Bundler;

use Sparrowdo;

our sub tasks (%args) {

  my %envvars = Hash.new;

  %envvars<http_proxy> = input_params('HttpProxy') if input_params('HttpProxy').defined;
  %envvars<https_proxy> = input_params('HttpsProxy') if input_params('HttpsProxy').defined;
  
  my $cmd = 'cd ' ~ %args<gemfile_dir>;

  $cmd ~= ' bundle install';

  $cmd ~= %args<verbose> ?? ' --verbose' !! ' --quiet';
   
  $cmd ~= ' --path ' ~ %args<path> if %args<path>.defined;

  my %parameters = Hash.new;

  %parameters<user> = %args<user> if %args<user>.defined;

  %parameters<debug> = %args<debug> if %args<debug>.defined;

  %parameters<command> = $cmd;

  %parameters<envvars> = %envvars;


  task_run %(
    task  => "bundle install",
    plugin  => "bash",
    parameters => %parameters,
  );
  
}

