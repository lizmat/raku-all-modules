Getting Started
===============

Prerequisites
-------------

* Latest stable version of Rakudo Star distribution which includes Rakudo Perl6 + Zef package manager. See http://rakudo.org/
* Latest stable version of Docker CE. See https://www.docker.com/

Installation and Setup
----------------------

Installation using `zef`::

   $ zef install Platform
   $ platform create

These will install Platform tool and launch proxy and dns services for you.

Command Line Usage
------------------

Output of `platform --help`::

   Usage:	platform COMMAND

   A tool for running projects through container environment programmatible way

   Options:
     -D, --debug              Enable debug mode
     -a, --data-path string   Location of resource files (default "/home/user/.platform")
     -d, --domain string      Domain address (default "localhost")
     -n, --network string     Network name (default "acme")

   Commands:
     attach      Attach to a running container through shell
     create      Start shared platform services
     destroy     Shutdown shared platform services
     remove      Initialize single project or environment with collection of projects
     rm          Remove stopped project or environment
     run         Initialize single project or environment with collection of projects
     ssh         Wrapper to ssh* commandds
     ssl         Wrapper to openssl command
     start       Start suspended project or environment
     stop        Stop suspended project or environment

   Run 'platform COMMAND --help' for more information on a command.

Verifying configuration
-----------------------

After running `platform create` command you should have 2-3 containers running depending which OS you have. For example on macOS `docker ps` output would be::

   $ platform create
   🚜 │ Services
      │ service/dns
      │ service/proxy

   $ docker ps
   CONTAINER ID        IMAGE                    COMMAND                  CREATED             STATUS              PORTS                NAMES
   283b41702bfb        jwilder/nginx-proxy      "/app/docker-entry..."   16 seconds ago      Up 17 seconds       0.0.0.0:80->80/tcp   platform-proxy
   8f9d8f55bc0c        zetaron/docker-dns-gen   "entrypoint generate"    29 seconds ago      Up 29 seconds       0.0.0.0:53->53/udp   platform-dns-out
   8c206594b27a        zetaron/docker-dns-gen   "entrypoint generate"    30 seconds ago      Up 30 seconds       53/udp               platform-dns-in

DNS configuration will need about always some manual configuration and this varies by OS and by what kind of configuration you have on your computer. Verify your configuration. For example on macOS output should be like this::

   $ ping proxy.localhost
   PING dns-in.localhost (127.0.0.1): 56 data bytes
   64 bytes from 127.0.0.1: icmp_seq=0 ttl=64 time=0.037 ms
   64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.071 ms
   ..
   $ ping dns-in.localhost
   PING dns-in.localhost (127.0.0.1): 56 data bytes
   64 bytes from 127.0.0.1: icmp_seq=0 ttl=64 time=0.037 ms
   64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.071 ms
   ..
   $ ping dns-out.localhost
   PING dns-in.localhost (127.0.0.1): 56 data bytes
   64 bytes from 127.0.0.1: icmp_seq=0 ttl=64 time=0.037 ms
   64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.071 ms
   ..

Note that `dnslookup` or `host` command may not give you correct answer. Although you can forcely check that dns working with `dnslookup proxy.localhost 127.0.0.1`.

Example project
---------------

Example projects are found on `examples/` directory, but here is simple example how to get started. Currently only docker containers are supported, but nothing prevents adding different container systems (or virtual machines) in the future.

1. Create Dockerfile under project dir ``project-butterfly/Dockerfile``::
      
      FROM nginx:alpine

#. Create ``project-butterfly/project.yml`` file::
      
      command: nginx -g 'daemon off;'
      volumes:
        - html:/usr/share/nginx/html:ro

#. Create ``project-butterfly/html/index.html`` file::

      <!DOCTYPE html>
      <html>
      <head><title>Project Butterfly 🦋 </title></head>
      <body>
      <h2>Welcome to Project Butterfly 🦋 </h2>
      <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc in libero dui. Curabitur eget iaculis ex. Nam pellentesque euismod augue, quis porttitor massa facilisis sit amet. Nulla a diam tempus augue pharetra congue.</p>
      </body>
      </html>

#. Start project::

      $ platform run project-dir

#. See what you've gained here and open browser to your project address http://project-butterfly.local


