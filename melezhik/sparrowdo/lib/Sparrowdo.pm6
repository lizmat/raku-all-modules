use v6;

unit module Sparrowdo;

use Terminal::ANSIColor;

my %input_params = Hash.new;
my $target_os;
my @tasks = Array.new;
my @plugins = Array.new;
my @spl = Array.new;
my %config = Hash.new;

sub push_task (%data){

  @tasks.push: %data;

  say colored('push [task] ' ~ %data<task> ~  ' OK', 'bold green on_black');

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


multi sub task_run($task_desc, $plugin_name, %parameters?) is export { 
    task_run %(
      task          => "$task_desc" ~ " [plg] " ~ $plugin_name,
      plugin        => $plugin_name,
      parameters    => %parameters
    );
}

multi sub task_run(%args) is export { 

  my %task_data = %( 
      task => %args<task>,
      plugin => %args<plugin>,
      data => %args<parameters>
  );

  push_task %task_data;

}
 
multi sub task-run(%args) is export { 
  task_run %args
}

multi sub task-run($task_desc, $plugin_name, %parameters?) is export { 
  task_run $task_desc, $plugin_name, %parameters
}

sub plg-list() is export {
  @plugins;
}

multi sub plg-run($plg) is export {
  plg-run([$plg])
}

multi sub plg-run(@plg-list) is export {

  for @plg-list -> $p {
    if $p ~~ /(\S+)\@(.*)/ {
      my $name = $0; my $params = $1;
      my @args = split(/\,/,$params);
      @plugins.push: [ $name,  @args ];
      say colored('push [plugin] ' ~ $name ~  ~ ' ' ~ @args ~ ' OK', 'bold green on_black');
    } else {
      @plugins.push: [ $p ];
      say colored('push [plugin] ' ~ $p ~  ' OK', 'bold green on_black');
    }
  }
}

sub module_run($name, %args = %()) is export {

  say colored('enter module <' ~ $name ~ '> ... ', 'bold cyan on_black');

  if ( $name ~~ /(\S+)\@(.*)/ ) {
      my $mod-name = $0; my $params = $1;
      my %mod-args;
      for split(/\,/,$params) -> $p { %mod-args{$0.Str} = $1.Str if $p ~~ /(\S+?)\=(.*)/ };
      require ::('Sparrowdo::' ~ $mod-name); 
      ::('Sparrowdo::' ~ $mod-name ~ '::&tasks')(%mod-args);
  } else {
      require ::('Sparrowdo::' ~ $name); 
      ::('Sparrowdo::' ~ $name ~ '::&tasks')(%args);
  }


}

sub config() is export { 
  %config 
}

sub config_set( %data = %()) is export { 
  %config = %data
}
