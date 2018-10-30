
class Dependency::Sort
{

has @Depindex;
has @Depthis;
has @Depon;
has @Depend;
has @!Bot;

has $.error_message;

my $debug = False;


method result
{
 return @!Bot;
}


# a, b is a hash
method add_dependency ( $a, $b ) {    #(a cols1%rowtype,b cols1%rowtype, summary boolean) IS
#    my ( $a, $b ) = ( shift, shift );
    my $f = -1;        #boolean=false;
    {
        for ( 0 .. @Depthis.end ) -> $i {
            if (    @Depthis[$i].<itemid> == $a.<itemid>
                and @Depon[$i].<itemid> == $b.<itemid> )
            {
                $f = 1;
                last;
            }
        }
        if ( $f >= 0 ) {
            return;
        }
        if ($debug)
        {
        print(    'adding dependency:'
                ~ ( $a.<name> ) ~ ' '
                ~ ( $b.<name> )
                ~ "\n" );
        print(    'adding dependency2:'
                ~ ( $a.<itemid> ) ~ ' '
                ~ ( $b.<itemid> )
                ~ "\n" );
        }
        push @Depthis, $a;
        push @Depon,   $b;
    }
}

method serialise {
    my @Depthis2;        # depTyp;
    my @Depon2;          #depTyp;
    my $Depsummary2;     # depTyp2;
    my $oldnodeindex;    # number(10);
    my @Node;            # nodeTyp;
    my $Nodeindex;       # number;
    {

        #copy
        for ( 0 .. @Depthis.end ) -> $i  {
            @Depon2[$i]   =  $(my % =   %(@Depon[$i]));
            @Depthis2[$i] = $(my % =  %(@Depthis[$i]));
            print(    'Dep '
                    ~ @Depthis2[$i].<name> ~ ' '
                    ~ @Depon2[$i].<name>
                    ~ "\n" ) if $debug;
        }

        $Nodeindex = 0;
        for ( 0 .. @Depthis.end ) -> $i  {

            if ( not defined @Node[ @Depon2[$i].<itemid> ] ) {
                @Node[ @Depon2[$i].<itemid> ] = 0;
                $Nodeindex = $Nodeindex + 1;
            }
           
            if ( @Depthis2[$i].<itemid> != -1 ) {
                if ( not defined @Node[ @Depthis2[$i].<itemid> ] ) {
                    @Node[ @Depthis2[$i].<itemid> ] = 1;

                    #independent
                    $Nodeindex = $Nodeindex + 1;
                }
                else {
                   
                    @Node[ @Depthis2[$i].<itemid> ]
                        = ( @Node[ @Depthis2[$i].<itemid> ] // 0 ) + 1;

                    #print "dependent @Node[ @Depthis2[$i].<itemid> ]\n";

                    #dependent
                }
            }

        }

       if $debug {
        for ( 0 .. @Node.end ) -> $i  {
            print "item id $i depends on that many: @Node[$i] \n" if defined @Node[$i];
        }
        }
        print "\n";

        $oldnodeindex = $Nodeindex;

        print( 'nodeindex initial ' ~ $Nodeindex ~ "\n" ) if $debug;
       #number of nodes processed, all should be processed
        while ( $Nodeindex > 0 ) {

            ###collect found independent/ dependent nodes ###
            for ( 0 .. @Depthis.end ) ->  $i  {

                print(    'dep examined '
                        ~ @Depthis2[$i].<itemid> ~ ' '
                        ~ @Depon2[$i].<itemid>
                        ~ "\n" ) if $debug;
                print ('node 2:',@Node[2] // "Mu","\n") if $debug;
                # removes independent nodes
                # that have no dependencies
                if ( @Depon2[$i].<itemid> != -1 )
                {    ## node has not been used yet * /
                        #print('on '.Depon2[$i].name);
                     #print('on ref '.to_char($Node(Depon2[$i].<itemid>).ref));
                      print ("node before pushed on:",@Node[ @Depon2[$i].<itemid> ] ," id: ",@Depon2[$i].<itemid> ,"\n") if $debug;
                      
                    if (defined( @Node[ @Depon2[$i].<itemid> ])  and @Node[ @Depon2[$i].<itemid> ] == 0 )
                    {    ## independent node * /
                         #print('Ref0 '.Depon2[$i].name.' '.to_char(Depon2[$i].<itemid>));
                        push @!Bot, @Depon[$i];
                        print "pushed on @Depon2[$i].<itemid>\n" if $debug;
                        @Node[ @Depon2[$i].<itemid> ]
                            = Mu;    ## to turn off repetitions * /
                         print ("node after pushed on:",@Node[ @Depon2[$i].<itemid> ] // "Mu" ,"\n") if $debug;
                         #print('Ref0 check '.Depon2[$i].name.' '.to_char(Depon2[$i].<itemid>));
                        $Nodeindex = $Nodeindex - 1;
                    }
                }
                if ( @Depon2[$i].<itemid> != -1
                    and ( @Node[ @Depon2[$i].<itemid> ] // 0 ) == 0 )

                    #print "Node:@Node[@Depon2[$i].<itemid>]\n";
                    #if ( @Node[ @Depon2[$i].<itemid> ] == 0 )
                {        ## already processed
                         # or not independent node * /
                         #print(Depthis2[$i].<itemid>);
                    print "entered reducing dependency number of this\n" if $debug;
                    if ( @Depthis2[$i].<itemid> != -1 )
                    {    ## not a single on node * /
                        @Node[ @Depthis2[$i].<itemid> ]
                            = @Node[ @Depthis2[$i].<itemid> ] - 1;

            #print('dec this '.Depthis2[$i].name);
            #print('dec this ref '.to_char(Node(Depthis2[$i].<itemid>).ref));
                    }
                    @Depon2[$i].<itemid>
                        = -1;  ## this dependency is deleted for this node * /
                }

                ## dependent nodes may become independent * /
                if ( @Depthis2[$i].<itemid> != -1 ) {    ## node exists */ /
                        #*delete related dependency if a node is missing * /
                        #print('this '.Depthis2[$i].name);
                     #print('this ref '.to_char(Node(Depthis2[$i].<itemid>).ref));

                  #  print ("cond ",defined @Node[ @Depthis2[$i].<itemid> ] );
                    if ( defined( @Node[ @Depthis2[$i].<itemid> ]) and @Node[ @Depthis2[$i].<itemid> ] == 0 )
                    {    ## independent node * /
                         #print('Ref0.1 '.Depon2[$i].name.' '.to_char(Depon2[$i].<itemid>));

                        push @!Bot, @Depthis[$i];
                        print "pushed this @Depthis2[$i].<itemid>\n" if $debug;
                        @Node[ @Depthis2[$i].<itemid> ]
                            = Mu;    ## to turn off repetitions * /
                        @Depthis2[$i].<itemid> = -1;
                        $Nodeindex = $Nodeindex - 1;
                    }
                }
                if ($debug)
                {
                for ( 0 .. @Node.end ) -> $i  {
                    print "$i: @Node[$i] " if defined @Node[$i];
                }
                print "\n";
                for ( 0 .. @Depthis.end ) -> $i  {
                    print "@Depthis2[$i].<itemid> -> @Depon2[$i].<itemid> ";
                }
                print "\n";
                }
                print( 'nodeindex: ' ~ $Nodeindex ~ "\n" ) if $debug;
            }

            print( 'nodeindex while' ~ $Nodeindex ~ "\n" ) if $debug;
            if ( $oldnodeindex == $Nodeindex ) {
                #print("Warning: circular reference found!\n");
                $!error_message = "Warning: circular reference found!\n";
                return False;
                last;
            }
            $oldnodeindex = $Nodeindex;
        }
    }
## at this point Bot contains the serialised nodes  for non-summaries * /

   if ($debug)
   {
    print("Part I.\n");
    for ( 0 .. @!Bot.end ) -> $i  {
        print( @!Bot[$i].<name> ~ "\n" );
    }
   }
  return True;
}
method test
{
my %h;
my %g;
%h<itemid> = 1;
%g<itemid> = 2;
%h<name>   = '1';
%g<name>   = '2';

my %j  = ( "itemid", 3, "name", 3 );
my %j4 = ( "itemid", 4, "name", 4 );

my $s = Dependency::Sort.new();

$s.add_dependency( %h, %g );
$s.add_dependency( %h, %j );

$s.add_dependency( %j, %j4 );
$s.add_dependency( %j, %g );

$s.serialise;
say $s.result.perl;

$s.add_dependency( %g, %j );

#Adddependency( %j, %h );
if !$s.serialise
{
  die $s.error_message;
}
say $s.result.perl;
}
}


