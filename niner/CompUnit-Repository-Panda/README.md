# TITLE

CompUnit::Repository::Panda

# SYNOPSIS

```
    use CompUnit::Repository::Panda;
    use Whatever::Module::Panda::Can::Install;
```

# DESCRIPTION

CompUnit::Repository::Panda automatically tries to install all modules that
your program uses and that are not already installed.

Fully recursive installation will need more infrastructure in
CompUnit::RepositoryRegistry, so we only install modules that are used by
compunits that use CompUnit::Repository::Panda directly.

# AUTHOR

Stefan Seifert <nine@detonation.org>
