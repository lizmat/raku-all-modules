use v6;

unit module Sparrowdo::Core::DSL::Directory;

use Sparrowdo;

sub directory-create ( $path, %opts = %() ) is export {

    my %params = %opts;

    %params<path> = $path;
    %params<action> = 'create';

    task_run  %(
      task        => "create directory $path",
      plugin      => 'directory',
      parameters  => %params
    );

}

multi sub directory ( $path , %opts = %() ) is export { directory-create $path, %opts }

sub directory-delete ( $path ) is export {

    my %params = Hash.new;

    %params<path> = $path;
    %params<action> = 'delete';

    task_run  %(
      task        => "delete directory $path",
      plugin      => 'directory',
      parameters  => %params
    );

}


