use v6;

unit module Sparrowdo;

use Terminal::ANSIColor;

my %input_params = Hash.new;
my $target_os;
my @tasks = Array.new;
my @spl = Array.new;

sub push_task (%data){

  @tasks.push: %data;

  say colored('push task <' ~ %data<task> ~ '> plg <' ~ %data<plugin> ~ '> OK', 'bold green on_blue');

}

sub push_spl ($item){

  @spl.push: $item;

  say colored('push ' ~ $item ~ ' into SPL - OK', 'bold yellow on_cyan');

}

sub get_tasks () is export {
    @tasks
}

sub get_spl () is export {
    @spl
}

sub set_target_os ($os) is export  {
  $target_os = $os
}

sub target_os () is export  {
  return $target_os;
}

sub set_input_params (%args) is export  {

  for %args.kv -> $name, $value {
    %input_params.push($name => $value);
  }

}

sub input_params ($name) is export  {

  %input_params{$name};

}

sub set_spl(%args) is export { 
  for %args.kv -> $plg, $source {
    push_spl($plg ~ ' ' ~ $source);
  }
}

sub task_run(%args) is export { 

  my %task_data = %( 
      task => %args<task>,
      plugin => %args<plugin>,
      data => %args<parameters>
  );

  push_task %task_data;

}
 

sub module_run($name, %args = %()) is export {

  say colored('enter module <' ~ $name ~ '> ... ', 'bold cyan on_blue');

  require ::('Sparrowdo::' ~ $name); 
  ::('Sparrowdo::' ~ $name ~ '::&tasks')(%args);


}

