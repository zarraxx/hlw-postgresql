#!/bin/bash

set -e

loginctl enable-linger $(whoami)

mkdir -p ~/.config/systemd/user/

cp postgresql.service ~/.config/systemd/user/postgresql.service

systemctl --user daemon-reload

systemctl --user enable postgresql.service

systemctl --user start postgresql.service


systemctl --user status postgresql.service

