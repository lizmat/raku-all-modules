## Release notes

See [semantic versioning](http://semver.org/). Please note point 4. on
that page: ***Major version zero (0.y.z) is for initial development. Anything may
change at any time. The public API should not be considered stable.***

* 0.5.0
  * Added type C-UNIX-OPTS-T3 to handle negated options specially used on perl6 command line when MAIN sub is defined. :filter is ignored in this case because tis filters out false booleans.
* 0.4.7
  * Bugfix, spaced text not quoted. Caused by backtick test where 0 ticks was an even number of ticks. Added test to see if there are any first.
  * Added tests for backticks.
* 0.4.6
  * Added check for even number of backticks to prevent quoting in the unix type processing C-UNIX-OPTS-T1 and C-UNIX-OPTS-T2. Spaces outside backticks must be quoted manually.
* 0.4.5
  * Bugfixes in pathnames on windows
* 0.4.4
  * Refactoring code into smaller and overseeable methods.
  * Removed an exception.
  * Getting the list of config locations is made more efficient.
* 0.4.3
  * Sharper tests needed on windows
* 0.4.2
  * Change use of constants into enums.
  * Fixed a bug when locations are empty strings or not readable.
  * Die statements now throw a X::Config::DataLang::Refine exception
* 0.4.1
  * Make merge-hash available for external use. Furthermore add a merge-hash routine asking for a 2nd Hash merging directly into $!config returning the result.
  * removed use of module File::HomeDir and use $\*HOME instead
* 0.4.0
  * Possibility to offer a config Hash when instantiating. :merge is turned on.
* 0.3.5
  * housekeeping shores
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
