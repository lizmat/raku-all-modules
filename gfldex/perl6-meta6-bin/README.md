# META6::bin
[![Build Status](https://travis-ci.org/gfldex/perl6-meta6-bin.svg?branch=master)](https://travis-ci.org/gfldex/perl6-meta6-bin)

Create and check META6.json files and module skeletons.

Depends on `git` and `curl` in `$PATH` and got a timeout of 60s for each call
to both. Those are used to setup a git and github repo.

Module skeletons include basic directories, `META6.json`, `t/meta.t`,
`.travis.yml` and a `README.md`. The latter includes a link to
[travis-ci](https://travis-ci.org/).

# SYNOPSIS

    meta6 --create --name=<project-name-here> --force
    meta6 --check
    meta6 --create-cfg-dir --force
    meta6 --new-module --name=<Module::Name::Here> --force --skip-git --skip-github
    meta6 --fork-module=<Module::Name::Here>
    meta6 --add-dep=<Module::Name::Here>
    meta6 --pull-request
    meta6 --set-license="license name or URL"
    meta6 --add-author="Another T. Author <another.t.author@somewhere.place>"

## Use as a Module

    use v6.c;

    use META6::bin :HELPER;
    
    &META6::bin::try-to-fetch-url.wrap({
        say "checking URL: ⟨$_⟩";
        callsame;
    });
    
    META6::bin::MAIN(:check);

# General Options

    --meta6-file=<path-to-META6.json> # defaults to ./META6.json

# Create Options

    --name
    --description
    --version # defaults to 0.0.1
    --perl # defaults to 6.c
    --author # defaults to user/name from ~/.gitconfig
    --auth # defaults to credentials/username from ~/.gitconfig

# Fork Module Options

    --fork-module=<Module::Name::Here> # module name as to be found in the ecosystem

This will seach a module by name in the ecosystem. If it's a github repo that
repo will be forked and cloned to the local FS. If there is a `META6.info` but
no `t/meta.t`, the file and its dependancy will be added and commited to the
local git repo.

# Pull Request Options

    --pull-request
    --title=`git log|head 1` # defaults to last commit message
    --message=''
    --head=master # branch in your fork
    --base=master # branch in upstream repo
    --repo-name # defaults to repo name provided in META6.info

Pull request need to tell github where to create the PR at. That in turn
requires a proper `META6.json` to get the repo name from.

# Config dir

The config dir resides at `~/.meta6` and holds a folder called `skeleton` for
additional files to be copied into any new project. This is where you put your
default `LICENSE` or alternate `.gitignore`.

The config dir, a default meta6.cfg and its default subdirs are created with
`--create-cfg-dir`.

Any executable under `pre-create.d`, `post-create.d` and `post-push.d` are
sorted and executed with a timeout of 60 seconds each. Files that end in `~`
are filtered out.

The config directory can hold a `github-token.txt` file that is used to help
`curl` to connect to github. The [token](https://github.com/settings/tokens)
needs the scopes `repo`, `user/read:user` and `user/email`. Please note that
`git` itself can handle a `~/.netrc`-file and github will accept a token
instead of a password.
