use IO::Select;
use Test;
plan 4;

{
    my $select = IO::Select.new;
    my $r      = open 'README';
    $select.add($r);
    is $select.can_read(1).elems, 1;
    is $select.can_write(0).elems, 0;
}

{
    my $select = IO::Select.new;
    my $r      = open 'README2', :w;
    $select.add($r);
    is $select.can_write(1).elems, 1;
    is $select.can_read(0).elems, 0;
    unlink 'README2';
}
