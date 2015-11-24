#Perl6 Role 'Pluggable'

Role that assists in finding plugins for a module .. 

##Currently handles:
* Custom directory searching (Module::$PluginDir)
* Customer perl module matching, by default it just looks for .pm6
* Finding plugins outside of the current modules namespace 

##Example

###Installed Plugins
```
a::Plugins::Plugin1
a::Plugins::Plugin2
a::Plugins::PluginClass1::PluginClass2::Plugin3
```

```perl6
use Pluggable; 

class a does Pluggable {
  method listplugins () {
    @($.plugins).join("\n").say;
  }
}

a.new.listplugins;
```
##Output
```
a::Plugins::Plugin1
a::Plugins::Plugin2
a::Plugins::PluginClass1::PluginClass2::Plugin3
```

##Options

Usage:  $.plugins( :$plugin, :$module, :$pattern )

###:$plugin (mandatory)

Default: ```Plugins```
Plugin should be set to the plugin directory

###:$module (optional)
Default: ```::?CLASS```
Can be set to another module name if you'd like to look for Plugins available to another module

###:$pattern (optional)
Default: ```/ '.pm6' $ /```
Can be set to anything, another useful option would be ```/ [ '.pm6' | '.pm' ] $ /```, this is used to match against the IO.basename in order to determine if the file contains a module.  ```Pluggable``` only adds the module to the list if it can ```require``` said module.

#License

Free, do whatever you want with this.

-[@tony-o](https://www.gittip.com/tony-o/)
