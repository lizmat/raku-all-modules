# Powerline::Prompt
[![Build Status](https://travis-ci.org/7ojo/perl6-powerline-prompt.svg?branch=master)](https://travis-ci.org/7ojo/perl6-powerline-prompt)

Make a useful prompt for your shell.

![Screenshot](https://raw.githubusercontent.com/7ojo/perl6-powerline-prompt/master/examples/powerline-prompt.png)

# SYNOPSIS

examples/powerline-prompt.p6

    #!/usr/bin/env perl6

    use v6;
    use Powerline::Prompt::Shell::Bash;

    print Powerline::Prompt::Shell::Bash.new.draw;

# SETUP

## Bash

### Daemon example

This is for faster setup

~/.bashrc

    TEMP=$(tty)
    POWERLINE_PORT=$((3333 + ${TEMP:9}))

    perl6 examples/powerline-daemon.p6 --port=${POWERLINE_PORT} &

    sleep 0.2 # wait for daemon to start

    function _update_ps1() {
        local EXIT="$?"
        PS1="$(exec 5<>/dev/tcp/localhost/${POWERLINE_PORT} ; echo ${PWD} ${EXIT} >&5 ; cat <&5)"
    }
    if [ "$TERM" != "linux" ]; then
        PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
    fi


### Basic example

~/.bashrc

    function _update_ps1() {
        PS1="$(examples/powerline-prompt.p6 $? 2> /dev/null)"
    }

    if [ "$TERM" != "linux" ]; then
        PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
    fi

