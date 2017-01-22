use v6;

unit module Sparrowdo::Core::DSL::File;

use Sparrowdo;

sub file-create ( $target, %opts = %() ) is export {

    my %params = %opts;

    %params<target> = $target;
    %params<action> = 'create';

    task_run  %(
      task        => "create file $target",
      plugin      => 'file',
      parameters  => %params
    );

}

multi sub file ( $target , %opts = %() ) is export { file-create $target, %opts }

sub file-delete ( $target ) is export {

    my %params = Hash.new;

    %params<target> = $target;
    %params<action> = 'delete';

    task_run  %(
      task        => "delete file $target",
      plugin      => 'file',
      parameters  => %params
    );

}


