use NativeCall;

enum Git::Submodule::Ignore (
    GIT_SUBMODULE_IGNORE_UNSPECIFIED  => -1,
    GIT_SUBMODULE_IGNORE_NONE         => 1,
    GIT_SUBMODULE_IGNORE_UNTRACKED    => 2,
    GIT_SUBMODULE_IGNORE_DIRTY        => 3,
    GIT_SUBMODULE_IGNORE_ALL          => 4,
);

subset Git::Submodule::Ignore::Str of Str
    where .uc ~~ 'UNSPECIFIED'|'NONE'|'UNTRACKED'|'DIRTY'|'ALL';
