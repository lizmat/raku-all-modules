use Docker::File;
use Test;

is
    Docker::File.new(
        images => [
            Docker::File::Image.new(
                from-short => 'ubuntu'
            )
        ]
    ),
    q:to/EXPECTED/, 'simple file with FROM';
        FROM ubuntu
        EXPECTED

is
    Docker::File.new(
        images => [
            Docker::File::Image.new(
                from-short => 'ubuntu',
                from-tag => 'latest'
            )
        ]
    ),
    q:to/EXPECTED/, 'simple file with FROM with tag';
        FROM ubuntu:latest
        EXPECTED

is
    Docker::File.new(
        images => [
            Docker::File::Image.new(
                from-short => 'ubuntu',
                from-digest => 'sha256:cbbf2f9a99b47fc460d422812b6a5adff7dfee951d8fa2e4a98caa0382cfbdbf'
            )
        ]
    ),
    q:to/EXPECTED/, 'simple file with FROM with digest';
        FROM ubuntu@sha256:cbbf2f9a99b47fc460d422812b6a5adff7dfee951d8fa2e4a98caa0382cfbdbf
        EXPECTED

sub simple-image(Docker::File::Instruction $ins) {
    Docker::File.new(
        images => [
            Docker::File::Image.new(
                from-short => 'ubuntu',
                entries => [$ins]
            )
        ]
    )
}

is
    simple-image(Docker::File::Maintainer.new(name => 'Jonathan <jnthn@jnthn.net>')),
    q:to/EXPECTED/, 'MAINTAINER';
        FROM ubuntu
        MAINTAINER Jonathan <jnthn@jnthn.net>
        EXPECTED

is
    simple-image(Docker::File::RunShell.new(command => 'sudo apt-get install perl6')),
    q:to/EXPECTED/, 'RUN (shell)';
        FROM ubuntu
        RUN sudo apt-get install perl6
        EXPECTED

is
    simple-image(Docker::File::RunExec.new(args => <sudo apt-get install perl6>)),
    q:to/EXPECTED/, 'RUN (exec)';
        FROM ubuntu
        RUN ["sudo", "apt-get", "install", "perl6"]
        EXPECTED

is
    simple-image(Docker::File::RunExec.new(
        args => ['"quoted"', "with\newline", "and \\slash"])),
    q:to/EXPECTED/, 'RUN (exec, quotes/escaping)';
        FROM ubuntu
        RUN ["\"quoted\"", "with\newline", "and \\\\slash"]
        EXPECTED

is
    simple-image(Docker::File::CmdShell.new(command => 'perl6 app.p6')),
    q:to/EXPECTED/, 'CMD (shell)';
        FROM ubuntu
        CMD perl6 app.p6
        EXPECTED

is
    simple-image(Docker::File::CmdExec.new(args => <perl6 app.p6>)),
    q:to/EXPECTED/, 'CMD (exec)';
        FROM ubuntu
        CMD ["perl6", "app.p6"]
        EXPECTED

is
    simple-image(Docker::File::CmdExec.new(
        args => ['"quoted"', "with\newline", "and \\slash"])),
    q:to/EXPECTED/, 'CMD (exec, quotes/escaping)';
        FROM ubuntu
        CMD ["\"quoted\"", "with\newline", "and \\\\slash"]
        EXPECTED

is
    simple-image(Docker::File::EntryPointShell.new(command => 'perl6 app.p6')),
    q:to/EXPECTED/, 'ENTRYPOINT (shell)';
        FROM ubuntu
        ENTRYPOINT perl6 app.p6
        EXPECTED

is
    simple-image(Docker::File::EntryPointExec.new(args => <perl6 app.p6>)),
    q:to/EXPECTED/, 'ENTRYPOINT (exec)';
        FROM ubuntu
        ENTRYPOINT ["perl6", "app.p6"]
        EXPECTED

is
    simple-image(Docker::File::EntryPointExec.new(
        args => ['"quoted"', "with\newline", "and \\slash"])),
    q:to/EXPECTED/, 'ENTRYPOINT (exec, quotes/escaping)';
        FROM ubuntu
        ENTRYPOINT ["\"quoted\"", "with\newline", "and \\\\slash"]
        EXPECTED

is
    simple-image(Docker::File::User.new(username => 'daemon')),
    q:to/EXPECTED/, 'USER';
        FROM ubuntu
        USER daemon
        EXPECTED

is
    simple-image(Docker::File::WorkDir.new(dir => '/var/lol')),
    q:to/EXPECTED/, 'WORKDIR';
        FROM ubuntu
        WORKDIR /var/lol
        EXPECTED

is
    simple-image(Docker::File::StopSignal.new(signal => 9)),
    q:to/EXPECTED/, 'STOPSIGNAL (integer)';
    FROM ubuntu
    STOPSIGNAL 9
    EXPECTED

is
    simple-image(Docker::File::StopSignal.new(signal => 'SIGKILL')),
    q:to/EXPECTED/, 'STOPSIGNAL (name)';
    FROM ubuntu
    STOPSIGNAL SIGKILL
    EXPECTED

is
    simple-image(Docker::File::OnBuild.new(build =>
        Docker::File::RunShell.new(command =>
            '/usr/local/bin/python-build --dir /app/src'))),
    q:to/EXPECTED/, 'ONBUILD';
    FROM ubuntu
    ONBUILD RUN /usr/local/bin/python-build --dir /app/src
    EXPECTED

is
    simple-image(Docker::File::Expose.new(ports => 5000)),
    q:to/EXPECTED/, 'EXPOSE (one port)';
    FROM ubuntu
    EXPOSE 5000
    EXPECTED

is
    simple-image(Docker::File::Expose.new(ports => (5001, 5002, 5005))),
    q:to/EXPECTED/, 'EXPOSE (many ports)';
    FROM ubuntu
    EXPOSE 5001 5002 5005
    EXPECTED

is
    simple-image(Docker::File::Add.new(
        sources => ('avast', 'mateys'),
        destination => '/ab/so/loot'
    )),
    q:to/EXPECTED/, 'ADD (multiple sources, no spaces in name)';
    FROM ubuntu
    ADD avast mateys /ab/so/loot
    EXPECTED

is
    simple-image(Docker::File::Add.new(
        sources => 'omg space',
        destination => 'rel/ative'
    )),
    q:to/EXPECTED/, 'ADD (source with space in)';
    FROM ubuntu
    ADD ["omg space", "rel/ative"]
    EXPECTED

is
    simple-image(Docker::File::Add.new(
        sources => 'ISS',
        destination => '/a/spaced out/place'
    )),
    q:to/EXPECTED/, 'ADD (destination with spaces in)';
    FROM ubuntu
    ADD ["ISS", "/a/spaced out/place"]
    EXPECTED

is
    simple-image(Docker::File::Copy.new(
        sources => ('avast', 'mateys'),
        destination => '/ab/so/loot'
    )),
    q:to/EXPECTED/, 'COPY (multiple sources, no spaces in name)';
    FROM ubuntu
    COPY avast mateys /ab/so/loot
    EXPECTED

is
    simple-image(Docker::File::Copy.new(
        sources => 'omg space',
        destination => 'rel/ative'
    )),
    q:to/EXPECTED/, 'COPY (source with space in)';
    FROM ubuntu
    COPY ["omg space", "rel/ative"]
    EXPECTED

is
    simple-image(Docker::File::Copy.new(
        sources => 'ISS',
        destination => '/a/spaced out/place'
    )),
    q:to/EXPECTED/, 'COPY (destination with spaces in)';
    FROM ubuntu
    COPY ["ISS", "/a/spaced out/place"]
    EXPECTED

is
    simple-image(Docker::File::Arg.new(name => 'user1')),
    q:to/EXPECTED/, 'ARG (no default)';
    FROM ubuntu
    ARG user1
    EXPECTED

is
    simple-image(Docker::File::Arg.new(name => 'user1', default => 'bob')),
    q:to/EXPECTED/, 'ARG (default)';
    FROM ubuntu
    ARG user1=bob
    EXPECTED

is
    simple-image(Docker::File::Arg.new(name => 'buildno', default => 0)),
    q:to/EXPECTED/, 'ARG (default that is Perl 6 false should still be emitted)';
    FROM ubuntu
    ARG buildno=0
    EXPECTED

is
    simple-image(Docker::File::Label.new(labels => ('foo.bar' => 'baz'))),
    q:to/EXPECTED/, 'LABEL (one k/v without whitespace)';
    FROM ubuntu
    LABEL foo.bar="baz"
    EXPECTED

is
    simple-image(Docker::File::Label.new(labels => ('foo bar' => 'baz'))),
    q:to/EXPECTED/, 'LABEL (one k/v with whitespace in key)';
    FROM ubuntu
    LABEL "foo bar"="baz"
    EXPECTED

is
    simple-image(Docker::File::Label.new(labels => (foo => 'bar', bat => 'man'))),
    any(q:to/EXPECTED-1/, q:to/EXPECTED-2/), 'LABEL (two key/value pairs)';
    FROM ubuntu
    LABEL foo="bar" bat="man"
    EXPECTED-1
    FROM ubuntu
    LABEL bat="man" foo="bar"
    EXPECTED-2

is
    simple-image(Docker::File::Label.new(labels => ('foo' => "bar\nbaz"))),
    q:to/EXPECTED/, 'LABEL (value has newline)';
    FROM ubuntu
    LABEL foo="bar\
    baz"
    EXPECTED

is
    simple-image(Docker::File::Volume.new(volumes => '/data')),
    q:to/EXPECTED/, 'VOLUME (one)';
    FROM ubuntu
    VOLUME ["/data"]
    EXPECTED
    
is
    simple-image(Docker::File::Volume.new(volumes => ['/data', '/var/log'])),
    q:to/EXPECTED/, 'VOLUME (two)';
    FROM ubuntu
    VOLUME ["/data", "/var/log"]
    EXPECTED

is
    simple-image(Docker::File::Env.new(variables => ('foo' => 'bar'))),
    q:to/EXPECTED/, 'ENV (one)';
    FROM ubuntu
    ENV foo="bar"
    EXPECTED
    
is
    simple-image(Docker::File::Env.new(variables => ('foo' => 'bar', 'bat' => 'man'))),
    any(q:to/EXPECTED-1/, q:to/EXPECTED-2/), 'ENV (two)';
    FROM ubuntu
    ENV foo="bar" bat="man"
    EXPECTED-1
    FROM ubuntu
    ENV bat="man" foo="bar"
    EXPECTED-2

done-testing;
