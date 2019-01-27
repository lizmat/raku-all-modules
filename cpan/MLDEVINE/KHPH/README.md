NAME
====

KHPH.pm6

AUTHOR
======

Mark Devine <mark@markdevine.com>

VERSION
=======

0.0.4

TITLE
=====

Keep Honest People Honest

SUBTITLE
========

Unsecure Reversible Obfuscated Character Storage & Retrieval

Disclaimer
==========

Don't use this module for storing your secrets. It's not secure. Any instance of using reversible encryption/obfuscation can be reversed by someone who puts in enough effort. A cracker can walk through the algorithm, perform the mirror-image of the steps, and eventually read your secret.

But imagine that you're in a corner where you need to run a batch job using an application client that requires a USERID/PASSWORD, and the vendor isn't planning on making any authentication improvements any time soon. It appears that you're forced to store a clear-text secret in a file with your head held in shame.

Hopefully the system you're working on is network-isolated to some reasonable degree. Hopefully the system you're working on registers users on an as-needed-only basis. You'll put the secret characters in a directory/file and judiciously apply DAC controls to tighten security (chown/chgrp/chmod). 'root' will be able to look at your secret with a quick `cat` command, but root access is controlled so there's some rationale for accepting that leak. Maybe, but maybe not. 'root' can tempt some administrators to do not-so-ethical things simply because they can without any resistance.

You can't protect your secret this way, that's for sure. But you can reduce the likelihood of exposing your secret inadvertently to typically honest, curious people who are just poking around. If you sufficiently scramble the secret string before storing it, reversing the obfuscation manually could induce just enough ennui and frustration to dissuade the amateur cracker sitting in the next cubicle.

Use this module if you are going to do something massively unsecure anyway. If your staff doesn’t have any Snowden-wannabes, then using this module would be better than clear-text storage.

Keep(ing) Honest People Honest is not an ambition to provide the ultimate secure non-interactive reversible algorithm. There really isn't such a thing. This module's obfuscation is trivial. Keep looking for something better to protect your secrets.

Description
===========

This module will make a mess of your secret, stash it wherever you specify, then expose it to you whole again when you ask for it, interactively or in batch (I.e. CRON). ‘root’ can’t expose it directly, unless ‘root’ originally stored it. SU’ing into the owner’s account from a different account won’t expose it directly either. It’s not in the direct line of site by anyone other than the owner, but not by much.

It's like the difference in playing hide-and-go-seek with a 2-year-old versus a 10-year-old. The 10-year-old stays out of site and is kind of clever about it, but you can still find them if you look hard enough.

Synopsis
========

    use KHPH;
    my KHPH $secret-string .= new(
                                    herald     => 'Enter myapp password',
                                    stash-path => '/tmp/myapp/mysecret.khph',
                                 );
    say $secret-string.expose;

Methods
=======

new()
-----

Generate a KHPH object

    :$herald

Optional announcement used only when interactively stashing the secret.

    :$stash-path

Specify the path (directories/file) to create or find the stash file.
Always use a subdirectory to store the secret, as KHPH will chmod the directory containing the stash file.

expose()
--------

Return the secret as a clear-text Str.

Example
=======

The following stand-alone script will manage the password stash of 'myapp' in the user's home directory. Run it interactively one time to stash your secret, then you (not someone else) can run it any time to expose the secret.

In this example, we'll make a script in our home directory named 'myapp-pass.pl6' as follows:

    #!/opt/rakudobrew/bin/perl6
    use KHPH;
    my KHPH $passwd .= new(:stash-path(%*ENV<HOME> ~ '/.myapp/password.khph')).expose.print;

Run ~/myapp-pass.pl6 once interactively to stash the secret.

Then in your ancient application client:

    dsmadmc -id=MYSELF -password=`~/myapp-pass.pl6` QUERY SESSION FORMAT=DETAILED

This particular application client is smarter than most, in that the vendor re-writes the args when the program launches so that a `ps` will only display `-password=*******` instead of the actual entered password. Not all vendors pay attention to such details, so beware -- `ps` could be displaying the secret after all of your efforts to protect it!

Limitations
===========

Only developed on Linux.
