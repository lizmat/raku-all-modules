
use Do::Timeline;

class Do {

    has $.file;
    has $.timeline handles qw<add edit find get-entry move render render-day remove>;

    submethod TWEAK {
        $!timeline = Do::Timeline.new(file => $!file);
        $!timeline.load;
    }
}


