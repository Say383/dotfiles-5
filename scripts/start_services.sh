#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
. "$DIR/base.sh"
. "$DIR/ansi"
. "$DIR/minimalcheck.sh"

if [[ "$OSTYPE" == "darwin"* ]]; then
	SYNCMAIL_PLIST="$HOME/Library/LaunchAgents/com.syncmail.plist"
	if [ -f "$SYNCMAIL_PLIST" ]; then
		ansi --green "Loading syncmail.plist..."
		(launchctl list | grep --silent syncmail) && launchctl unload "$SYNCMAIL_PLIST"
		launchctl load -w "$SYNCMAIL_PLIST"
	else
		ansi --yellow "Skipping launchctl of syncmail.plist"
	fi

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
	# ask sudo upfront
	sudo -v

	sudo systemctl enable pcscd

	ansi --green "Setting up UFW service"
	sudo systemctl enable ufw.service
	sudo systemctl restart ufw.service
	sudo ufw enable

	mkdir -p "$HOME/.config/systemd/user/"

	if [ -f "$HOME/.config/systemd/user/mbsync.service" ]; then
		systemctl --user enable mbsync.service
		systemctl --user enable mbsync.timer
	fi

	if [ -f "$HOME/.config/systemd/user/mopidy.service" ]; then
		systemctl --user enable mopidy.service
		systemctl --user start mopidy.service
	fi

fi
