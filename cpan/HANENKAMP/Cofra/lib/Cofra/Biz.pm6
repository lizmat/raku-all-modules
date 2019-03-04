use v6;

use Cofra::App::Godly;

unit role Cofra::Biz does Cofra::App::Godly;

=begin pod

=head1 NAME

Cofra::Biz - business logic should go in here somewhere

=head1 SYNOPSIS

    use Cofra::Biz;

    unit class MyApp::Biz::DoohickeyFactory does Cofra::Biz;

    method make-doohickies($stuff, $things) { ... }

=head1 DESCRIPTION

You know what annoys me about software frameworks? They have all this stuff to
help you do things like control things, view things, model things, make widgets,
manage documents, and all that. But where the heck is the thing that holds that
actual business logic? You know, the reason you need to control, view, model,
widget, document, and whatever.

So what inevitably happens? The same thing that will happen when you use this
framework. You and the other developers on the project stash the business logic
all over the dang place inside of parts of the application that have no business
holding your business logic. It will be in places that are hard to test, hard to
reuse, and generally the places that have no business holding business logic.

That will happen to code built on this framework too. The human condition, the
outcome of that original sin passed on from one generation to the next, is just
that inevitable.

The difference is that this framework provides you with literally no excuse.
Your business logic belongs in a Biz class. Now you can feel proper shame when
you put it somewhere else. This framework will secretly despise you for your
lack of self-control. That's just the way it rolls.

=end pod
