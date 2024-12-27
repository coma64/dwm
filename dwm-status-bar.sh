#!/bin/bash

set -euo pipefail

function log() {
	echo $@ >&2
}
log "Starting"

function reload() {
	log "Reloading"
	exec "$0" "$@"
}
trap 'reload' SIGUSR1

function get_load() {
	local uptime_out
	# 0.02 0.06 0.03 1/1330 2260596
	uptime_out="$(</proc/loadavg)"
	echo "${uptime_out%% *}"
}

function get_ram() {
	local free_out total used
	free_out="$(free -h | grep -F 'Mem:')"
	total="$(awk '{ print $2 }' <<< "${free_out}")"
	used="$(awk '{ print $3 }' <<< "${free_out}")"
	echo "${used} / ${total}"
}

function get_public_ip() {
	local ip
	if ip="$(dig whoami.cloudflare @1.1.1.1 chaos txt +short)"; then
		echo "${ip:1:-1}"
	else
		echo "offline"
	fi
}

slow_status_file="$(mktemp)"
log "slow_status_file=${slow_status_file}"
echo "pub ip: ..." > "${slow_status_file}"

{
	while true; do
		echo "pub ip: $(get_public_ip)" > "${slow_status_file}"
		sleep 10s
	done
} &

while true; do
	bar="$(cat "${slow_status_file}") | load: $(get_load) | ram: $(get_ram) | $(date '+%d.%m.%Y %T')"
	xsetroot -name "${bar}"

	sleep 1s
done
