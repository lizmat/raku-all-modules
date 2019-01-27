use Native::Exec;

exec 'non-existant';

CATCH
{
    when X::Native::Exec
    {
        say "Native Error Code: ", .errno;
        say "Native Error Message: ", .message;
    }
}
