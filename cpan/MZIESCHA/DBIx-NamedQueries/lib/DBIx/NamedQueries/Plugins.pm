use v6.c;

role DBIx::NamedQueries::Plugin {
    has %.config;
}

class DBIx::NamedQueries::Plugins {
    has %!plugins = {};

    method add(Str:D $name, DBIx::NamedQueries::Plugin:D $plugin) {
        %!plugins.{$name} = $plugin;
    }

    method get(Str:D $name) {
        return %!plugins.{$name};
    }

    #method detect(DBIx::NamedQueries::Configuration $config) {
    #    for $config.plugins.keys -> $name {
    #        my $plugin_conf= $config.plugins{$name};
    #        my $package = 'DBIx::NamedQueries::Plugin::' ~ $name;
    #        try {
    #            require ::($package);
    #             $.add($name, ::($package).new(config => $plugin_conf));
    #        }
    #    }
    #}
}
