use SSH::LibSSH;

sub MAIN($host, $user, $local, $remote) {
    my $session = await SSH::LibSSH.connect(:$host, :$user);
    await $session.scp-upload($local, $remote);
    $session.close;
}
