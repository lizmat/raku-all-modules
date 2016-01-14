class RPi {
  use RPi::Wiring;
  use RPi::GPIO;
  use POSIX;

  has RPi::GPIO $!gpio;
  
  method drop-privileges(Str $user, Str $group) returns Bool {
    return self.set-group($group) && self.set-user($user)
  }

  method set-user(Str $user) returns Bool {
    # Retrieve the passwd struct for the provided username.
    my $user-info = getpwnam($user);

    # Throw an exception if we weren't able to retrieve the passwd struct
    # for the provided username.
    die "Unknown user: $user" if ! $user-info.defined;

    # Set the UID.
    my $res = setuid($user-info.uid);
    die "Couldn't set user to: $user.  Are you running as root?"
      if $res == -1;

    return True;
  }

  method set-group(Str $group) returns Bool {
    # Retrieve the group struct for the provided group.
    my $group-info = getgrnam($group);
    
    # Throw an exception if we weren't able to retrieve the group struct
    # for the provided group.
    die "Unknown group: $group" if ! $group-info.defined;
    
    # Set the GID.
    my $res = setgid($group-info.gid);
    die "Couldn't set group to: $group.  Are you running as root?"
      if $res == -1;

    return True;
  }

  method gpio(RPiGPIOMode :$mode = BCM) {
    return (! $!gpio.defined) ?? ($!gpio = RPi::GPIO.new(mode => $mode)) !! $!gpio;
  }
  
  method delay(Int $milliseconds where $milliseconds >= 0) {
    return RPi::Wiring::delay-milliseconds($milliseconds)
  }
  
  method revision() returns Int {
    return RPi::Wiring::board-revision();
  }
}
