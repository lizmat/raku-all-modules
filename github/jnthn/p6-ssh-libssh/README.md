# SSH::LibSSH

An asynchronous Perl 6 binding to LibSSH. So far it only supports client
operations, and even then only some of those. It implements:

* Connecting to SSH servers, performing server authentication and client
  authentication (by default, using a running key agent or the current user's
  private key; you can also provide a private key file or a password)
* Executing commands, sending stdin, reading stdout/stderr, and getting the
  exit code
* Port forwarding
* Reverse port forwarding
* Single file SCP in either direction

See the `examples` directory for a set of examples to illustrate usage of the
module.

All operations are asynchronous, and the interface to the module is expressed
in terms of the Perl 6 `Promise` and `Supply` types.

On Linux, install libssh with your package manager to use this module. On
Windows, the installation of this module will download a pre-built libssh.dll,
so just install the module and you're good to go.

Pull requests to add missing features, or better documentation, are welcome.
Please file bug reports or feature requests using GitHub Issues.
