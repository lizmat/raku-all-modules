# Configuration refinements
[![Build Status](https://travis-ci.org/MARTIMM/config-datalang-refine.svg?branch=master)](https://travis-ci.org/MARTIMM/config-datalang-refine)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/MARTIMM/config-datalang-refine?branch=master&passingText=Windows%20-%20OK&failingText=Windows%20-%20FAIL&pendingText=Windows%20-%20pending&svg=true)](https://ci.appveyor.com/project/MARTIMM/config-datalang-refine/branch/master)
[![License](http://martimm.github.io/label/License-label.svg)](http://www.perlfoundation.org/artistic_license_2_0)

# Synopsis

The following piece of code
```
use Config::DataLang::Refine;

my Config::DataLang::Refine $c .= new(:config-name<myConfig.toml>);

my Hash $hp1 = $c.refine(<options plugin1 test>);
my Hash $hp2 = $c.refine(<options plugin2 deploy>);
```
With the following config file in **myConfig.toml**

```
[options]
  key1 = 'val1'

[options.plugin1]
  key2 = 'val2'

[options.plugin1.test]
  key1 = false
  key2 = 'val3'

[options.plugin2.deploy]
  key3 = 'val3'
```
Will get you the following as if *$hp\** is set like
```
$hp1 = { key2 => 'val3'};
$hp2 = { key1 => 'val1', key3 => 'val3'};
```

A better example might be from the MongoDB project to test several server setups, the config again in TOML format;
```
[mongod]
  journal = false
  fork = true
  smallfiles = true
  oplogSize = 128
  logappend = true

# Configuration for Server 1
[mongod.s1]
  logpath = './Sandbox/Server1/m.log'
  pidfilepath = './Sandbox/Server1/m.pid'
  dbpath = './Sandbox/Server1/m.data'
  port = 65010

[mongod.s1.replicate1]
  replSet = 'first_replicate'

[mongod.s1.replicate2]
  replSet = 'second_replicate'

[mongod.s1.authenticate]
  auth = true
```
Now, to get run options to start server 1 one does the following;
```
my Config::DataLang::Refine $c .= new(:config-name<mongoservers.toml>);
my Array $opts = $c.refine-str( <mongod s1 replicate1>, :C-UNIX-OPTS-T2);

# Output
# --nojournal, --fork, --smallfiles, --oplogSize=128, --logappend,
# --logpath='./Sandbox/Server1/m.log', --pidfilepath='./Sandbox/Server1/m.pid',
# --dbpath='./Sandbox/Server1/m.data', --port=65010, --replSet=first_replicate
```
Easy to run the server now;
```
my Proc $proc = shell(('/usr/bin/mongod', |@$opts).join(' '));
```

# Description

The **Config::DataLang::Refine** class adds facilities to use a configuration file and gather the key value pairs by searching top down a list of keys thereby refining the resulting set of keys. Boolean values are used to add a key without a value when True or to cancel a previously found key out when False.

# Documentation

Look for documentation and other information at
* [Config::DataLang::Refine](https://github.com/MARTIMM/config-datalang-refine/blob/master/doc/Refine.pdf)
* [Release notes](https://github.com/MARTIMM/config-datalang-refine/blob/master/doc/CHANGES.md)
* [Todo and Bugs](https://github.com/MARTIMM/config-datalang-refine/blob/master/doc/TODO.md)
