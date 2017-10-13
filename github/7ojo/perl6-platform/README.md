# Platform Project Development

[![Build Status](https://travis-ci.org/7ojo/perl6-platform.svg?branch=master)](https://travis-ci.org/7ojo/perl6-platform) [![Build status](https://ci.appveyor.com/api/projects/status/ijwor42w8i47d6lf/branch/master?svg=true)](https://ci.appveyor.com/project/7ojo/perl6-platform/branch/master)

## Demo

Nginx and OpenLDAP projects configured to work together through platform tool 

See environment file: ```examples/02-environment/nginx-ldap.yml```

![Demo-Nginx-LDAP](demo/platform-nginx-ldap.gif)

## Table of contents

  * [Overview](#overview)
    * [Features](#features)
    * [Synopsis](#synopsis)
    * [Installation and setup](#installation-and-setup)
    * [Example project setup](#example-project-setup)
    * [Advanced setup](#advanced-setup)
  * [Using on Linux OS](#using-on-linux-os)
    * TODO: Should be no brainer, but add some notes
  * [Using on Mac OS](#using-on-mac-os)
     * [Prerequisites](#prerequisites)
        * [Perl6 2017.01 or newer](#perl6-201701-or-newer)
        * [Docker 17 or newer](#docker-17-or-newer)
     * [Install Platform tool](#install-platform-tool)
     * [Platform Services](#platform-services)
     * [Running environments](#running-environments)
     * [Attaching to inside containers](#attaching-to-inside-containers)
     * [DNS Configuration](#dns-configuration)
  * [Using on Windows OS](#using-on-windows-os)
     * [Prerequisites](#prerequisites-1)
     * [Install platform tool](#install-platform-tool-1)
     * [Platform services](#platform-services-1)
     * [Running environments](#running-environments-1)
     * [Attaching to inside containers](#Attaching-to-inside-containers-1)
     * [DNS configuration](#dns-configuration-1)
  * [Contributing](#contributing)
     * [Tools](#tools)
  * [General todo and known issues](#todo-and-known-issues)
  * [Misc notes](#misc-notes)
  * [References](#references)

## Overview

Imagine that you can just start complex environments for your team members with just couple of commands and with predefined setup. If someone messes up the configuration then just restart and everythings is fine.

So in short the `platform` command is a development tool for managing and running single projects or tightly coupled projects via container environment. In a long run aims to be kind of swiss army knife for configuring different like development environments.

With this tool you can configure container with single yaml file and you get configured development environment running instantly. Host files can be mounted inside where you want so you see live changes in your environment or you can override configuration to spesific needs without touching the original code coming from code repository. Everything is configurable what is happening inside containers.

Of course everyhing what this tool does can be done using basic shell commands and wizardry, but in the long run it will be cumbersome when handling multiple projects and more if there are some how related to each other.

Similar projects which you may want to look at:

* [Nut: the development environment, containerized](https://github.com/matthieudelaro/nut)

### Features

* Auto configuring DNS server [1]
* Auto configuring HTTP proxy server [2]
* Generation and usage of SSL RSA keys
* Generation and usage of SSH authentication keys
* Start/stop projects with project specific configuration
* Support for basic containers and more cumbersome systemd containers
* Creating/mounting/overriding files inside project container

### Synopsis

    $ platform ssl genrsa
    $ platform ssh keygen
    $ platform create
    $ platform --environment my-projects.yml run|start|stop|rm
    $ platform --project=butterfly-project/ run|start|stop|rm
    $ platform destroy

### Installation and Setup

    $ zef install Platform
    $ platform create

Now add 127.0.0.1 as your DNS server to use platform's DNS server e.g

    $ vim /etc/resolv.conf

Note: Project's DNS name is constructed from folder name and domain which defaults to ```.local``` and can be changed from command line ```<project-folder-name>.<tld>``` e.g. ```project-butterfly.local```

### Example project setup

Everything and more is seen in test files under t/ directory, but here is simple example how to get started. Currently only docker containers are supported, but nothing prevents adding different container systems (or virtual machines).

 1. Create ```Dockerfile``` under project dir if you don't already have

    project-butterfly/Dockerfile

        FROM nginx:alpine

 2. Create ```project.yml``` file

    project-butterfly/project.yml

    ```yaml
    command: nginx -g 'daemon off;'
    volumes:
        - html:/usr/share/nginx/html:ro
    ```

 3. Create ```index.html``` file to show off

    project-butterfly/html/index.html

    ```html
    <!DOCTYPE html>
    <html>
    <head><title>Project Butterfly 🦋 </title></head>
    <body>
    <h2>Welcome to Project Butterfly 🦋 </h2>
    <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc in libero dui. Curabitur eget iaculis ex. Nam pellentesque euismod augue, quis porttitor massa facilisis sit amet. Nulla a diam tempus augue pharetra congue.</p>
    </body>
    </html>
    ```

 4. Start platform services. This is done only once, because these services are shared between containers

    ```$ platform create```

 5. Start project

    ```$ platform --project=project-butterfly/ run```

 5. See what you've gained here. Open browser to your project address

    [http://localhost](http://localhost)

    OR if you have configured platform DNS server to your host then you can use DNS names

    [http://project-butterfly.local](http://project-butterfly.local)

### Advanced setup

When you have tightly coupled projects you may want configure those "single" projects to somekind of shared environment, and then platform tool's environment support kicks in. Steps are:

 1. You have already configured your projects with ```project.yml``` file

 2. Create your environment file e.g ```my-environment.yml```

    ```yaml
    # First project. No changes to project configuration just start the project.
    project-butterfly: true

    # Second project. Make changes to project default configuration
    project-snail:
      files:
        /var/www/app/config:
          volume: true
          readonly: true
          content: |
          <?php
            $hello = "こんにちは!";
    ```

 3. Start platform services if not yet started

    ```$ platform create```

 4. Start your environment

    ```$ platform --environment=my-environment.yml run```

 5. Open projects in a browser

    * [http://project-butterfly.local](http://project-snail.local)
    * [http://project-snail.local](http://project-snail.local)

## Using on Linux OS

## Using on Mac OS

### Prerequisites

#### Latest perl 6

Go to http://rakudo.org/how-to-get-rakudo/ and follow the installation instructions

    $ perl6 -v
    This is Rakudo version 2017.01 built on MoarVM version 2017.01
    implementing Perl 6.c.

#### Docker 17 or newer

Go to https://docs.docker.com/docker-for-mac/install/ and follow the installation instructions

    docker -v
    Docker version 17.03.1-ce, build c6d412e

### Install platform tool

    $ zef install Platform
    $ platform
    Usage:
      platform [--network=<Str>] [--domain=<Str>] [--data-path=<Str>] create -- Start shared platform services
      platform [--network=<Str>] [--domain=<Str>] [--data-path=<Str>] destroy -- Shutdown shared platform services
      platform [--project=<Str>] [--network=<Str>] [--domain=<Str>] [--data-path=<Str>] run -- Initialize and run single project
      platform [--project=<Str>] [--data-path=<Str>] start -- Start suspended project
      platform [--project=<Str>] [--data-path=<Str>] stop -- Stop running project
      platform [--project=<Str>] [--data-path=<Str>] rm -- Remove stopped project
      platform [--environment=<Str>] [--network=<Str>] [--domain=<Str>] [--data-path=<Str>] run -- Initialize and run environment
      platform [--environment=<Str>] [--data-path=<Str>] start -- Start suspended environment
      platform [--environment=<Str>] [--data-path=<Str>] stop -- Stop running environment
      platform [--environment=<Str>] [--data-path=<Str>] rm -- Remove stopped environment
      platform [--domain=<Str>] [--data-path=<Str>] ssl genrsa -- Generation of RSA Private Key
      platform [--domain=<Str>] [--data-path=<Str>] ssh keygen -- Generation of authentication keys

### Platform services

This can take a while, because of fetching container files from docker hub.

    $ platform create
    ...
    $ docker ps
    CONTAINER ID        IMAGE                    COMMAND                  CREATED              STATUS              PORTS                         NAMES
    9af9923ebb11        jwilder/nginx-proxy      "/app/docker-entry..."   26 seconds ago       Up 24 seconds       0.0.0.0:80->80/tcp, 443/tcp   platform-proxy
    6059d2c36f59        zetaron/docker-dns-gen   "entrypoint generate"    About a minute ago   Up About a minute   0.0.0.0:53->53/udp            platform-dns

### Running environments

TODO: Make environment example under examples/

### Attaching to inside containers

TODO: Example usages how to attach and how check that dns resolves correctly
    
### DNS configuration

Create own DNS resolver for *.localhost addresses:

    sudo sh -c 'echo "nameserver 127.0.0.1" > /etc/resolver/localhost'

## Using on Windows OS

### Prerequisites

Note: It seems that its better to use PowerShell for running these console commands.

#### Get the latest perl 6

Go to http://rakudo.org/how-to-get-rakudo/ and follow the installation instructions

    $ perl6 -v
    This is Rakudo version 2017.04.3 built on MoarVM version 2017.04-53-g66c6dda
    implementing Perl 6.c.

#### Install Git for Windows

#### Download and install Docker Toolbox 

You'll need docker toolbox especially for Windows Home, because it is missing HyperV. Toolbox uses Oracle's VirtualBox which is perfectly fine for us.

Go to https://www.docker.com/products/docker-toolbox and follow the installation instructions

    docker -v
    Docker version 17.05.0-ce, build 89658be

### Install platform tool

    $ zef install Platform
    $ platform
    Usage:
      platform [--network=<Str>] [--domain=<Str>] [--data-path=<Str>] create -- Start shared platform services
      platform [--network=<Str>] [--domain=<Str>] [--data-path=<Str>] destroy -- Shutdown shared platform services
      platform [--project=<Str>] [--network=<Str>] [--domain=<Str>] [--data-path=<Str>] run -- Initialize and run single project
      platform [--project=<Str>] [--data-path=<Str>] start -- Start suspended project
      platform [--project=<Str>] [--data-path=<Str>] stop -- Stop running project
      platform [--project=<Str>] [--data-path=<Str>] rm -- Remove stopped project
      platform [--environment=<Str>] [--network=<Str>] [--domain=<Str>] [--data-path=<Str>] run -- Initialize and run environment
      platform [--environment=<Str>] [--data-path=<Str>] start -- Start suspended environment
      platform [--environment=<Str>] [--data-path=<Str>] stop -- Stop running environment
      platform [--environment=<Str>] [--data-path=<Str>] rm -- Remove stopped environment
      platform [--domain=<Str>] [--data-path=<Str>] ssl genrsa -- Generation of RSA Private Key
      platform [--domain=<Str>] [--data-path=<Str>] ssh keygen -- Generation of authentication keys

### Platform services

This can take a while, because of fetching container files from docker hub.

    $ platform create
    ...
    $ docker ps
    CONTAINER ID        IMAGE                    COMMAND                  CREATED             STATUS              PORTS                NAMES
    fabe43bf44bf        jwilder/nginx-proxy      "/app/docker-entry..."   5 minutes ago       Up 5 minutes        0.0.0.0:80->80/tcp   platform-proxy
    6a8d7a645967        zetaron/docker-dns-gen   "entrypoint generate"    5 minutes ago       Up 5 minutes        0.0.0.0:53->53/udp   platform-dns-out
    35241df24a3f        zetaron/docker-dns-gen   "entrypoint generate"    5 minutes ago       Up 5 minutes        53/udp               platform-dns-in

### Running environments

TODO: Make environment example under examples/

### Attaching to inside containers

TODO: Example usages how to attach and how check that dns resolves correctly
    
### DNS configuration

NOTE: You may have to disable IPV6

Addresses won't work out of the box so we have to circumvent little bit. Set up port forwarding on VirtualBox side from localhost to virtual machine.

  * Go to VirtualBox -> Your BOX -> Settings -> Network ->
  * Choose NAT
  * Open Advanced
  * Click Port Forwarding
  * Add rule for DNS 53/UDP from 127.0.0.1/localhost
  * Add rule for HTTP 80/TCP from 127.0.0.1/localhost
  * Click OK, OK

Set up your network connection to use 127.0.0.1 address as DNS server. Test DNS resolving with ´nslookup´ and ´ping´ commands:

  * nslookup google.fi
  * ping google.fi
  * nslookup proxy.localhost
    (should resolve to 127.0.0.1)
  * ping proxy.localhost
    (should ping to 127.0.0.1)
 
## Contributing

### Tools

  * grip for previewing e.g. README.md https://github.com/joeyespo/grip

## General todo and known issues

* General: Add `git clone ..` function on environment files for easy start
* General: No feedback on e.g. build phase when it can take a long time on fetching things
* macOS: There is no bridge between host and containers. This can help https://github.com/mal/docker-for-mac-host-bridge
* macOS: If not bridging the networks you'll need local DNS server to point default ```*.localhost``` address to 127.0.0.1 (```brew install dnsmasq``` and so on)
* Windows: Ability to make port forwardings and settings through platform

## Remarks

* Use ```--domain=whateveryouwant``` option on commandline to have different TLD on DNS names so can group/differentiate your environments more easily

## References

1. [zetaron/docker-dns-gen](//github.com/zetaron/docker-dns-gen)
2. [jwilder/docker-gen](//github.com/jwilder/docker-gen)
