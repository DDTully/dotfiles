#!/bin/sh
if pgrep -f showmethekey-gtk >/dev/null; then
  pkill -f showmethekey-gtk
else
  uwsm app -- showmethekey-gtk -C -A
fi
