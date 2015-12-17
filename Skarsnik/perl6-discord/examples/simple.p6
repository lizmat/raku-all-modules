use Discord;

#This small example allow me to send message to a channel by talking in private with
#This client
my $disc = Discord::Client.new;

$disc.login(@*ARGS[0], @*ARGS[1]);

#Every call to get message without argument give the "historic" of the channel
#So we keep the last msg to keep his ID
my @msg = $disc.get-messages($disc.me.private-channels<Skarsnik>);
my $last-msg = @msg.tail[0];

react {
  whenever Supply.interval(5) {
    #We only want new message
    @msg = $disc.get-messages($disc.me.private-channels<Skarsnik>, :after($last-msg.id));
    for @msg -> $msg {
      say $msg.perl;
      $disc.send-message($disc.me<QuillnBlade><qnb-general-sfw>, $msg.content);
      LAST {
        $last-msg = $msg;
      }
    }
  }
}

