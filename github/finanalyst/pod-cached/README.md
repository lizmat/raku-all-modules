# Pod::Cached

Create and Maintain a cache of precompiled pod files

Module to take a collection of pod files and create a precompiled cache. Methods / functions
to add a pod file to a cache.

## Install

This module is in the [Perl 6 ecosystem](https://modules.perl6.org), so you install it in the usual way:

    zef install Pod::Cached


# SYNOPSIS
```perl6
use Pod::Cached;

my Pod::Cached $cache .= new(:path<path-to-cache>, :source<path-to-directory-with-pod-files>);

$cache.update-cache;

for $cache.list-files( :all ).kv -> $filename, $status {
    given $status {
        when Pod::Cached::Valid {say "$filename has valid cached POD"}
        when Pod::Cached::Updated {say "$filename has valid POD, just updated"}
        when Pod::Cached::Tainted {say "$filename has been modified since the cache was last updated"}
        when Pod::Cached::Failed {say "$filename has been modified, but contains invalid POD"}
        when Pod::Cached::New {say "$filename has not yet been added to pod-cache"}
    }
    user-supplied-routine-for-processing-pod( $cache.pod( $filename ) );
}

# Find files with status
say 'These pod files failed:';
.say for $cache.list-files( Pod::Cached::Failed );

# Remove the dependence on the pod source
$cache.freeze;
```
## Notes
-  Str $!path = '.pod6-cache'  
    path to the directory where the cache will be created/kept

-  Str $!source = 'doc'  
    path to the collection of pod files
    ignored if cache frozen

-  @!extensions = <pod pod6>  
    the possible extensions for a POD file

-  verbose = False  
    Whether processing information is sent to stderr.

-  new  
    Instantiates class. On instantiation,
    - get the cache from index, or creates a new cache if one does not exist
    - if frozen, does not check the source directory
    - if not frozen, or new cache being created, verifies
        - source directory exists
        - the source directory contains POD/POD6 etc files (recursively)
        - no duplicate pod file names exist, eg. xx.pod & xx.pod6
    - verifies whether the cache is valid

-  update-cache  
    All files with Status New or Tainted are precompiled and added to the cache
    - Status is changed to Updated (compiles Valid) or Fail (does not compile)
    - Failed files that were previously Valid files still retain the old cache handle
    - Throws an exception when called on a frozen cache

-  freeze  
    Can be called only when there are only Valid or Updated (no New, Tainted or Failed files),
    otherwise dies.  
    The intent of this method is to allow the pod-cache to be copied without the original pod-files.  
    update-cache will throw an error if used on a frozen cache

-  list-files( Status $s)  
    returns an Sequence of files with the given status

-  pod  
    method pod(Str $filename, :$when-tainted='none', :when-failed = 'note')  
    Returns the POD Object Module generated from the file with the filename.  
    When a doc-set is being actively updated, then pod files may be tainted, or failed, and the user may wish
    to choose how to handle them.  
    In a frozen cache, all files have valid status  
    The behaviour of pod can be changed for 'tainted' or 'failed', eg :when-failed='allow'
> Caution: allowing a failed file uses pod in cache, but will die if the pod is new and failed.  

    - 'note' issues an error on stderr
    - 'allow' provides pod, no note
    - 'exit' stops the program at that point
    - none' ignores the pod-name silently


## LICENSE

You can use and distribute this module under the terms of the The Artistic License 2.0. See the LICENSE file included in this distribution for complete details.

The META6.json file of this distribution may be distributed and modified without restrictions or attribution.
