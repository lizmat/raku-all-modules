use v6;

unit module CompUnit::DynamicLib:ver<0.2.1>:auth<Sterling Hanenkamp (hanenkamp@cpan.org)>;

multi use-lib-do(@include, &block) is export {
    my @repos;
    {
        ENTER {
            @repos = gather for @include -> $inc {
                my $repo;
                CompUnit::RepositoryRegistry.use-repository(
                    $repo = CompUnit::RepositoryRegistry.repository-for-spec($inc)
                );
                take $repo;
            };
        }

        LEAVE {
            for @repos -> $current {
                if $*REPO === $current {
                    PROCESS::<$REPO> := $*REPO.next-repo;
                }
                else {
                    for $*REPO.repo-chain -> $try-repo {
                        if $try-repo.next-repo === $current {
                            $try-repo.next-repo = $current.next-repo;
                            last;
                        }
                    }
                }
            }
        }

        block();
    }
}

multi use-lib-do($include, &block) is export {
    use-lib-do(($include,), &block);
}

multi require-from(@include, Str $module-name where /^ [ \w | <[':_-]> ]+ $/) is export {
    use-lib-do(@include, {
        # Work-around RT #129109
        # require ::($module-name);
        # TODO Try removing this work-around once the ticket is resolved.
        use MONKEY-SEE-NO-EVAL;
        EVAL "use $module-name";
        ::($module-name);
    });
}

multi require-from($include, Str $module-name) is export {
    require-from(($include,), $module-name);
}
