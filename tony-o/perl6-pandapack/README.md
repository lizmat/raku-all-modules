#Introducing ```pandapack``` util..

This little guy does everything you want but only partially.  Actually, this just calls plugins that you have installed based on a config file .. 

#Developing for ```pandapack```, become part of the pack

Developing for ```pandapack``` is pretty straight forward.  There are two build phases you can hook into, the first being 'build', the second being 'postbuild'.  Below is a skeleton class for ```pandapack```

```perl6
#!/usr/bin/env perl6

class Packopanda::Plugin::Skeleton {
  method build {
    #I get called first
  }

  method postbuild {
    #I get called second
  }
}
```

