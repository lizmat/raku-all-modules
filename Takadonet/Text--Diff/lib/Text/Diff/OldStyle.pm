class Text::Diff::OldStyle {
# sub _op {                                                                                         
#     my $ops = shift;                                                                              
#     my $op = $ops->[0]->[OPCODE];                                                                 
#     $op = "c" if grep $_->[OPCODE] ne $op, @$ops;                                                 
#     $op = "a" if $op eq "+";                                                                      
#     $op = "d" if $op eq "-";                                                                      
#     return $op;                                                                                   
# }                                                                                                 

# sub Text::Diff::OldStyle::hunk_header {                                                           
#     shift; ## No instance data                                                                    
#                                                                                                   
#     my $ops = pop;                                                                                

#     my $op = _op $ops;                                                                            

#     return join "", _range( $ops, A, "" ), $op, _range( $ops, B, "" ), "\n";                      
# }                                                                                                 

# sub Text::Diff::OldStyle::hunk {                                                                  
#     shift; ## No instance data                                                                    
#     pop; ## ignore options                                                                        
#     my $ops = pop;                                                                                
#     ## Leave the sequences in @_[0,1]                                                             

#     my $a_prefixes = { "+" => undef,  " " => undef, "-" => "< "  };                               
#     my $b_prefixes = { "+" => "> ",   " " => undef, "-" => undef };                               

#     my $op = _op $ops;                                                                            

#     return join( "",                                                                              
#         map( _op_to_line( \@_, $_, A, $a_prefixes ), @$ops ),                                     
#         $op eq "c" ? "---\n" : (),                                                                
#         map( _op_to_line( \@_, $_, B, $b_prefixes ), @$ops ),                                     
#     );                                                                                            
} 
