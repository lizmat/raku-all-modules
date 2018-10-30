class System::Passwd::User
{
    has $.username;
    has $.password;
    has $.uid;
    has $.gid;
    has $.fullname;
    has $.home_directory;
    has $.login_shell;

    method new ($line!)
    {
        my @line = $line.split(':');
        my $username        = @line[0];
        my $password        = @line[1];
        my $uid             = @line[2];
        my $gid             = @line[3];
        my $fullname        = @line[4];
        my $home_directory  = @line[5];
        my $login_shell     = @line[6];

        return self.bless(:$username, :$password, :$uid, :$gid, :$fullname, :$home_directory, :$login_shell);
    }
}
