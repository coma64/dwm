#!/bin/bash

set -euo pipefail

function log() {
	logger -t dwm-status $@
}

function reload() {
	log "Reloading"
	exec "$0" "$@"
}

trap 'reload' SIGUSR1

log "Started"

while true; do
	# 13:33:45 up  1:20,  2 users,  load average: 0,01, 0,09, 0,09
	uptime_out="$(uptime)"
	# 0,04, 0,08, 0,08
	uptime_out="${uptime_out##*load average: }"
	# 0,04,
	uptime_out="${uptime_out%% *}"
	# 0,04
	uptime_out="${uptime_out:0:-1}"

	bar="load: ${uptime_out} | $(date '+%d.%m.%Y %T')"
	xsetroot -name "${bar}"

	sleep 0.2
done
