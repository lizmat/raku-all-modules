use v6;

use nqp;
use NativeCall;

constant NOTMUCH_STATUS_SUCCESS = 0;
constant NOTMUCH_STATUS_OUT_OF_MEMORY = 1;
constant NOTMUCH_STATUS_READ_ONLY_DATABASE = 2;
constant NOTMUCH_STATUS_XAPIAN_EXCEPTION = 3;
constant NOTMUCH_STATUS_FILE_ERROR = 4;
constant NOTMUCH_STATUS_FILE_NOT_EMAIL = 5;
constant NOTMUCH_STATUS_DUPLICATE_MESSAGE_ID = 6;
constant NOTMUCH_STATUS_NULL_POINTER = 7;
constant NOTMUCH_STATUS_TAG_TOO_LONG = 8;
constant NOTMUCH_STATUS_UNBALANCED_FREEZE_THAW = 9;
constant NOTMUCH_STATUS_UNBALANCED_ATOMIC = 10;
constant NOTMUCH_STATUS_UNSUPPORTED_OPERATION = 11;
constant NOTMUCH_STATUS_UPGRADE_REQUIRED = 12;
constant NOTMUCH_STATUS_PATH_ERROR = 13;


class Tags is repr('CPointer') {
    sub notmuch_tags_valid(Tags)
        returns bool
        is native('notmuch', v4)
        {*};
    sub notmuch_tags_get(Tags)
        returns Str
        is native('notmuch', v4)
        {*};
    sub notmuch_tags_destroy(Tags)
        is native('notmuch', v4)
        {*};
    sub notmuch_tags_move_to_next(Tags)
        is native('notmuch', v4)
        {*};

    method all() {
        gather {
            while self.valid() {
                take self.get();
                self.move_to_next();
            }
        }
    }

    method free() {
        notmuch_tags_destroy(self)
    }

    method get() {
        return unless self.valid();
        notmuch_tags_get(self)
    }
    method move_to_next() {
        notmuch_tags_move_to_next(self)
    }
    method valid() {
        notmuch_tags_valid(self)
    }
}

class Message is repr('CPointer') {
    sub notmuch_message_destroy(Message)
        is native('notmuch', v4)
        {*};
    sub notmuch_message_get_filename(Message)
        returns Str
        is native('notmuch', v4)
        {*};
    sub notmuch_message_get_header(Message, Str $header)
        returns Str
        is native('notmuch', v4)
        {*};
    sub notmuch_message_get_tags(Message)
        returns Tags
        is native('notmuch', v4)
        {*};
    sub notmuch_message_add_tag(Message, Str $tag)
        returns Int
        is native('notmuch', v4)
        {*};
    sub notmuch_message_get_message_id(Message)
        returns Str
        is native('notmuch', v4)
        {*};
    sub notmuch_message_get_thread_id(Message)
        returns Str
        is native('notmuch', v4)
        {*};

    method free() {
        notmuch_message_destroy(self)
    }
    method get_filename() {
        notmuch_message_get_filename(self)
    }
    method get_header(Str $header) {
        notmuch_message_get_header(self, $header)
    }
    method get_tags() {
        notmuch_message_get_tags(self)
    }
    method add_tag(Str $tag) {
        notmuch_message_add_tag(self, $tag)
    }
    method get_message_id() {
        notmuch_message_get_message_id(self)
    }
    method get_thread_id() {
        notmuch_message_get_thread_id(self)
    }
}

class Thread is repr('CPointer') {
    sub notmuch_thread_destroy(Thread)
        is native('notmuch', v4)
        {*};
    sub notmuch_thread_get_tags(Thread)
        returns Tags
        is native('notmuch', v4)
        {*};
    sub notmuch_thread_get_messages(Thread)
        returns Tags
        is native('notmuch', v4)
        {*};
    sub notmuch_thread_get_thread_id(Thread)
        returns Str
        is native('notmuch', v4)
        {*};

    my @.subresources;

    method free() {
        for @.subresources -> $subresource {
            $subresource.free();
        }
        notmuch_thread_destroy(self)
    }
    method get_tags() {
        notmuch_thread_get_tags(self)
    }
    method get_thread_id() {
        notmuch_thread_get_thread_id(self)
    }
    method get_thread_get_messages() {
        my $messages = notmuch_thread_get_messages(self);
        @.subresources.append($messages);
    }

}

class Database is repr('CPointer') {
    sub notmuch_database_create_verbose(Str $path, CArray[long] $database, CArray[Str] $error_message)
        returns Int
        is native('notmuch', v4)
        {*};
    sub notmuch_database_open_verbose(Str $path, Int $mode, CArray[long] $database, CArray[Str] $error_message)
        returns Int
        is native('notmuch', v4)
        {*};
    sub notmuch_database_get_all_tags(Database)
        returns Tags
        is native('notmuch', v4)
        {*};
    sub notmuch_database_add_message(Database, Str $filename, CArray[long] $message)
        returns Int
        is native('notmuch', v4)
        {*};
    sub notmuch_database_find_message_by_filename(Database, Str $filename, CArray[long] $message)
        returns Int
        is native('notmuch', v4)
        {*};
    sub notmuch_database_get_version(Database)
        returns Int
        is native('notmuch', v4)
        {*};
    sub notmuch_database_close(Database)
        returns Int
        is native('notmuch', v4)
        {*};
    sub notmuch_database_destroy(Database)
        returns Int
        is native('notmuch', v4)
        {*};


    my @.subresources;

    method create(Str $path) {
        my $buf = CArray[long].new;
        my $err = CArray[Str].new;
        $buf[0] = 0;
        $err[0] = Str;
        notmuch_database_create_verbose($path, $buf, $err);
        $err[0].throw if $err[0];
        # TODO(Gonéri): I guess there is better way to do that ^^
        nqp::box_i(nqp::unbox_i(nqp::decont($buf[0])), Database)
    }

    method open(Str $path) {
        my $buf = CArray[long].new;
        my $err = CArray[Str].new;
        $buf[0] = 0;
        $err[0] = Str;
        notmuch_database_open_verbose($path, 0, $buf, $err);
        $err[0].throw if $err[0];
        # TODO(Gonéri): I guess there is better way to do that ^^
        nqp::box_i(nqp::unbox_i(nqp::decont($buf[0])), Database)
    }

    method add_message(Str $filename) {
        my $buf = CArray[long].new;
        $buf[0] = 0;
        notmuch_database_add_message(self, $filename, $buf);
        my $message = nqp::box_i(nqp::unbox_i(nqp::decont($buf[0])), Message);
        @.subresources.append($message);
        return $message;
    }

    method find_message_by_filename(Str $filename) {
        my $buf = CArray[long].new;
        $buf[0] = 0;
        notmuch_database_find_message_by_filename(self, $filename, $buf);
        my $message = nqp::box_i(nqp::unbox_i(nqp::decont($buf[0])), Message);
        @.subresources.append($message);
        return $message;
    }

    method get_version() {
        notmuch_database_get_version(self);
    }

    method close() {
        notmuch_database_close(self);
    }

    method free() {
        for @.subresources -> $subresource {
            $subresource.free();
        }
        notmuch_database_destroy(self);
    }
}

class Messages is repr('CPointer') {
    sub notmuch_messages_valid(Messages)
        returns bool
        is native('notmuch', v4)
        {*};
    sub notmuch_messages_get(Messages)
        returns Message
        is native('notmuch', v4)
        {*};
    sub notmuch_messages_destroy(Messages)
        is native('notmuch', v4)
        {*};
    sub notmuch_messages_move_to_next(Messages)
        is native('notmuch', v4)
        {*};

    my @.subresources;

    method all() {
        gather {
            while self.valid() {
                take self.get();
                self.move_to_next();
            }
        }
    }

    method free() {
        for @.subresources -> $subresource {
            $subresource.free();
        }
        notmuch_messages_destroy(self)
    }

    method get() {
        return unless self.valid();
        my $message = notmuch_messages_get(self);
        @.subresources.append($message);
        return $message;
    }
    method move_to_next() {
        notmuch_messages_move_to_next(self)
    }
    method valid() {
        notmuch_messages_valid(self)
    }
}

class Threads is repr('CPointer') {
    sub notmuch_threads_valid(Threads)
        returns bool
        is native('notmuch', v4)
        {*};
    sub notmuch_threads_get(Threads)
        returns Thread
        is native('notmuch', v4)
        {*};
    sub notmuch_threads_destroy(Threads)
        is native('notmuch', v4)
        {*};
    sub notmuch_threads_move_to_next(Threads)
        is native('notmuch', v4)
        {*};


    my @.subresources;

    method all() {
        gather {
            while self.valid() {
                take self.get();
                self.move_to_next();
            }
        }
    }

    method free() {
        for @.subresources -> $subresource {
            $subresource.free();
        }
        notmuch_threads_destroy(self)
    }

    method get() {
        return unless self.valid();
        my $thread = notmuch_threads_get(self);
        @.subresources.append($thread);
        return $thread;
    }
    method move_to_next() {
        notmuch_threads_move_to_next(self)
    }
    method valid() {
        notmuch_threads_valid(self)
    }
}

class Query is repr('CPointer') {
    sub notmuch_query_create(Database $database, Str $query_string)
        returns Query
        is native('notmuch', v4)
        {*};
    sub notmuch_query_destroy(Query)
        is native('notmuch', v4)
        {*};
    sub notmuch_query_search_messages(Query)
        returns Messages
        is native('notmuch', v4)
       {*};
    sub notmuch_query_search_threads(Query)
        returns Threads
        is native('notmuch', v4)
       {*};

    my @.subresources;

    method new(Database $database, Str $query_string) {
        my $query = notmuch_query_create($database, $query_string);
        $database.subresources.append($query);
        return $query;
    }

    method free() {
        for @.subresources -> $subresource {
            $subresource.free();
        }
        notmuch_query_destroy(self);
    }

    method search_messages() {
        my $messages = notmuch_query_search_messages(self);
        @.subresources.append($messages);
        return $messages;
    }
    method search_threads() {
        my $threads = notmuch_query_search_threads(self);
        @.subresources.append($threads);
        return $threads;
    }

}

