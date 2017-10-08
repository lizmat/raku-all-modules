use v6;
use lib 'lib';
use Test;

use File::LibMagic;

{
    my %standard = (
        't/samples/foo.foo' => {
            description => 'ASCII text',
            mime-type   => 'text/plain',
            encoding    => rx{'us-ascii'},
        },
        't/samples/foo.c' => {
            description => ( 'ASCII C program text' | 'C source, ASCII text' ),
            mime-type   => 'text/x-c',
            encoding    => rx{'us-ascii'},
        },
        't/samples/tiny.pdf' => {
            description => 'PDF document, version 1.4',
            mime-type   => 'application/pdf',
            encoding    => rx{ 'binary' | 'unknown' },
        },
    );

    my $magic = File::LibMagic.new;

    subtest {
        test-flm( $magic, %standard );
    }, 'standard magic file';
}

{
    my $standard_file = '/usr/share/file/magic.mgc'.IO;;
    skip-rest "The standard magic file must exist at $standard_file"
         unless $standard_file ~~ :e;

    my %info = File::LibMagic.new.from-filename($standard_file);
    skip-rest "The file at $standard_file is not a magic file"
         unless %info<description> ~~ rx{'magic binary file'};

    my %custom = (
        't/samples/foo.foo' => {
            description => 'A foo file',
            mime-type   => 'text/plain',
            encoding    => rx{'us-ascii'},
        },
        't/samples/foo.c' => {
            description => ( 'ASCII C program text' | 'C source, ASCII text' ),
            mime-type   => 'text/x-c',
            encoding    => rx{'us-ascii'},
        },
    );

    my $magic = File::LibMagic.new(
        magic-files => [
            't/samples/magic',
            $standard_file,
        ],
    );

    subtest {
        test-flm( $magic, %custom );
    }, 'custom magic file';
}

sub test-flm (File::LibMagic $magic, %tests) {
    for %tests.kv -> $file, %test {
        subtest {
            subtest {
                test-info(
                    %test,
                    $magic.from-filename($file),
                );
            }, 'from-filename';

            subtest {
                my $buffer = $file.IO.slurp( :bin( $file ~~ / '.pdf' $ / ) );
                test-info(
                    %test,
                    $magic.from-buffer($buffer),
                );
            }, 'from-buffer';

            subtest { 
                my $handle = $file.IO.open(:r);
                test-info(
                    %test,
                    $magic.from-handle($handle),
                );
            }, 'from-handle';
        }, $file;
    }
}

sub test-info( %test, %info ) {
    for <description mime-type encoding> -> $field {
        ok(
            %info{$field}.defined,
            "$field is defined"
        ) or next;

        cmp-ok(
            %info{$field},
            '~~',
            %test{$field},
            $field
        );
    }

    ok(
        %info<mime-type-with-encoding>.defined,
        'mime-type-with-encoding is defined'
    ) or return;

    like(
        %info<mime-type-with-encoding>,
        rx{ "%info<mime-type>" '; charset=' "%info<encoding>" },
        'mime-type-with-encoding'
    );
}

done-testing;
