use SSH::LibSSH;

sub MAIN($host, $user, $remote, $local) {
    my $session = await SSH::LibSSH.connect(:$host, :$user);
    await $session.scp-download($remote, $local);
    $session.close;
}
