#Template::Protone 

[![Build Status](https://travis-ci.org/tony-o/perl6-template-protone.svg?branch=master)](https://travis-ci.org/tony-o/perl6-template-protone)

Creating synergy throughout the world by bringing harmonious designs and interfaces into a collaborative space that resides between what users want and also giving people what they need.

Also, a templating system that allows you to embed perl6.  ```EVAL```s your templates into a callable sub and caches them for later use, if you want.

##Stuff still to do or nice to haves

* Don't match a closer embedded in quotes
* Make the opener escapable
* Run template sub in a space where custom functions are available to the template
* Save template sub to a file so it doesn't need to be rebuilt every time app is restarted

#Usage

```perl6
use Template::Protone;

my Template::Protone $templ .= new;

$templ.parse(template => [q|
Hello <% print "WORLD!"; %>

Oh, did you want variables too?  I can do <% print $data<what>; %> too.

<% for ^3 { %>
<% print $_ ~ ($_ == 2 ?? '' !! ', '); %>
<% } %>
|], :name<example>);

say $templ.render(:name<example>, :data(what => 'that'));
```

##Output

```
Hello WORLD!

Oh, did you want variables too?  I can do that too.

0, 1, 2
```

#What's that?  You don't like <% and %> ?

```perl6
qw<...>;

use Template::Protone;

my Template::Protone $templ .= new(:open('%%'), :close("%%"));

say $templ.render(template => [q|
Hello %% print "WORLD!"; %%

List: %% for ^3 {  
   print $_ ~ ($_ == 2 ?? '' !! ', '); 
 } %%
|]);

qw<...>;
```

##Output
```
Hello WORLD!

List: 0, 1, 2
```

#Performance

Yea, yea, but how fast does your car go

```
$ perl6 -Ilib bench.pl6; perl6 -Iblib/lib bench.pl6
Benchmark:
Timing 1000 iterations of parsing, render...
   parsing: 11.5185 wallclock secs @ 86.8168/s (n=1000)
    render: 0.1311 wallclock secs @ 7629.1286/s (n=1000)
Benchmark:
Timing 1000 iterations of parsing, render...
   parsing: 11.4190 wallclock secs @ 87.5737/s (n=1000)
    render: 0.1288 wallclock secs @ 7762.4681/s (n=1000)
```

#Author

Tony O'Dell

#License

You can use and distribute this module under the terms of the The Artistic License 2.0.
See the `LICENSE` file included in this distribution for complete details.
