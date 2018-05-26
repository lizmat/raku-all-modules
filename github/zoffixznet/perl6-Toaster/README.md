[![Build Status](https://travis-ci.org/zoffixznet/perl6-Proc-Q.svg)](https://travis-ci.org/zoffixznet/perl6-Proc-Q)

# Live Site

The data for latest toastings I run is available at [toast.perl6.party](https://toast.perl6.party)


# WARNING!! DANGERUS STUF AHED!

Ecosystem toasting is Serious Business™. **You're LITERALLY running
arbitrary code from hundreds of strangers!**

It's HIGHLY UNrecommended to run this software on anything but a throw-away
install that contains no sensitive data. Are you OK if ALL the files on the
system published somewhere publicly but without you being able to ever get them
again? If not, don't run this software!

# Rakudo Prereq

You need Rakudo `v2017.05.380.*` or newer to run this software.

# Blank Debian GCE VM Setup

On an out-of-the-box Debian, run these commands to prepare the system for
toasting:

```bash
    sudo apt-get update
    sudo apt-get -y upgrade
    sudo apt-get -y install build-essential git curl aptitude libssl-dev \
        wget htop zip sqlite3 time \

        # libs needed by modules
        uuid-dev #LibUUID

    \curl -L https://install.perlbrew.pl | bash
    git clone https://github.com/tadzik/rakudobrew ~/.rakudobrew
    echo 'source ~/perl5/perlbrew/etc/bashrc' >> ~/.bashrc
    echo 'export PATH=~/bin:~/.rakudobrew/bin:~/.rakudobrew/moar-master/install/share/perl6/site/bin:$PATH' >> ~/.bashrc
    wget https://temp.perl6.party/.bash_aliases
    echo 'source ~/.bash_aliases' >> ~/.bashrc
    source ~/.bashrc
    perlbrew install perl-5.26.0 --notest -Duseshrplib -Dusemultiplicity
    perlbrew switch perl-5.26.0
    perlbrew install-cpanm
    rakudobrew build moar
    rakudobrew build zef

    # This one is to ensure git doesn't freeze up, waiting for a pass on some
    # dists that have wrong URL for source. The script gives it bogus pass
    # to use, so it just fails authen and moves on
    echo -e '#!/usr/bin/env perl6\nsay 42' > ~/bin/fake-ask-pass
    chmod +x ~/bin/fake-ask-pass
    echo 'export GIT_ASKPASS=~/bin/fake-ask-pass' >> ~/.bashrc

    # ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼
    # ▼▼▼▼▼▼▼▼▼▼ use your own email in that config file ▼▼▼▼▼▼▼▼▼▼▼▼▼
    # ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼
    mkdir .cpanreporter
    echo 'email_from=zoffix@cpan.org' > ~/.cpanreporter/config.ini

    git clone https://github.com/zoffixznet/perl6-Toaster toaster
    cd toaster
    zef --serial --/test --depsonly install .

    # ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼
    # ▼▼▼▼▼▼▼▼▼▼ specify which commits/tags to toast       ▼▼▼▼▼▼▼▼▼▼
    # ▼▼▼▼▼▼▼▼▼▼ command below toasts 2017.07, then master ▼▼▼▼▼▼▼▼▼▼
    # ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼
    perl6 bin/toaster-perl6 2017.07 master
```

# Toasting

To toast the ecosystem, run the `bin/toaster-perl6` command, giving it as
positionals args the tags, branches or commits (basically anything
`git checkout` will accept). The toaster will build rakudos for the requested
commits so ensure you've got space for that + anything the modules need, for
each of the commits you're toasting.

**Note:** toasting takes ages (~50 minutes on a 24-core box), so don't go wild
with toasting all the commits, if you're not prepared to wait for it.

The toaster will create an SQLite database in `toast.sqlite.db` file, with
toasting results for each of the toasted module, and each of the given commits.

```bash
    perl6 bin/toaster-perl6 2017.03 2017.05 some-branch master 64e898f9baa159e2019
```

# Viewing

## Perl Mojolicious

The [Molicious](http://mojolicious.org/)-based viewer is currently the most up-to-date
and recommended. To use it, install Perl, unless you already have it:

```bash
\curl -L https://install.perlbrew.pl | bash
echo 'source ~/perl5/perlbrew/etc/bashrc' >> ~/.bashrc
source ~/.bashrc
perlbrew install perl-5.26.2 --notest -Duseshrplib -Dusemultiplicity
perlbrew switch perl-5.26.2
perlbrew install-cpanm
```

Then install necessary Perl modules:

```bash
    cpanm -vn Mojolicious::Lite Mojo::SQLite List::Util
```

Then run the development version of the viewer if you want extra
debugging output:

```bash
   ./morbo
```

Or just run the production version of the viewer:

```bash
    ./hyp
```

Then go to `http://localhost:3333` to view the site.

## Rakudo

To use rakudo for running the viewer, run `bin/toaster-viewer` and then go to `http://localhost:3333` to
view the site.

You'll need *Tardigrade* Web framework to run it:

```bash
zef --/test install https://github.com/zoffixznet/tardigrade/archive/master.zip
```

Note that currently this method appears to leak memory in one of the supporting modules.

## SQL

Alternatively, just use SQL queries to view the results. They're all in
the generated `toast.sqlite.db` file.

```bash
sqlite3 toast.sqlite.db
```

----

#### REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Toaster

#### BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Toaster/issues

#### AUTHOR

Zoffix Znet (http://perl6.party/)

#### LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

The `META6.json` file of this distribution may be distributed and modified
without restrictions or attribution.
