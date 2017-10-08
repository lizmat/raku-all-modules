# WebService::Slack::Webhook
Small module to use a Slack 'Incoming Webhook' easily.

## Design
The idea is to make this module as simple to use as possible. In an effort to do this, info will be passed as a hash instead of named arguments. This is because Slack's API for webhooks is not documented terribly well, and they are always new additions to it. So, instead of preventing you from sending a particular bit of data, just pass a hash and it will be sent.

### `.new`
The `.new` method will require an 'incoming webhook' integration link from Slack, this way it knows where to connect and has the correct authentication to do so. One of these links will be given after setting up an integration using [this link](https://my.slack.com/services/new/incoming-webhook/ "New Slack incoming webhook"). If the url is not given an exception will be thrown. The syntax for this method will look like this:
```
#String containing the URL.
my $slack = WebService::Slack::Webhook.new(url => "$url");
```

Defaults are now available as well. This should make it easier to use this module, because instead of having to pass a huge hash every time, it can just be set as a default. Note that the defaults can still be overridden just by setting the option to something else when passing a hash. Setting defaults:
```
#Setting a default hash for the object.
my $slack = WebService::Slack::Webhook.new(
    url => "$url",
    defaults => %( username => "System Messenger" )
);
```

### `.send`
This will be the method to send a message from. It will be overloaded so that it can be used easier. The correct syntax for it will be:
```
#Using the '$slack' variable from the previous example...

#Using a hash.
my %info = (
  username  => "Jimmy the Robot",
  icon_emoji => ":robot_face:",
  text      => "Beep, boop. *excited robot sounds*"
);
$slack.send(%info);

#Or if you just want to send something...

#Just a string.
$slack.send("Beep, boop. *excited robot sounds*");
```

## Requirements
Everything relies on something else (really I'm just lazy). The following is a list of the modules that are required for this one to function correctly:
- JSON::Fast
- Net::HTTP
