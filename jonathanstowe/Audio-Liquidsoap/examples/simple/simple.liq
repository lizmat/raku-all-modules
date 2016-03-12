#!/usr/bin/env liquidsoap

set("log.stdout", true)
set("server.telnet", true)


path = dirname(argv(0));

amen = single("#{path}/amen.mp3")

queue = request.queue(id="incoming")

radio = fallback(track_sensitive=false,[queue, amen, blank()])

output.icecast(%mp3, host="localhost",port=8000,password="hackme",mount="radio", radio)
