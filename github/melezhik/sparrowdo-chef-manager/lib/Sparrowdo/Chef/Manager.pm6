use v6;

unit module Sparrowdo::Chef::Manager;

use Sparrowdo;

our sub tasks (%args) {

  my $action = %args<action>;
 
  if $action eq 'create-user' {

    my @params = Array.new;

    # check parameters

    for 'user-id', 'name', 'email', 'password' -> $p {
      die "$p is required" unless %args{$p};
    }

    @params.push: '-o ' ~ %args<org> if %args<org>;
    @params.push: %args<user-id>;
    @params.push: %args<name>;
    @params.push: '""';
    @params.push: %args<last-name>||'""';
    @params.push: %args<email>;
    @params.push: %args<password>;
    


    task_run %(
      task    => "create chef user",
      plugin  => "bash",
      parameters => %(
        command => 'chef-server-ctl user-create --verbose ' ~ (@params.join(' ')) ~ ' ; echo',
        expect_stdout => '(User\s+\S+\s+already\s+exists|BEGIN\s+RSA\s+PRIVATE\s+KEY)',
        debug => %args<debug> || False
      )
    );
  
  } elsif $action eq 'add-to-org' {

    for 'user-id', 'org' -> $p {
      die "$p is required" unless %args{$p};
    }

    task_run %(
      task    => "add chef user to organization",
      plugin  => "bash",
      parameters => %(
        command => 'chef-server-ctl org-user-add --verbose  ' ~ %args<org> ~  ' ' ~ %args<user-id>,
        debug => %args<debug> || False
      )
    );

  } elsif $action eq 'delete-user' {

    # check parameters

    die "user-id is required" unless %args<user-id>;

    task_run %(
      task    => "delete chef user",
      plugin  => "bash",
      parameters => %(
        command => 'chef-server-ctl  user-delete --verbose -R -y --print-after '  ~ %args<user-id> ~ ' ; echo ',
        debug => %args<debug> || False
      )
    );

  }

}

