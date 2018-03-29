use NativeCall;
use Git::Buffer;
use Git::Error;

constant \GIT_DESCRIBE_DEFAULT_ABBREVIATED_SIZE = 7;

enum Git::Describe::Strategy <
    GIT_DESCRIBE_DEFAULT
    GIT_DESCRIBE_TAGS
    GIT_DESCRIBE_ALL
>;

class Git::Describe::Options is repr('CStruct')
{
    has uint32 $.version = 1;
    has uint32 $.max-candidates-tags = 10;
    has uint32 $.describe-strategy;
    has Str $.pattern;
    has int32 $.only-follow-first-parent;
    has int32 $.show-commit-oid-as-fallback;

    submethod BUILD(Bool :$tags, Bool :$all, Str :$pattern,
                    Bool :$only-follow-first-parent,
                    Bool :$show-commit-oid-as-fallback)
    {
        $!describe-strategy =
            $tags ?? GIT_DESCRIBE_TAGS
                  !! $all ?? GIT_DESCRIBE_ALL
                          !! GIT_DESCRIBE_DEFAULT;

        $!pattern := $pattern;

        $!only-follow-first-parent = $only-follow-first-parent ?? 1 !! 0;

        $!show-commit-oid-as-fallback = $show-commit-oid-as-fallback ?? 1 !! 0;
    }
}

class Git::Describe::Format::Options is repr('CStruct')
{
    has uint32 $.version = 1;
    has uint32 $.abbreviated-size = GIT_DESCRIBE_DEFAULT_ABBREVIATED_SIZE;
    has int32 $.always-use-long-format;
    has Str $.dirty-suffix;

    submethod BUILD(Bool :$always-use-long-format, Str :$dirty-suffix,
                    uint32 :$!abbreviated-size)

    {
        $!always-use-long-format = $always-use-long-format ?? 1 !! 0;

        $!dirty-suffix := $dirty-suffix;
    }
}

class Git::Describe::Result is repr('CPointer')
{
    sub git_describe_result_free(Git::Describe::Result)
        is native('git2') {}

    submethod DESTROY { git_describe_result_free(self) }

    sub git_describe_format(Git::Buffer, Git::Describe::Result,
                            Git::Describe::Format::Options --> int32)
        is native('git2') {}

    method format(|opts)
    {
        my Git::Buffer $buf .= new;
        my Git::Describe::Format::Options $opts .= new(|opts);
        check(git_describe_format($buf, self, $opts));
        $buf.str
    }
}
