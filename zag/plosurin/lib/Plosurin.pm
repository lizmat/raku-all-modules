use v6;
my $VERSION = '0.02';
class Template {
    has $.namespace ;
    has @.params;
    has $.name;
    has $.comment;
    has $.body;
}

class Param {
    has Bool $!requred = False;
    has $!name='';
    has $!comment='';
}

sub line-and-column(Match $m) {
        my $line   = ($m.orig.substr(0, $m.from).split("\n")).elems;
        # RAKUDO workaround for RT #70003, $m.orig.rindex(...) directly fails
        my $column = $m.from - ('' ~ $m.orig).rindex("\n", $m.from);
        $line, $column;
  }
grammar Plosurin::Template {
    token TOP  { <content>+ }
    token content { $<cnt>=[<struct_if> || <struct_switch> || <struct_foreach> || <raw_text> || <tag> ] }
    token plain_content { [<raw_text> || <tag> ]+}
    rule raw_text { <-[{ }]>+ }
    rule tag {'{' ~ '}' [ <command_import> || <command_print> ] }
    rule command_print { 'print' <variable>}
    rule struct_if { '{' ~ '}' <command_if> 
                        <plain_content>
                       [ '{' ~ '}' <command_elseif> 
                          <plain_content>
                       ]*
                       [ '{' ~ '}' <command_else> 
                          <plain_content>
                       ]?
                       '{' ~ '}' <command_endif> 
    }
    rule command_if {'if' <expression>}
    rule command_else {'else' }
    rule command_elseif {'elseif' <expression>}
    rule command_endif {'/if'}
    rule struct_switch {  '{' ~ '}' <command_switch> 
                         [ '{' ~ '}' <command_case> 
                          <plain_content> ]+
                         [ '{' ~ '}' <command_default> 
                            <plain_content> ]?
                       '{' ~ '}' <command_endswitch> 
    }
    rule command_switch {'switch' <expression> }
    rule command_endswitch {'/switch'}
    rule command_case {'case' <expression_list>}
    rule command_default {'default'}
    rule struct_foreach { '{' <command_foreach> <expression_foreach> '}'
                             <content> 
                          [ '{' <command_ifempty> '}'
                              <content> 
                          ]?
                          '{' <command_endforeach> '}'
    }
    rule command_foreach {'foreach'}
    rule command_endforeach {'/foreach'}
    rule command_ifempty {'ifempty'}
    rule expression_foreach { <variable> 'in' <variable>}

    rule command_import {
        'import'  <attribute> ** 1..2 }
    rule expression { [ \w+ ['=='||'<'||'>'] \w+ || <variable>] }
    rule expression_list { [\w+] ** ',' }
    token variable { '$' \w+ }
#    rule pair  { <string> ':'  <value>     }
    rule attribute { (\w+) '=' '"' (<-['"']>+) '"' }

}

class Plo::Node {
    has Plo::Node @!childs;
    has $!name;
    method dumper {
        return { self.WHAT.perl =>[ @!childs».dumper]};
    }
}

class Plo::raw_text is Plo::Node {
    has $.raw_text;
    method export_perl {
    return $.raw_text;
    }
}
class Plo::command_print is Plo::Node {
    has $.raw_text;
}
class Plo::command_import is Plo::Node {
    has $!file;
    has $!rule;
 method dumper {
    return { self.WHAT.perl =>{ file=> $!file, rule=>$!rule}};    
 }
 method export_perl {
  my $command = "pod6xhtml  -nb -t div -M Perl6::Pod::Lib -c \'=Include $!file";
  if ( $!rule) {
    $command ~= "\($!rule\)";
  }
  $command ~= "\'";
  my $body = qqx% $command %;
  return $body
 }
}

class Plosurin::TActions {
    method TOP ($/)  { make  [ $<content>».ast]}
    method content ($/) {
         make $/.values.[0].ast;
   }
    method raw_text ($/) {
        make Plo::raw_text.new(:raw_text($/));
    }

    method command_print ($/) {
        make Plo::command_print.new(:raw_text($/));
    }

    method attribute ($/) {
        my ($key,$val) = $/[0..1];
        make ~$key => ~$val;
    }

    method command_import ($/) {
        my %attr = $/<attribute>».ast.hash;
        unless ( %attr{'file'}) {
            die  "Bad attr at: " ~ $/.CURSOR.pos ;
        }
    make Plo::command_import.new( |%attr );
    }

    method tag ($/) {
        make $/.values.[0].ast;
    }

}


class  Plosurin::Actions {
   method TOP ($/)  {
    my $namespace = $<namespace><nsname>;
    my @arr = ();
    for $<def_template>.list -> $template  {
     my $tcomment = $template<header><h_comment>;
     my $tparams = $template<header><h_param>;
     my $tmplname = $template<template><template_name>;
     my $tmplbody = $template<template><tmpl_content>;
     @arr.push(Template.new( 
                :namespace($namespace),
                :params($tparams),
                :name($tmplname),
                :comment($tcomment),
                :body($tmplbody)
                ));
    }
    make @arr;
   }
   method namespace ($/) {
    make $/.values.[0].ast
   }
    method h_comment ($/) {
    make $<comment>.ast
    }
   method h_param ($/) {
    my Bool $requred =  "?" ne $<is_notrequired>;
    make Param.new( requred=>$requred , name => $<paramname>, comment=>$<comment> )
   }
}
grammar Plosurin::Grammar {
  token TOP {<namespace> [ <def_template> ]+}
  token namespace {'{namespace' \s* $<nsname>=[\w.]+ '}'}
  rule def_template {  <header>
                       <template> }
  rule header { '/**'\s+
                  <h_comment>?
                  <h_param>*
                '*/'||{
                unless  $/.CURSOR.pos ~~ $/.orig.chars {
                my $m = $/;
                my ($line, $column ) =  line-and-column($/);
                my $near_text = $/.orig.substr( $/.CURSOR.pos -1 , 5);
                die "bad template header at line: $line : pos $column " ~" near:" 
    ~ $/.orig.substr($/.CURSOR.pos-1, 5) ~ "<  "}
                #return 2
                1;}}
  rule h_comment { '*'  <!before '@'>$<comment>=[\N]+}
  rule h_param { '*'  '@param'$<is_notrequired>=['?']?  $<paramname>=[\w+] $<comment>=[\N]+}
  rule template {
        '{template' $<template_name>=<tmpl_name>'}'
        $<tmpl_content>=[ .*? ]
        '{/template}'}
  rule  tmpl_name { \.? \w+}
}


class Plosurin {
    has $!type='perl5';
    has $!package='MyApp::Template';
    has $!parsed;
    method parse ( $txt) {
       my $res = Plosurin::Grammar.parse($txt, :actions(Plosurin::Actions.new ));
       $!parsed = $/;
       self;
    }
    multi method out_perl { self.out_perl( $!parsed.ast.values)}
    multi method out_perl ( @templates ) {
        my $output = "
# this is a generated code
# Plosurin  ver. $VERSION
package $!package;
use utf8;
";
    for @templates -> $tmpl {
        my $sub_name = $!package ~ '::' ~ ($tmpl.namespace ~ $tmpl.name).subst(rx/\./, '_', :g);
        my $res = Plosurin::Template.parse($tmpl.body,  :actions(Plosurin::TActions.new));
        my $body = "";
        for $/.ast.values -> $cnt {
            $body ~= $cnt.export_perl()
       }
        #escape \!
        $output ~=  "sub $sub_name \{
        return q!" ~ $body.subst(rx/\!/,'\!',:g) ~ "!;
    \}
";
   }
   $output ~= "\n 'Made by plosurin';";
   return $output;
  }
}


