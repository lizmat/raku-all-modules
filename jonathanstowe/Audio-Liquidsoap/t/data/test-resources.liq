#!/usr/bin/env liquidsoap

set("log.stdout", true)
set("server.telnet", true)
set("server.telnet.bind_addr","127.0.0.1")
set("harbor.bind_addr","127.0.0.1")

instring = interactive.string("instring", "default")
inbool   = interactive.bool("inbool", true)
infloat  = interactive.float("infloat",1.0)

default = playlist(id="default-playlist","t/data/play")

outblank = blank()

incoming = request.queue(id="incoming")

live = input.harbor("live-source", id="live-source", port=9878)

relay = input.http("http://stream.futuremusic.fm:8000/mp3", id="relay-source", autostart=false)

radio = fallback(track_sensitive=false,[live, relay, incoming, default, outblank])

output.dummy(id="dummy-output", radio)
