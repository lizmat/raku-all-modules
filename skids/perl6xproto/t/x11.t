use v6;
use lib <blib/lib lib>;

use Test;

plan 6;

use X::Protocol::X11;
ok(1,'We use X::Protocol::X11 and we are still alive');
lives-ok { X::Protocol::X11.new(:status(5), :bad_value(0x28000004),
                                :major_opcode<ChangeProperty(18)>) }, "Can create an X::Protocol::X11";
is X::Protocol::X11.new(:sequence(0x1234), :status(5), :bad_value(0x28000004),
                        :major_opcode<ChangeProperty(18)>).message, "X11 protocol error: Bad Atom for request #0x1234 (Opcode ChangeProperty(18)) Atom(0x28000004)", "Simple one-shot has correct message";
is X::Protocol::X11.new(:sequence(0x1234), :status(5), :bad_value(0x28000004),
                        :major_opcode<ChangeProperty(18)>).gist, "Bad Atom Atom(0x28000004)", "Simple one-shot has correct gist";
is X::Protocol::X11.new(:sequence(0x1234), :status(8),
                        :major_opcode<ChangeProperty(18)>).message, "X11 protocol error: No match for request #0x1234 (Opcode ChangeProperty(18))", "Valueless one-shot has correct message";
is X::Protocol::X11.new(:sequence(0x1234), :status(8),
                        :major_opcode<ChangeProperty(18)>).gist, "No match", "Valueless one-shot has correct gist";

