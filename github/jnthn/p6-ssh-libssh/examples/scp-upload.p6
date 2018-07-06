use SSH::LibSSH;

sub MAIN($host, $user, $local, $remote, Int :$port, Str :$password) {
    my $session = await SSH::LibSSH.connect(:$host, :$user, :$port, :$password);
    await $session.scp-upload($local, $remote);
    $session.close;
}
