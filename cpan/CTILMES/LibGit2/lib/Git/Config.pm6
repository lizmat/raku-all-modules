use NativeCall;
use Git::Error;
use Git::Buffer;

enum Git::Config::Level (
    GIT_CONFIG_LEVEL_PROGRAMDATA => 1,
    GIT_CONFIG_LEVEL_SYSTEM      => 2,
    GIT_CONFIG_LEVEL_XDG         => 3,
    GIT_CONFIG_LEVEL_GLOBAL      => 4,
    GIT_CONFIG_LEVEL_LOCAL       => 5,
    GIT_CONFIG_LEVEL_APP         => 6,
    GIT_CONFIG_HIGHEST_LEVEL     => -1,
);

enum Git::Config::cvar <
    GIT_CVAR_FALSE
    GIT_CVAR_TRUE
    GIT_CVAR_INT32
    GIT_CVAR_STRING
>;

class Git::Config::Entry is repr('CStruct')
{
    has Str $.name;
    has Str $.value;
    has int32 $.level;
    has Pointer $.free;
    has Pointer $.payload;

    sub git_config_entry_free(Git::Config::Entry)
        is native('git2') {}

    method level { Git::Config::Level($!level) }

    method Str { $!value }

    submethod DESTROY { git_config_entry_free(self) }
}

class Git::Config::Iterator is repr('CPointer') does Iterator
{
    sub git_config_iterator_free(Git::Config::Iterator)
        is native('git2') {}

    sub git_config_next(Pointer is rw, Git::Config::Iterator
                        --> int32)
        is native('git2') {}

    method pull-one
    {
        my Pointer $ptr .= new;
        my $ret = git_config_next($ptr, self);
        return IterationEnd if $ret == GIT_ITEROVER;
        check($ret);
        nativecast(Git::Config::Entry, $ptr)
    }

    submethod DESTROY { git_config_iterator_free(self) }
}

class Git::Config is repr('CPointer') does Associative
{
    sub git_config_new(Pointer is rw --> int32)
        is native('git2') {}

    sub git_config_add_file_ondisk(Git::Config, Str, int32, int32
                               --> int32)
        is native('git2') {}

    sub git_config_open_default(Pointer is rw --> int32)
        is native('git2') {}

    sub git_config_free(Git::Config)
        is native('git2') {}

    sub git_config_open_level(Pointer is rw, Git::Config, int32 --> int32)
        is native('git2') {}

    sub git_config_get_entry(Pointer is rw, Git::Config, Str --> int32)
        is native('git2') {}

    sub git_config_iterator_new(Pointer is rw, Git::Config --> int32)
        is native('git2') {}

    sub git_config_set_bool(Git::Config, Str, int32 --> int32)
        is native('git2') {}

    sub git_config_set_int32(Git::Config, Str, int32 --> int32)
        is native('git2') {}

    sub git_config_set_int64(Git::Config, Str, int64 --> int32)
        is native('git2') {}

    sub git_config_set_string(Git::Config, Str, Str --> int32)
        is native('git2') {}

    sub git_config_set_multivar(Git::Config, Str, Str, Str --> int32)
        is native('git2') {}

    sub git_config_multivar_iterator_new(Pointer is rw, Git::Config,
                                         Str, Str --> int32)
        is native('git2') {}

    sub git_config_snapshot(Pointer is rw, Git::Config --> int32)
        is native('git2') {}

    sub git_config_delete_entry(Git::Config, Str --> int32)
        is native('git2') {}

    sub git_config_delete_multivar(Git::Config, Str, Str --> int32)
        is native('git2') {}

    sub git_config_find_global(Git::Buffer --> int32)
        is native('git2') {}

    sub git_config_find_programdata(Git::Buffer --> int32)
        is native('git2') {}

    sub git_config_find_system(Git::Buffer --> int32)
        is native('git2') {}

    sub git_config_find_xdg(Git::Buffer --> int32)
        is native('git2') {}

    submethod DESTROY { git_config_free(self) }

    method new(--> Git::Config)
    {
        my Pointer $ptr .= new;
        check(git_config_new($ptr));
        nativecast(Git::Config, $ptr);
    }

    method add-file-ondisk(Str:D $path, Git::Config::Level:D $level,
                           Bool :$force = False)
    {
        check(git_config_add_file_ondisk(self, $path, $level, $force ?? 1 !! 0))
    }

    method default(--> Git::Config)
    {
        my Pointer $ptr .= new;
        check(git_config_open_default($ptr));
        nativecast(Git::Config, $ptr)
    }

    method open-level(Git::Config::Level:D $level --> Git::Config)
    {
        my Pointer $ptr .= new;
        check(git_config_open_level($ptr, self, $level));
        nativecast(Git::Config, $ptr);
    }

    method snapshot()
    {
        my Pointer $ptr .= new;
        check(git_config_snapshot($ptr, self));
        nativecast(Git::Config, $ptr)
    }

    method get-entry(Str:D $name)
    {
        my Pointer $ptr .= new;
        check(git_config_get_entry($ptr, self, $name));
        nativecast(Git::Config::Entry, $ptr);
    }

    method get-all()
    {
        my Pointer $ptr .= new;
        check(git_config_iterator_new($ptr, self));
        Seq.new(nativecast(Git::Config::Iterator, $ptr))
    }

    method get-multi(Str:D $name, Str $regexp?)
    {
        my Pointer $ptr .= new;
        check(git_config_multivar_iterator_new($ptr, self, $name, $regexp));

        Seq.new(nativecast(Git::Config::Iterator, $ptr))
    }

    multi method set(Str:D $name, Bool:D $value)
    {
        check(git_config_set_bool(self, $name, $value ?? 1 !! 0))
    }

    multi method set(Str:D $name, Str:D $value)
    {
        check(git_config_set_string(self, $name, $value))
    }

    multi method set(Str:D $name, Int:D $value)
    {
        check(git_config_set_int64(self, $name, $value))
    }

    multi method set(Str:D $name, Str:D $regexp, Str:D $value)
    {
        check(git_config_set_multivar(self, $name, $regexp, $value))
    }

    multi method delete(Str:D $name)
    {
        check(git_config_delete_entry(self, $name))
    }

    multi method delete(Str:D $name, Str:D $regexp)
    {
        check(git_config_delete_multivar(self, $name, $regexp))
    }

    multi method AT-KEY(Str:D $key)
    {
        my Pointer $ptr .= new;
        my $ret = git_config_get_entry($ptr, self, $key);
        return if $ret == GIT_ENOTFOUND;
        check($ret);
        nativecast(Git::Config::Entry, $ptr).value
    }

    multi method EXISTS-KEY(Str:D $key --> Bool)
    {
        my Pointer $ptr .= new;
        my $ret = git_config_get_entry($ptr, self, $key);
        return False if $ret == GIT_ENOTFOUND;
        check($ret);
        my $entry = nativecast(Git::Config::Entry, $ptr); # So it will DESTROY
        True
    }

    multi method DELETE-KEY(Str:D $key)
    {
        my Pointer $ptr .= new;
        my $ret = git_config_get_entry($ptr, self, $key);
        return if $ret == GIT_ENOTFOUND;
        check($ret);
        my $entry = nativecast(Git::Config::Entry, $ptr);
        check(git_config_delete_entry(self, $key));
        $entry.value
    }

    method find(Str:D $which where 'global'|'programdata'|'system'|'xdg')
    {
        my Git::Buffer $buf .= new;
        check: do given $which
        {
            when 'global'      { git_config_find_global($buf) }
            when 'programdata' { git_config_find_programdata($buf) }
            when 'system'      { git_config_find_system($buf) }
            when 'xdg'         { git_config_find_xdg($buf) }
        }
        $buf.str
    }
}
