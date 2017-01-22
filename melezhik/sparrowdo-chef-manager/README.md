# SYNOPSIS

Sparrowdo module to manage chef users.

WARNING! --- This soft is far from being ideal, but at least some functions work for me.


# Install

    $ panda install Sparrowdo::Chef::Manager

# Usage

NOTE! An assumption is made that _chef server_ runs at the same host where sparrow client runs,
as under the hood this module uses `chef-server-ctl` command. 

Chef::Manager module exposes two commands to create/remove chef users.

## Delete user

    module_run 'Chef::Manager', %(
      action => 'delete-user',
      user-id => 'alexey',
    );

## Create user
    
    module_run 'Chef::Manager', %(
      action => 'create-user',
      user-id => 'alexey',
      email => 'sparrow.hub@gmail.com',
      name => 'Alexey',
      last-name => 'Melezhik',
      password => '123456',
      org => 'devops'
    );
    
## Add user to organization

    module_run 'Chef::Manager', %(
      action  => 'add-to-org',
      user-id => 'alexey',
      org     => 'IT'
    );

# Parameters

## action

One of two - `create-user|delete-user|add-to-org`.

## user-id 

A chef user ID.

## password

A chef user password.

## org

Chef server organization. This one is optional, no default value.
If `org` parameter is set, then `create-user` action will add a new user to chef organization.

## name

A user name, this one is obligatory.

## last-name

A user last-name, this one is obligatory.

## email

A user email, this one is obligatory.

# Author

[Alexey Melezhik](mailto:melezhik@gmail.com)

# See also

* [SparrowDo](https://github.com/melezhik/sparrowdo)
* [chef-server-ctl (executable)](https://docs.chef.io/ctl_chef_server.html)
