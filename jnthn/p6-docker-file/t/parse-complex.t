use Docker::File;
use Test;

# Tests here are taken from various examples in Docker documentation.

subtest {
    my $file = Docker::File.parse: q:to/DOCKER/;
        # Nginx
        #
        # VERSION               0.0.1
        FROM      ubuntu
        MAINTAINER Victor Vieux <victor@docker.com>

        LABEL Description="This image is used to start the foobar executable" Vendor="ACME Products" Version="1.0"
        RUN apt-get update && apt-get install -y inotify-tools nginx apache2 openssh-server
        DOCKER
    is $file.images.elems, 1, 'Parsed successfully';
    is $file.images[0].from, 'ubuntu', 'Correct .from';
    is $file.images[0].instructions.elems, 3, '3 instructions';
    is $file.images[0].instructions.map(*.instruction),
        (Docker::File::InstructionName::MAINTAINER,
         Docker::File::InstructionName::LABEL,
         Docker::File::InstructionName::RUN),
        'Correct instruction types';
}, 'Nginx example';

subtest {
    my $file = Docker::File.parse: q:to/DOCKER/;
        # Firefox over VNC
        #
        # VERSION               0.3

        FROM ubuntu

        # Install vnc, xvfb in order to create a 'fake' display and firefox
        RUN apt-get update && apt-get install -y x11vnc xvfb firefox
        RUN mkdir ~/.vnc
        # Setup a password
        RUN x11vnc -storepasswd 1234 ~/.vnc/passwd
        # Autostart firefox (might not be the best way, but it does the trick)
        RUN bash -c 'echo "firefox" >> /.bashrc'

        EXPOSE 5900
        CMD    ["x11vnc", "-forever", "-usepw", "-create"]
        DOCKER
    is $file.images.elems, 1, 'Parsed successfully';
    is $file.images[0].from, 'ubuntu', 'Correct .from';
    is $file.images[0].instructions.elems, 6, '3 instructions';
    is $file.images[0].instructions.map(*.instruction),
        (Docker::File::InstructionName::RUN,
         Docker::File::InstructionName::RUN,
         Docker::File::InstructionName::RUN,
         Docker::File::InstructionName::RUN,
         Docker::File::InstructionName::EXPOSE,
         Docker::File::InstructionName::CMD),
        'Correct instruction types';
}, 'Firefox over VNC example';

subtest {
    my $file = Docker::File.parse: q:to/DOCKER/;
        # Multiple images example
        #
        # VERSION               0.1

        FROM ubuntu
        RUN echo foo > bar
        # Will output something like ===> 907ad6c2736f

        FROM ubuntu
        RUN echo moo > oink
        # Will output something like ===> 695d7793cbe4

        # You᾿ll now have two images, 907ad6c2736f with /bar, and 695d7793cbe4 with
        # /oink.
        DOCKER
    is $file.images.elems, 2, 'Parsed two images successfully';
    is $file.images[0].from, 'ubuntu', 'Correct .from in first image';
    is $file.images[0].instructions.elems, 1, 'One instruction in first image';
    is $file.images[0].instructions[0].command, 'echo foo > bar',
        'Instruction in first image has correct command';
    is $file.images[1].from, 'ubuntu', 'Correct .from in first image';
    is $file.images[1].instructions.elems, 1, 'One instruction in first image';
    is $file.images[1].instructions[0].command, 'echo moo > oink',
        'Instruction in second image has correct command';
}, 'Multiple images example';

done-testing;
