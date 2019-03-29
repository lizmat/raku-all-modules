use v6.c;

use Acme::Cow;

unit class Acme::Cow::DragonAndCow:ver<0.0.2>:auth<cpan:ELIZABETH> is Acme::Cow;

my $dragon_and_cow = Q:to/EOC/;
{$balloon}
                 {$tl}                          ^    /^
                    {$tl}                      / \  // \
                       {$tl}     |\___/|      /   \//  .\
                          {$tl}  /O  O  \__  /    //  | \ \           *----*
                            /     /  \/_/    //   |  \  \          \   |
                            @___@`    \/_   //    |   \   \         \/\ \
                           0/0/|       \/_ //     |    \    \         \  \
                       0/0/0/0/|        \///      |     \     \       |  |
                    0/0/0/0/0/_|_ /   (  //       |      \     _\     |  /
                 0/0/0/0/0/0/`/,_ _ _/  ) ; -.    |    _ _\.-~       /   /
                             ,-\}        _      *-.|.-~-.           .~    ~
            \     \__/        `/\      /                 ~-. _ .-~      /
             \____({$el}{$er})           *.   \}            \{                   /
             (    (--)          .----~-.\        \-`                 .~
             //__\\  \__ Ack!   ///.----..<        \             _ -~
            //    \\               ///-._ _ _ _ _ _ _\{^ - - - - ~
EOC

method as_string() { callwith($dragon_and_cow) }
