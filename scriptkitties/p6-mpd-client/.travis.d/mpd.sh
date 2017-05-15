#! /usr/bin/env sh

readonly BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly MUSICDIR=/var/media/music

# install all required packages
apt-get install -y \
	mpc \
	mpd

# create the required directories
mkdir -p \
	/var/lib/mpd \
	${MUSICDIR}

# configure mpd
install "${BASEDIR}/mpd.conf" /etc/mpd.conf

# start the service
service mpd start

# TODO: add some free music
curl https://github.com/PostCocoon/P6-TagLibC/raw/master/t/test.mp3 > ${MUSICDIR}/test.mp3

# sync the music with the mpd library
mpc update --wait
