use NativeCall;
use Git::Error;

# git_credtype_t
enum Git::Credtype
(
    GIT_CREDTYPE_USERPASS_PLAINTEXT => 1 +< 0,
    GIT_CREDTYPE_SSH_KEY            => 1 +< 1,
    GIT_CREDTYPE_SSH_CUSTOM         => 1 +< 2,
    GIT_CREDTYPE_DEFAULT            => 1 +< 3,
    GIT_CREDTYPE_SSH_INTERACTIVE    => 1 +< 4,
    GIT_CREDTYPE_USERNAME           => 1 +< 5,
    GIT_CREDTYPE_SSH_MEMORY         => 1 +< 6,
);

# git_cred
class Git::Cred is repr('CPointer')
{
    sub git_cred_default_new(Pointer is rw --> int32)
        is native('git2') {}

    method new(--> Git::Cred)
    {
        my Pointer $ptr .= new;
        check(git_cred_default_new($ptr));
        nativecast(Git::Cred, $ptr)
    }

    sub git_cred_ssh_key_from_agent(Pointer is rw, Str --> int32)
        is native('git2') {}

    method ssh-key-from-agent(Str:D $username --> Git::Cred)
    {
        my Pointer $ptr .= new;
        check(git_cred_ssh_key_from_agent($ptr, $username));
        nativecast(Git::Cred, $ptr)
    }

    sub git_cred_ssh_key_memory_new(Pointer is rw, Str, Str, Str, Str --> int32)
        is native('git2') {}

    method ssh-key-memory-new(Str:D $username,
                              Str:D $publickey,
                              Str:D $privatekey,
                              Str:D $passphrase)
    {
        my Pointer $ptr .= new;
        check(git_cred_ssh_key_memory_new($ptr, $username, $publickey,
                                          $privatekey, $passphrase));
        nativecast(Git::Cred, $ptr)
    }

    method free is native('git2') is symbol('git_cred_free') {}

    sub git_cred_has_username(Git::Cred --> int32)
        is native('git2') {}

    method has-username { git_cred_has_username(self) == 1 }

    sub git_cred_ssh_key_new(Pointer is rw, Str, Str, Str, Str --> int32)
        is native('git2') {}

    method ssh-key-new(Str:D $username,
                       Str:D $publickey,
                       Str:D $privatekey,
                       Str:D $passphrase)
    {
        my Pointer $ptr .= new;
        check(git_cred_ssh_key_new($ptr, $username, $publickey, $privatekey,
                                   $passphrase));
        nativecast(Git::Cred, $ptr)
    }
}

