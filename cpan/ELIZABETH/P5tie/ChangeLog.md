# Version 0.0.1
Initial implementation.

# Version 0.0.2
Add support for DESTROY (tied arrays and hashes only)

# Version 0.0.3
No longer accept strings for class names.  For some reason the ::() lookup
cannot find imported precompiled classes inside a precomped module.  Also
removed some more now redundant code.
