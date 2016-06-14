# Configuration refinements
[![Build Status](https://travis-ci.org/MARTIMM/config-datalang-refine.svg?branch=master)](https://travis-ci.org/MARTIMM/config-datalang-refine)

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

The **Config::DataLang::Refine** class adds facilities to use a configuration file and gather the key value pairs by searching top down a list of keys thereby refining the resulting set of keys. Boolean values are used to add a key without a value when True or to cancel a previously found key out when False. For details see the pod file or [pdf](https://github.com/MARTIMM/config-datalang-refine/blob/master/doc/Refine.pdf).

* 0.3.4
  * Panda problems
* 0.3.3
  * Added modes used to create strings with refine-str.
* 0.3.2
  * Removed **refine-filter()** and added named argument **:filter** to **refine()**.
  * Renamed **refine-filter-str()** to **refine-str()** and added named argument **:filter**.
* 0.3.1
  * Bugfix in use of **:locations** array and relative/absolute path usage in **:config-name**.
* 0.3.0
  * Use **:data-module** to select other modules to load other types of config files. Possible configuration data languages are Config::TOML and JSON::Fast.
* 0.2.0
  * methods **refine()**, **refine-filter()**. **refine-filter-str()** added
* 0.1.0
  * setup using config language **Config::TOML**
  * method **new()** to read config files and **:merge**
  * method refine to get key value pairs
* 0.0.1 Start of the project
