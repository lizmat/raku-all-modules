#!/usr/bin/env liquidsoap

# This is the basis of the script that I have used for testing
set("log.stdout", true)
set("server.telnet", true)

default = playlist(id="default-playlist","~/Music/")

radio = fallback(track_sensitive=false,[ request.queue(id="incoming"), default, blank()])

output.icecast(%mp3, host="localhost",port=8000,password="hackme",mount="radio", radio)
