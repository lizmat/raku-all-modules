use v6;
use Platform::Container;

class Platform::Docker::Container is Platform::Container {

    has Str $.dockerfile-loc;
    has Str $.variant;
    has Str $.shell;
    has @.extra-args;
    has @.volumes;

    submethod BUILD {
        $!dockerfile-loc = $_ if not $!dockerfile-loc and "$_/Dockerfile".IO.e for self.projectdir ~ "/docker", self.projectdir;
        $!variant = "$!dockerfile-loc/Dockerfile".IO.slurp ~~ / ^ FROM \s .* alpine / ?? 'alpine' !! 'debian';
        $!shell = $!variant eq 'alpine' ?? 'ash' !! 'bash';
        @!volumes = map { '--volume ' ~ self.projectdir.IO.abspath ~ '/' ~ $_ }, self.config-data<volumes>.Array if self.config-data<volumes>;
        self.hostname = self.name ~ '.' ~ self.domain;
    }

    method build {
        my @args;
        my $config = self.config-data;
        if $config<build> {
            for $config<build>.Array {
                next if $_.Str.chars == 0;
                my ($option, $value) = $_.split(' ');
                @args.push("--$option");
                @args.push($value) if $value.chars > 0;
            }
        }
        my $proc = run <docker build -t>, self.name, @args, <.>, :cwd«$.dockerfile-loc», :out;
        my $out = $proc.out.slurp-rest;

        my $last-line = $out.lines[*-1];
        put $out if not $last-line ~~ / Successfully \s built /;
    }

    method users {
        return if not self.config-data<users>;
        my @cmds;
        my $config = self.config-data;
        for $config<users>.Hash.kv -> $login, $params {
            my %params = $params ~~ Hash ?? $params.hash !! ();
            if %params<home> {
                @cmds.push: 'mkdir -p ' ~ %params<home>.IO.dirname;
            }
            my @cmd = [ 'adduser' ];
            if $.variant eq 'alpine' {
                @cmd.push: "-h {%params<home>}" if %params<home>;
                @cmd.push: "-g \"{%params<gecos>}\"" if %params<gecos>;
                @cmd.push: "-s \"{%params<shell>}\"" if %params<shell>;
                @cmd.push: '-S' if %params<system>;
                @cmd.push: '-D' if not %params<password>;
                @cmd.push: $login;
                @cmds.push: @cmd.join(' ');
            } else {
                @cmd.push: "--home {%params<home>}" if %params<home>;
                @cmd.push: "--gecos \"{%params<gecos>}\"" if %params<gecos>;
                @cmd.push: "--shell \"{%params<shell>}\"" if %params<shell>;
                @cmd.push: '--system' if %params<system>;
                @cmd.push: '--disabled-password' if not %params<password>;
                @cmd.push: '--quiet';
                @cmd.push: $login;
                @cmds.push: @cmd.join(' ');
            }
        }
        my $proc = shell "docker run --name {self.name} {self.name} {self.shell} -c '{@cmds.join(' ; ')}'", :out, :err;
        my $out = $proc.out.slurp-rest;
        $proc = run <docker commit>, self.name, self.name, :out; $out = $proc.out.slurp-rest;
        $proc = run <docker rm>, self.name, :out; $out = $proc.out.slurp-rest;
    }

    method dirs {
        return if not self.config-data<dirs>;
        my $proc = run <docker run -d -it --name>, self.name, self.name, self.shell, :out;
        my $out = $proc.out.slurp-rest;
        my $config = self.config-data;
        for $config<dirs>.Hash.kv -> $target, $content {
            my ($owner, $group, $mode);
            $owner   = $content<owner> if $content<owner>;
            $group   = $content<group> if $content<group>;
            $mode    = $content<mode>  if $content<mode>;
            run <docker exec>, self.name, 'mkdir', '-p', $target;
            run <docker exec>, self.name, 'chown', "$owner:$group", $target if $owner and $group;
            run <docker exec>, self.name, 'chmod', $mode, $target if $mode;
        }
        $proc = run <docker stop -t 0>, self.name, :out; $out = $proc.out.slurp-rest; 
        $proc = run <docker commit>, self.name, self.name, :out; $out = $proc.out.slurp-rest;
        $proc = run <docker rm>, self.name, :out; $out = $proc.out.slurp-rest;
    }

    method files {
        return if not self.config-data<files>;
        my $config = self.config-data;
        if not self.data-path ~ '/' ~ self.domain ~ '/ssh/id_rsa.pub'.IO.e {
            put "No SSH keys available. Maybe you should run:\n\n  platform --data-path={self.data-path} --domain={self.domain} ssh keygen\n";
            exit;
        }
        my $proc = run <docker run -d -it --name>, self.name, self.name, self.shell, :out;
        my $out = $proc.out.slurp-rest;
        my $path = self.data-path ~ '/' ~ self.domain ~ "/files";
        for $config<files>.Hash.kv -> $target, $content is rw {
            my ($owner, $group, $mode);
            if $content ~~ Hash {
                if $content<volume> { # create file to host and mount it inside container
                    my Str $flags = '';
                    $flags ~= ':ro' if $content<readonly>;
                    $content = $content<content>;
                    $content = "$path/$content".IO.slurp if "$path/$content".IO.e;
                    mkdir "$path/{self.name}/" ~ $target.IO.dirname;
                    spurt "$path/{self.name}/{$target}", $content;
                    @.volumes.push: "--volume $path/{self.name}/{$target}:{$target}{$flags}";
                    next;
                } else {
                    $owner   = $content<owner> if $content<owner>;
                    $group   = $content<group> if $content<group>;
                    $mode    = $content<mode>  if $content<mode>;
                    $content = $content<content>;
                    temp $path = $path.IO.dirname;
                    $content = "$path/$content".IO.slurp if "$path/$content".IO.e;
                }
            }
            my $file_tpl = "$path/{self.name}/" ~ $target;
            mkdir $file_tpl.IO.dirname;
            spurt $file_tpl, $content;
            run <docker exec>, self.name, 'mkdir', '-p', $target.IO.dirname;
            run <docker cp>, $file_tpl, self.name ~ ":$target";
            run <docker exec>, self.name, 'chown', "$owner:$group", $target if $owner and $group;
            run <docker exec>, self.name, 'chmod', $mode, $target if $mode;
        }
        $proc = run <docker stop -t 0>, self.name, :out; 
        $out = $proc.out.slurp-rest;
        $proc = run <docker commit>, self.name, self.name, :out;
        $out = $proc.out.slurp-rest;
        $proc = run <docker rm>, self.name, :out;
        $out = $proc.out.slurp-rest;
    }

    method run {
        my $config = self.config-data;

        # Type of docker image e.g systemd
        if $config<type> and $config<type> eq 'systemd' {
            @.volumes.push('--volume /sys/fs/cgroup:/sys/fs/cgroup');
            @.extra-args.push('--privileged');
        }

        # Environment variables
        my @env = [ "--env VIRTUAL_HOST={self.hostname}" ];
        if $config<environment> {
            my $proc = run <git -C>, self.projectdir, <rev-parse --abbrev-ref HEAD>, :out, :err;
            my $branch = $proc.out.slurp-rest.trim;
            @env = (@env, map { $_ = '--env ' ~ $_.subst(/ \$\(GIT_BRANCH\) /, $branch) }, $config<environment>.Array).flat;
        }

        # Network
        @.extra-args.push("--network {$.network.Str}") if $.network-exists;

        # DNS
        @.extra-args.push("--dns {$.dns.Str}") if $.dns.Str.chars > 0;

        # PHASE: run
        my @args = flat @env, @.volumes, @.extra-args;
        my $cmd = "docker run -dit -h {self.hostname} --name {self.name} {@args.join(' ')} {self.name} {$config<command>}";
        shell $cmd, :out, :err;
    }
    
    method start {
        self.last-command: run <docker start>, self.name, :out, :err;
        self;
    }

    method stop {
        self.last-command: run <docker stop -t 0>, self.name, :out, :err;
        self;
    }
    
    method rm {
        self.last-command: run <docker rm>, self.name, :out, :err;
        self;
    }

}
