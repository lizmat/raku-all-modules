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

multi sub http-ok ( $url, %args? ) is export {

  my $host = input_params('Host');

  my $curl-cmd = "curl -fsSLk -D - --retry 3 $url";

  $curl-cmd ~= ":%args<port>" if %args<port>;
  $curl-cmd ~= "%args<path>"  if %args<path>;
  $curl-cmd ~= " --noproxy $host" if %args<no-proxy>;

  my %bash-args =  %( debug => True );

  if %args<has-content> {
    %bash-args<expect_stdout> = %args<has-content> 
  } else {
    $curl-cmd ~= " -o /dev/null"
  }

  bash $curl-cmd, %bash-args;

}

multi sub http-ok () is export {

  my $host = input_params('Host');

  http-ok($host);

}

multi sub http-ok ( %args ) is export {

  my $host = input_params('Host');

  http-ok($host, %args);

}


