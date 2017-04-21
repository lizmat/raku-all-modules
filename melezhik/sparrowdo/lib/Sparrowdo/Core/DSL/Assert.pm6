use v6;

unit module Sparrowdo::Core::DSL::Assert;

use Sparrowdo;
use Sparrowdo::Core::DSL::Bash;

multi sub proc-exists ( $proc, %params ) is export {

    my %args = Hash.new;

    %args<pid_file>   = %params<pid_file>     if %params<pid_file>:exists;
    %args<pid_file>   = %params<pid-file>     if %params<pid-file>:exists;
    %args<footprint>  = %params<footprint>    if %params<footprint>:exists;

    task_run  %(
      task        => "check $proc process",
      plugin      => 'proc-validate',
      parameters  => %args
    );
    
}

multi sub proc-exists ( $proc ) is export {
  proc-exists $proc, %( pid-file => "/var/run/$proc" ~ '.pid' )
}

sub proc-exists-by-pid ( $proc, $pid-file ) is export {
  proc-exists $proc, %( pid-file => $pid-file )
}

sub proc-exists-by-footprint ( $proc, $fp ) is export {
  proc-exists($proc, %( footprint => $fp ))
}

sub http-ok ( $url ) is export {

  bash "curl -fsSLk -o /dev/null -D - $url", %( debug => True );

}

