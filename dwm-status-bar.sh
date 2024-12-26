#!/bin/bash

set -euo pipefail

function log() {
	logger -t dwm-status $@
}
log "Started"

function reload() {
	log "Reloading"
	exec "$0" "$@"
}
trap 'reload' SIGUSR1

function get_load() {
	local uptime_out
	# 13:33:45 up  1:20,  2 users,  load average: 0,01, 0,09, 0,09
	uptime_out="$(uptime)"
	# 0,04, 0,08, 0,08
	uptime_out="${uptime_out##*load average: }"
	# 0,04,
	uptime_out="${uptime_out%% *}"
	# 0,04
	echo "${uptime_out:0:-1}"
}

function get_public_ip() {
	local ipinfo
	if ! ipinfo="$(curl -sSL https://ipinfo.io | jq -r .ip)"; then
		echo "offline"
	fi

	echo "${ipinfo}"
}

slow_status_file="$(mktemp)"
echo "pub ip: offline" > "${slow_status_file}"
log "slow_status_file=${slow_status_file}"

{
	while true; do
		echo "pub ip: $(get_public_ip)" > "${slow_status_file}"
		sleep 10
	done
} &

while true; do
	bar="$(cat "${slow_status_file}") | load: $(get_load) | $(date '+%d.%m.%Y %T')"
	xsetroot -name "${bar}"

	sleep 0.2
done
