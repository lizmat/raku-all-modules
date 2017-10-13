# CommandLine::Usage

[![Build Status](https://travis-ci.org/7ojo/p6-commandline-usage.svg?branch=master)](https://travis-ci.org/7ojo/p6-commandline-usage) [![Build status](https://ci.appveyor.com/api/projects/status/l3i5vujymxpevn3u/branch/master?svg=true)](https://ci.appveyor.com/project/7ojo/p6-commandline-usage/branch/master)

Get alternative command line usage generated for you.

# Synopsis

Main:

    $ examples/docker --help
        
    Usage:	docker COMMAND

    A self-sufficient runtime for containers

    Options:
          --config string      Location of client config files (default "/Users/tojo/.docker")
      -D, --debug              Enable debug mode
          --help               Print usage
      -H, --host list          Daemon socket(s) to connect to
      -l, --log-level string   Set the logging level ("debug"|"info"|"warn"|"error"|"fatal") (default "info")
          --tls                Use TLS; implied by --tlsverify
          --tlscacert string   Trust certs signed only by this CA (default "/Users/tojo/.docker/ca.pem")
          --tlscert string     Path to TLS certificate file (default "/Users/tojo/.docker/cert.pem")
          --tlskey string      Path to TLS key file (default "/Users/tojo/.docker/key.pem")
          --tlsverify          Use TLS and verify the remote
      -v, --version            Print version information and quit

    Commands:
      attach      Attach local standard input, output, and error streams to a running container
      build       Build an image from a Dockerfile

    Run 'docker COMMAND --help' for more information on a command.

Subcommand:

    $ examples/docker attach --help

    Usage:	docker attach [OPTIONS] CONTAINER

    Attach local standard input, output, and error streams to a running container

    Options:
          --detach-keys        Override the key sequence for detaching a container
          --no-stdin           Do not attach STDIN
          --sig-proxy          Proxy all received signals to the process (default true)
      -h, --help bool          Print usage

## Projects

Listing of projects using the module:

- [Platform](https://github.com/7ojo/perl6-platform) (NOT YET -- Will be)
- [Mattermost::Bot](https://github.com/7ojo/p6-mattermost-bot) (NOT YET -- Will be)
- [Gitlab::Reminder](https://github.com/7ojo/perl6-gitlab-reminder) (NOT YET -- Will be)
