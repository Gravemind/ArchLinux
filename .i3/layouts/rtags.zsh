#!/bin/zsh

HERE="$(cd "`dirname "$0"`"; pwd)"

WS="$1"
if [ -z "$WS" ]
then
	WS=6
fi

$HERE/urxvt.zsh $WS "rtags" 'cd ~/bin/rtags;'