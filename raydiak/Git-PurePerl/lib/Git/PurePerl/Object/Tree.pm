use Git::PurePerl::Object;
unit class Git::PurePerl::Object::Tree is Git::PurePerl::Object;
use Git::PurePerl::DirectoryEntry;

has $.kind = 'tree';
has Git::PurePerl::DirectoryEntry @.directory_entries is rw;

submethod BUILD (:$!kind) {
    my $content = self.content;
    return unless $content;
    my @directory_entries;
    while $content {
        my $space_index = index( $content, ' ' );
        my $mode = substr( $content, 0, $space_index );
        $content = substr( $content, $space_index + 1 );
        my $null_index = index( $content, "\0" );
        my $filename = substr( $content, 0, $null_index );
        $content = substr( $content, $null_index + 1 );
        my $sha1 = substr( $content, 0, 20 ).encode('latin-1').unpack( 'H*' );
        $content = substr( $content, 20 );
        push @directory_entries,
            Git::PurePerl::DirectoryEntry.new(
                :$mode,
                :$filename,
                :$sha1,
                :git(self.git),
            );
    }
    @!directory_entries = @directory_entries;
}

# vim: ft=perl6
