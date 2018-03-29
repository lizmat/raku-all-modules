use NativeCall;
use Git::Error;
use Git::Buffer;

class Git::Message
{
    sub git_message_prettify(Git::Buffer, Str, int32, int8 --> int32)
        is native('git2') {}

    method prettify(Str:D $message, Bool:D :$strip-comments = True,
                    Str:D :$comment-char = '#' --> Str)
    {
        my Git::Buffer $buf .= new;
        check(git_message_prettify($buf, $message, $strip-comments ?? 1 !! 0,
                                   $comment-char.ord));
        $buf.str
    }
}
