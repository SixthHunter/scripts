#!/bin/bash
# Restart conky regularly due to terrible memory leak with io ops
# `xscreensaver' may interfere with restarting conky properly
# use with SystemD timer
# v0.5.1  aug/2021  by mountaineerbr

export DISPLAY=":0.0"

#load user confs (conkies)
CONFS=(
	"$HOME/.config/conky/confs/aurora_ds_sensors.conf"
	"$HOME/.config/conky/confs/rss_long1.conf"
	"$HOME/.config/conky/confs/rss_short1.conf"
	"$HOME/.config/conky/confs/rss_short2.conf"
	"$HOME/.config/conky/confs/calendar.conf"
	"$HOME/.config/conky/confs/todo.conf"
	"$HOME/.config/conky/confs/aurora_allinone.conf"
)

#pid file
#echo $$ >/tmp/${0##*/}.pid

#kill conky
killall conky || echo 'killall: no conkies running' >&2

#check if `xscreensaver' has blanked the screen
if grep -Fqi 'screen blanked' <(xscreensaver-command -time)
then grep -q '^UNBLANK' <(xscreensaver-command -watch)
fi

#launch conkies
for c in "${CONFS[@]}"
do conky --daemonize --pause=2 -X "${DISPLAY}" -c "$c"
done
#-d daemonises conky
#-c configuration file
#-p time to pause before actually starting conky
#--display X11 display to use

