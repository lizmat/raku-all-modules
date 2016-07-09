
use v6;
use PubFunc;

unit class LocalConfig;

has Str $.socket-error-uri is rw = 'https://msdn.microsoft.com/en-us/library/windows/desktop/ms740668%28v=vs.85%29.aspx';
has Str $.system-error-uri is rw = 'https://msdn.microsoft.com/en-us/library/windows/desktop/ms681381%28v=vs.85%29.aspx';
has Str $.include-directory is rw = '/usr/include';
has Str $.errno-include is rw = '/usr/include/errno.h';

#our $CACHE-DATA-DIR				= $*HOME.path ~ '/.config/' ~ $PROGRAM-NAME;
#our $ERRNO-FILENAME				= 'errno.ls';
#our $SOCKET-FILENAME			= 'socket.ls';
#our $SYSTEM-FILENAME			= 'system.ls';
#our $LOCAL-CONFIG              = 'finderror.cfg';

sub localProgramPath() is export {
    $ISWIN32 ??
		$*HOME.path ~ "/" ~ $PROGRAM-NAME !!
		$*HOME.path ~ '/.config/' ~ $PROGRAM-NAME;
}

sub localConfigPath() is export {
    localProgramPath() ~ '/finderror.cfg';
}

sub errnoCachePath() is export {
	localProgramPath() ~ '/error.ls';
}

sub win32ErrorSystemCachePath() is export {
	localProgramPath() ~ '/system.ls';
}

sub win32ErrorSocketCachePath() is export {
	localProgramPath() ~ '/socket.ls';
}

sub cleanCache($path) is export {
    $path.IO.unlink();
}

multi sub writeCache($path, @datas) is export {
	my $eh = $path.IO.open(:w);

	for @datas -> $errno {
		$eh.say("errno:{$errno.errno},number:{$errno.number},comment:{$errno.comment}");
	}

	$eh.close();
}

multi sub writeCache($path, @datas, :$append) is export {
	my $eh = $path.IO.open(:w, :a);

	for @datas -> $errno {
		$eh.say("errno:{$errno.errno},number:{$errno.number},comment:{$errno.comment}");
	}

	$eh.close();
}

method read-config() {
    self!check-local-path();
    self!read-local-config();
}

# when user modify config
method update-config() {
    self!write-local-config();
}

method !check-local-path() {
    if localProgramPath().IO !~~ :e {
        unless localProgramPath().IO.mkdir() {
            fail "Can not create directory:" ~ localProgramPath();
        }
    }
}

#`(
    [NAME]=VALUE
)
method !read-local-config() {
    my @table = [
        'SYSTEM-ERROR-URI',
        'SOCKET-ERROR-URI',
        'ERRNO-INCLUDE',
        'INCLUDE-DIRECTORY',
    ];

    if localConfigPath().IO ~~ :e {
        for localConfigPath().IO.open.lines -> $line {
            for @table -> $key {
                if $line ~~ /\[ {$key} \]\=$<value>=(.*)/ {
                    self.hash-way-operator($key, ~$/<value>);
                    last;
                }
            }
        }
    }
    # not exists, write initialize config
    else {
        self!write-local-config();
    }
}

method !write-local-config() {
    my @table = [
        'SYSTEM-ERROR-URI',
        'SOCKET-ERROR-URI',
        'ERRNO-INCLUDE',
        'INCLUDE-DIRECTORY',
    ];

    my $fh = localConfigPath().IO.open(:w);

    for @table -> $key {
        $fh.say("[{$key}]=" ~ self.hash-way-operator($key));
    }

    $fh.close();
}

method hash-way-operator(Str $key, Str $value?) {
    my $object;

    given $key {
        when m:i/'system-error-uri'/ {
            $!system-error-uri = $value if $value.defined;
            $object = $!system-error-uri;
        }
        when m:i/'socket-error-uri'/ {
            $!socket-error-uri = $value if $value.defined;
            $object = $!socket-error-uri;
        }
        when m:i/'errno-include'/ {
            $!errno-include = $value if $value.defined;
            $object = $!errno-include;
        }
        when m:i/'include-directory'/ {
            $!include-directory = $value if $value.defined;
            $object = $!include-directory;
        }
    }
    $object;
}
