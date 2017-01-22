use v6;

unit module Sparrowdo::Core::DSL::Template;

use Sparrowdo;

sub template-create ( $target, %opts = %() ) is export {

    my %params = %opts;

    %params<variables> = Hash.new unless %params<variables>:exists;

    %params<target> = $target;

    task_run  %(
      task        => "create template $target",
      plugin      => 'templater',
      parameters  => %params
    );

}

sub template ( $target , %opts = %() ) is export { template-create $target, %opts }



