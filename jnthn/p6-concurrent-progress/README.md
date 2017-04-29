# Concurrent::Progress

It's fairly straightforward to wire up concurrent progress reporting in Perl
6: just create a `Supplier`, use it to emit progress reports, and have things
wishing to receive progress reports tap the `Supply`. That's exactly what this
module does on this inside; it just saves some boilerplate and helps get a
little more intent into the code. It is best suited to cases where "N out of
M"-style progress reports are desired, where N reaching M indicates completion.
However, it may be used in cases where there is no target also.

## Synopsis

In the operation that should report progress, take `Concurrent::Progress` as
a parameter (usually optional) and use it. If no instance is passed, then the
method calls will be made on the type object, and will silently do nothing.

    sub some-async-operation(Concurrent::Progress :$progress) {
        start {
            # Optionally set a target (get percentage completion calculation
            # for free).
            my @things-to-do = ...;
            $progress.set-target(@things-to-do.elems);

            # Can add 1 to the count of things completed.
            for @things-to-do {
                ...;
                $progress.increment();
            }

            # Or can add many.
            for @things-to-do.batch(5) -> @batch {
                ...;
                $progress.add(@batch.elems);
            }

            # Or can just set the value, if we're counting by ourselves.
            for @things-to-do.kv -> $idx, $obj {
                ...;
                $progress.set-value($idx + 1);
            }
        }
    }

Meanwhile, in the caller (note that `whenever` automatically calls `Supply` on
the `Concurrent::Progress` object):

    my $progress = Cocurrent::Progress.new;
    react {
        whenever $progress -> $status {
            say "$status.value() / $status.target() ($status.percent()%)";
        }

        whenever some-async-operation(:$progress) {
            say "Completed";
        }
    }

## Construction

A `Concurrent::Progress` instance will usually be constructed by the initiator
of an asynchronous operation. No options are required, but the following may
be provided:

* **auto-done** - automatically emits a `done` message on the `Supply` of
  progress reports when the current value reaches the target. This means a
  `whenever` will complete (which is why the `react` block in the synopsis
  example terminates). Defaults to `True`. Note this is only applicable if
  `set-target` is called.
* **min-interval** - the minimum time interval between progress updates. Can
  be provided as an `Real` (`Int`, `Rat`, `Duration`, etc.) If provided, then
  there will be at most one update per the specified time interval (so, passing
  1 means at most one update per second). If this option is not specified, then
  every progress report will be emitted.

## Methods for reporting progress

The following methods may be called to report progress:

* **set-target(Int $target)** - sets the target to be reached to indicate
  completion. In many cases, where the total amount of work is known up-front,
  then this will be called once. Calling it allows automatic computation of
  the percentage complete in progress reports; if it is not called, then the
  percentage complete will be undefined. It is allowed to call `set-target`
  multiple times if there is a "moving target", but if using `auto-done` then
  it is up to you to ensure the value never reaches the target prematurely.
* **set-value(Int $value)** - sets the current value included in progress
  reports, and triggers emitting a progress report if appropirate.
* **increment** - adds 1 to the current value. It is safe to make multiple
  concurrent calls to `increment` (making this highly convenient for divide
  and conquer style code).
* **add(Int $n)** - adds `$n` to the current value. As with `increment`,
  multiple concurrent calls are safe.

### Methods for receiving progress reports

Progress reports are delivered using a `Supply`. This is a *live* `Supply`, so
if it matters that you receive every progress report then be sure to tap it
prior to starting the work.

The `Supply` method is used to obtain the `Supply` of progress reports (which
means a `Concurrent::Progress` object may be used directly with `whenever`).
The `Supply` will `emit` instances of `Concurrent::Progress::Report`, which
has the following properties:

* **value** - the current value (which will typically correspond to items
  processed, bytes download/uploaded, etc.)
* **target** - if set, the target to which the `value` property is working
  (total items to process, total bytes to be downloaded/uploaded, etc.)
* **percet** - if `target` is defined, then `(100 * $.value / $.target).Int`;
  if not, then an `Int` type object.

Provided `auto-done` was not disabled at construction time, then a `done` will
be sent when `value` reaches `target`.

It is also possible to pass `auto-done` and `min-interval` to the `Supply`
method, in order to override them on a per-Supply basis. This may be useful if
you did not have control over the creation of the `Concurrent::Progress`
instance.

