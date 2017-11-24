use v6;
use App::Platform::Container;
use App::Platform::Docker::Command;

class App::Platform::Docker::Container is App::Platform::Container {

    has Str $.dockerfile-loc;
    has Str $.variant;
    has Str $.shell;
    has @.extra-args;
    has @.volumes;

    submethod BUILD {
        $!dockerfile-loc = $_ if not $!dockerfile-loc and "$_/Dockerfile".IO.e for self.projectdir ~ "/docker", self.projectdir;
        $!variant = (
            $!dockerfile-loc and 
            $!dockerfile-loc.IO.e and 
            "$!dockerfile-loc/Dockerfile".IO.slurp ~~ / ^ FROM \s .* alpine / 
            ) ?? 'alpine' !! 'debian';
        $!shell = $!variant eq 'alpine' ?? 'ash' !! 'bash';
        @!volumes = self.config-data<volumes>.Array.map({ <--volume>, self.projectdir.IO.absolute ~ '/' ~ $_ }).flat if self.config-data<volumes>;
        self.hostname = self.name ~ '.' ~ self.domain;
    }

    method build {
        return if not $.dockerfile-loc;
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
        App::Platform::Docker::Command.new(<docker>, <build -t>, self.name, @args, <.>).run(:cwd«$.dockerfile-loc»);
    }

    method users {
        return if not self.config-data<users>;
        my @cmds;
        my $config = self.config-data;
        for $config<users>.Hash.kv -> $login, $params {
            put "+ $login";
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
        my @args = flat self.env-cmd-opts;
        my $proc = shell "docker run {@args.join(' ')} --name {self.name} {self.name} {self.shell} -c '{@cmds.join(' ; ')}'", :out, :err;
        my $out = $proc.out.slurp-rest;
        $proc = run <docker commit>, self.name, self.name, :out; $out = $proc.out.slurp-rest;
        $proc = run <docker rm>, self.name, :out; $out = $proc.out.slurp-rest;
    }

    method dirs {
        return if not self.config-data<dirs>;
        my @args = flat self.env-cmd-opts;
        App::Platform::Docker::Command.new(<docker>, <run>, @args.flat, <-it -d --name>, self.name, self.name, $!shell).run;
        my $config = self.config-data;
        for $config<dirs>.Hash.kv -> $target, $content {
            my ($owner, $group, $mode);
            $owner   = $content<owner> if $content<owner>;
            $group   = $content<group> if $content<group>;
            $mode    = $content<mode>  if $content<mode>;
            my @cmd = [ "mkdir -p $target" ];
            @cmd.push: "chown $owner:$group $target" if $owner and $group;
            @cmd.push: "chmod $mode $target" if $mode;
            App::Platform::Docker::Command.new(<docker>, <exec>, self.name, $!shell, <-c>, @cmd.join(' ; ')).run;
        }
        App::Platform::Docker::Command.new(<docker>, <stop -t 0>, self.name).run;
        App::Platform::Docker::Command.new(<docker>, <commit>, self.name, self.name).run;
        App::Platform::Docker::Command.new(<docker>, <rm>, self.name).run
    }

    method files {
        return if not self.config-data<files>;
        my $config = self.config-data;
        if not self.data-path ~ '/' ~ self.domain ~ '/ssh/id_rsa.pub'.IO.e {
            put "No SSH keys available. Maybe you should run:\n\n  platform --data-path={self.data-path} --domain={self.domain} ssh keygen\n";
            exit;
        }
        my @args = flat self.env-cmd-opts;
        App::Platform::Docker::Command.new(<docker>, <run>, @args.flat, <-it -d --name>, self.name, self.name, $!shell).run;
        my $domain_path = self.data-path ~ '/' ~ self.domain;
        my $path = $domain_path ~ '/files';
        for $config<files>.Hash.kv -> $target, $content is rw {
            my ($owner, $group, $mode);
            if $content ~~ Hash {
                if $content<volume> { # create file to host and mount it inside container
                    my Str $flags = '';
                    $flags ~= ':ro' if $content<readonly>;
                    $content = $content<content>;
                    $content = "$domain_path/$content".IO.slurp if "$domain_path/$content".IO.e;
                    $content = "$path/$content".IO.slurp if "$path/$content".IO.e;
                    my $local_target = $target;
                    $local_target ~~ s'^\/'';
                    mkdir "$path/{self.name}/" ~ $local_target.IO.dirname;
                    spurt "$path/{self.name}/{$local_target}", $content;
                    @.volumes.push: <--volume>, "$path/{self.name}/{$local_target}:{$target}{$flags}";
                    next;
                } else {
                    $owner   = $content<owner> if $content<owner>;
                    $group   = $content<group> if $content<group>;
                    $mode    = $content<mode>  if $content<mode>;
                    $content = $content<content>;
                    temp $path = $path.IO.dirname;
                    $content = "$path/$content".IO.slurp if $content && "$path/$content".IO.e;
                }
            }
            $content = '' unless $content;
            my $file_tpl = "$path/{self.name}/" ~ $target;
            mkdir $file_tpl.IO.dirname;
            spurt $file_tpl, $content;
            App::Platform::Docker::Command.new(<docker>, <exec>, self.name, 'mkdir', '-p', $target.IO.dirname).run;
            App::Platform::Docker::Command.new(<docker>, <cp>, $file_tpl, self.name ~ ":$target").run;
            my @perm;
            @perm.push: "chown $owner:$group $target" if $owner and $group;
            @perm.push: "chmod $mode $target" if $mode;
            App::Platform::Docker::Command.new(<docker>, <exec>, self.name, $!shell, <-c>, @perm.join(' ; ')).run if @perm.elems > 0;
        }
        App::Platform::Docker::Command.new(<docker>, <stop -t 0>, self.name).run;
        App::Platform::Docker::Command.new(<docker>, <commit>, self.name, self.name).run;
        App::Platform::Docker::Command.new(<docker>, <rm>, self.name).run;
    }

    method exec {
        return if not self.config-data<exec>;
        App::Platform::Docker::Command.new(<docker>, <exec>, self.name, $!shell, <-c>, $_).run for self.config-data<exec>.Array;
    }

    method run {
        my $config = self.config-data;
        $config<command> = ($!shell, <-c>, $config<command>.flat) if $config<command> && $config<command>.chars > 0; 

        # Type of docker image e.g systemd
        if $config<type> and $config<type> eq 'systemd' {
            @.volumes.push: <--volume>, "/sys/fs/cgroup:/sys/fs/cgroup";
            @.extra-args.push('--privileged');
        }

        # Network
        @.extra-args.push("--network {$.network.Str}") if $.network-exists;

        # DNS
        @.extra-args.push: <--dns>, $.dns.Str if $.dns.Str.chars > 0;

        # Compute arbitrary amount of args
        my @args = flat self.env-cmd-opts, @.volumes, @.extra-args;
      
        # PHASE: run
        my @params = flat <docker>, <run>, <-it --detach>, @args, <-h>, self.hostname, <--name>, self.name, self.name;
        @params.append: $config<command>.flat if $config<command>;
        App::Platform::Docker::Command.new(|@params).run;
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

    method need-sleep-before-exec {
        # "hackish way" TODO: implement better detection or figure something different
        my $proc = run <docker exec>, self.name, 'ls', '/etc/init.d/postgresql', :out, :err;
        my $out = $proc.out.slurp-rest;
        my $err = $proc.err.slurp-rest;
        $err.chars > 0 ?? False !! True;
    }

    method env-cmd-opts {
        my $config = self.config-data;
        my @env = <--env>, "VIRTUAL_HOST={self.hostname}";
        @env.push: <--env>, "PS1=foo ";
        if $config<environment> {
            my $proc = run <git -C>, self.projectdir, <rev-parse --abbrev-ref HEAD>, :out, :err;
            my $branch = $proc.out.slurp-rest.trim;
            @env = flat @env, $config<environment>.Array.map({<--env>, $_.subst(/ \$\(GIT_BRANCH\) /, $branch)}).flat;
        }
say @env;
        @env;
    }
}
