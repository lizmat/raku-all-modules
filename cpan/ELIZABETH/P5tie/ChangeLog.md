# Version 0.0.1
Initial implementation.

# Version 0.0.2
Add support for DESTROY (tied arrays and hashes only)

# Version 0.0.3
No longer accept strings for class names.  For some reason the ::() lookup
cannot find imported precompiled classes inside a precomped module.  Also
removed some more now redundant code.

# Version 0.0.4
Apparently we also need a Numeric method, to handle +@a and +%h.
.STORE is supposed to return self
Added some stringification methods: .Str, .perl and .join.

# Version 0.0.5
Fixed .perl for tied arrays, added .gist method
Added .Str, .perl, .gist, .join for tied hashes
