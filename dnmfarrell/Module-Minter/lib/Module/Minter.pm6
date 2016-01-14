use Software::License;
use File::Directory::Tree;

module Module::Minter
{
    our grammar Legal-Module-Name
    {
        token TOP { ^ <identifier> [<separator><identifier>] ** 0..* $ }
        token identifier { <[A..Za..z_]> <[A..Za..z0..9]> ** 0..* } # leading alpha or _ only
        token separator { \:\: } # colon pairs only
    }

    sub mint-new-module (Str:D $filepath, Str:D $author, Str:D $license_name='Artistic2') is export
    {
        # extract module name from filepath
        my @filepath_parts = $filepath.split(/\/|\\/);
        my $module_name = @filepath_parts.pop.subst(/\-+/, '::', :g);

        # check module name is ok
        unless Legal-Module-Name.parse($module_name)
        {
            die 'Error, illegal module name. A Module name must start with a letter or underscore, contain only alphanumeric characters and separate package names with ::';
        }

        # convert module name to root dir name
        my $root_dir_name = $module_name.subst(/\:\:/, '-', :g);
        my $root_dir_path = join('/', @filepath_parts, $root_dir_name);

        # check dir doesn't exist
        die "Error, cannot continue as directory: '$root_dir_path' already exists"
            if $root_dir_path.IO ~~ :e;

        # create root dir
        $root_dir_path.IO.mkdir;
        say "Creating structure: $root_dir_path";

        # create lib
        my @module_name_parts = $root_dir_name.split(/\-/);
        my $main_module_filename = @module_name_parts.pop;
        my $lib_path = $root_dir_path ~ '/lib/' ~ @module_name_parts.join('/');
        mktree($lib_path);
        say $lib_path;
        my $main_module_path = make-main-module($lib_path, $module_name);

        # create t
        my $test_path = $root_dir_path ~ '/t';
        $test_path.IO.mkdir;
        say $test_path;
        make-main-test($test_path, $module_name);

        # make misc files
        my $license_path = make-license($root_dir_path, $author, $license_name);
        say $license_path;

        my $meta_path = make-meta($root_dir_path, $module_name, $main_module_path, $author);
        say $meta_path;

        return $root_dir_path;
    }

    sub make-main-module (Str:D $parent_dir, Str:D $module_name)
    {
        my $module_filename = $module_name.split(/\:\:/)[*-1];
        my $full_path = $parent_dir ~ '/' ~ $module_filename ~ '.pm6';
        my $fh = $full_path.IO.open(:w);

        my $file_contents = qq:to/END/;
        module {$module_name}:ver<0.01>
        \{
            # do something
        \}
        END

        $fh.say($file_contents);
        return $full_path;
    }

    sub make-main-test (Str:D $parent_dir, Str:D $module_name)
    {
        my $module_filename = $module_name.split(/\:\:/)[*-1];
        my $full_path = $parent_dir ~ '/' ~ $module_filename ~ '.t';
        my $fh = $full_path.IO.open(:w);

        my $file_contents = qq:to/END/;
        use Test;
        use lib 'lib';

        plan 1;

        use $module_name; pass "Import $module_name";

        END
        $fh.say($file_contents);
        return $full_path;
    }

    sub make-meta (Str:D $parent_dir, Str:D $module_name, Str:D $main_module_path, Str:D $author)
    {
        my $full_path = $parent_dir ~ '/META.info';
        my $fh = $full_path.IO.open(:w);

        my $file_contents = qq:to/END/;
        \{
            "name" : "$module_name",
            "version" : "0.01",
            "description" : "The great new $module_name",
            "author" : "$author",
            "source-url" : "",
            "depends" : [ ],
            "provides" : \{
              "$module_name" : "$main_module_path"
            \},
        \}
        END
        $fh.say($file_contents);

        return $full_path;
    }


    sub make-license (Str:D $parent_dir, Str:D $author, Str:D $license_name?)
    {
        my $license = Software::License.new;
        my $license_text = $license.full-text($license_name, $author); # defaults to current year
        my $full_path = $parent_dir ~ '/LICENSE';
        my $fh = $full_path.IO.open(:w);

        $fh.say($license_text);

        return $full_path;
    }
}

# vim: set ft=perl6
