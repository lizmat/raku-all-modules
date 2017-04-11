# Platform Project Development
[![Build Status](https://travis-ci.org/7ojo/perl6-platform.svg?branch=master)](https://travis-ci.org/7ojo/perl6-platform)

Platform command is a development tool for managing and running single projects or tightly coupled projects via container environment. In a long run aims to be kind of swiss army knife for configuring different like development environments.

With this tool you can configure container with single yaml file and you get configured development environment running instantly. Host files can be mounted inside where you want so you see live changes in your environment or you can override configuration to spesific needs without touching the original code coming from code repository. Everything is configurable what is happening inside containers.

Of course everyhing what this tool does can be done using basic shell commands and wizardry, but in the long run it will be cumbersome when handling multiple projects and more if there are some how related to each other.

Similar projects:

* [Nut: the development environment, containerized](https://github.com/matthieudelaro/nut)

# Features

* Auto configuring DNS server [1]
* Auto configuring HTTP proxy server [2]
* Generation and usage of SSL RSA keys
* Generation and usage of SSH authentication keys
* Start/stop projects with project specific configuration
* Support for basic containers and more cumbersome systemd containers
* Creating/mounting/overriding files inside project container

# Synopsis

    $ platform ssl genrsa
    $ platform ssh keygen
    $ platform create
    $ platform --environment my-projects.yml run|start|stop|rm
    $ platform --project=butterfly-project/ run|start|stop|rm
    $ platform destroy

# Installation and Setup

    $ zef install Platform
    $ platform create

Now add 127.0.0.1 as your DNS server to use platform's DNS server e.g

    $ vim /etc/resolv.conf

Note: Project's DNS name is constructed from folder name and domain which defaults to ```.local``` and can be changed from command line ```<project-folder-name>.<tld>``` e.g. ```project-butterfly.local```

# Example project setup

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

# Advanced setup

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

# Todo / Known issues

* General: No feedback on e.g. build phase when it can take a long time on fetching things
* macOS: There is no bridge between host and containers. This can help https://github.com/mal/docker-for-mac-host-bridge
* macOS: If not bridging the networks you'll need local DNS server to point default ```*.localhost``` address to 127.0.0.1 (```brew install dnsmasq``` and so on)

# Remarks

* Use ```--domain=whateveryouwant``` option on commandline to have different TLD on DNS names so can group/differentiate your environments more easily

# References

1. [zetaron/docker-dns-gen](//github.com/zetaron/docker-dns-gen)
2. [jwilder/docker-gen](//github.com/jwilder/docker-gen)
