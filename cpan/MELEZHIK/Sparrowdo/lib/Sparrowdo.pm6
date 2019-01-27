use v6;

unit module Sparrowdo:ver<0.0.45>;

use Terminal::ANSIColor;
use Data::Dump;

my %input_params = Hash.new;
my $target_os; my $target_hostname;
my @tasks = Array.new;
my @plugins = Array.new;
my @spl = Array.new;
my %config = Hash.new;

sub push_task (%data){

  @tasks.push: %data;

  unless input_params('QuietMode') {
    term-out('push [task] ' ~ %data<task> ~  ' OK', input_params('NoColor'), %( colors => 'bold green on_black' ));
  }
}

sub push_spl ($item){

  @spl.push: $item;

  unless input_params('QuietMode') {
    term-out('push ' ~ $item ~ ' into SPL - OK', input_params('NoColor'), %( colors => 'bold yellow on_cyan' ));
  }
}

sub get_tasks () is export {
    term-out(Dump(@tasks)) if %*ENV<SPARROWDO-DEBUG>;
    @tasks;
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

sub set_target_hostname ($hostname) is export  {
  $target_hostname = $hostname
}

sub target_hostname () is export  {
  return $target_hostname;
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

sub swat-task-run($task_desc, $plugin_name,%args) is export { 

  my %task_data = %( 
      task => $task_desc,
      plugin => $plugin_name,
      host => %args<host>,
      data => %(),
      type => "swat"      
  );

  push_task %task_data;

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
      unless input_params('QuietMode') {
        term-out('push [plugin] ' ~ $name ~  ~ ' ' ~ @args ~ ' OK', input_params('NoColor'), %( colors => 'bold green on_black' ));
      }
    } else {
      @plugins.push: [ $p ];
      unless input_params('QuietMode') {
        term-out('push [plugin] ' ~ $p ~  ' OK', input_params('NoColor'), %( colors => 'bold green on_black' ));
      }
    }
  }
}

sub module_run($name, %args = %()) is export {

      unless input_params('QuietMode') {
        term-out('enter module <' ~ $name ~ '> ... ', input_params('NoColor'), %( colors => 'bold cyan on_black' ));
      }

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

multi sub runtime-vars-set ( $var ) is export {
   runtime-vars-set( [ $var ] )
}

multi sub runtime-vars-set ( @vars ) is export {
  for @vars -> $var {
    my %hash = $var.split( "=" );
    for %hash.kv -> $key, $val {
      %config{$key} = $val
    }
  }
}


multi sub term-out ($line) is export {
  term-out($line,True)
}

multi sub term-out ($line,$no-color-mod,%args?) is export {
    if $no-color-mod {
      say $line;
    } else {
      say colored($line, %args<colors>);
    }
}



