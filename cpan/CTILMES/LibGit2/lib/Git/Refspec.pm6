use NativeCall;
use Git::Error;
use Git::Buffer;

# git_direction
enum Git::Direction
<
    GIT_DIRECTION_FETCH
    GIT_DIRECTION_PUSH
>;

class Git::Refspec is repr('CPointer')
{
    sub git_refspec_direction(Git::Refspec --> int32)
        is native('git2') {}

    method direction
    {
        given git_refspec_direction(self)
        {
            when GIT_DIRECTION_FETCH { 'fetch' }
            when GIT_DIRECTION_PUSH  { 'push'  }
        }
    }

    method Str(--> Str)
        is native('git2') is symbol('git_refspec_string') {}

    method dst(--> Str)
        is native('git2') is symbol('git_refspec_dst') {}

    sub git_refspec_dst_matches(Git::Refspec, Str --> int32)
        is native('git2') {}

    method dst-matches(Str:D $refname)
    {
        git_refspec_dst_matches(self, $refname) == 1
    }

    sub git_refspec_force(Git::Refspec --> int32)
        is native('git2') {}

    method force { git_refspec_force(self) == 1 }

    sub git_refspec_rtransform(Git::Buffer, Git::Refspec, Str --> int32)
        is native('git2') {}

    method rtransform(Str:D $name)
    {
        my Git::Buffer $buf .= new;
        check(git_refspec_rtransform($buf, self, $name));
        $buf.str
    }

    method src( --> Str)
        is native('git2') is symbol('git_refspec_src') {}

    sub git_refspec_src_matches(Git::Refspec, Str --> int32)
        is native('git2') {}

    method src-matches(Str:D $refname)
    {
        git_refspec_src_matches(self, $refname) == 1
    }

    sub git_refspec_transform(Git::Buffer, Git::Refspec, Str --> int32)
        is native('git2') {}

    method transform(Str:D $name)
    {
        my Git::Buffer $buf .= new;
        check(git_refspec_transform($buf, self, $name));
        $buf.str
    }
}
