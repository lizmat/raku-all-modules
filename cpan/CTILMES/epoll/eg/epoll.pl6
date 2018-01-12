use epoll;

for epoll.new.add(0, :in).wait
{
    say "ready to read on {.fd}" if .in;
}
