# SYNOPSIS

Sparky plugin to send notifications in a Telegram chat after completing your builds.
Based on a perl6 module - [TelegramBot](https://github.com/GildedHonour/TelegramBot)

# INSTALL

    $ zef install Sparky::Plugin::Notify::Telegram

# USAGE

    $ cat sparky.yaml
    # send me a notifications on failed builds
    plugins:
    - Sparky::Plugin::Notify::Telegram:
      run_scope: fail
      parameters:
        token: "111:222" # Your token
        id: "1123213"
        message: "Some fails while processing your build"
# Author

Spigell
