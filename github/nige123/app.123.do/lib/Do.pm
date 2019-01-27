
use Do::Timeline;

class Do {

    has $.file;
    has $.timeline handles 
        qw<
            add edit 
            estimate-tasks-per-day 
            find 
            get-entry 
            move 
            render 
            render-day 
            remove 
            show-graph
        >;

    submethod TWEAK {
        $!timeline = Do::Timeline.new(file => $!file);
        $!timeline.load;
    }
}


