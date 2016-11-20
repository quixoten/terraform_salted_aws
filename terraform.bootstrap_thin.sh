#!/bin/sh -

minion_id="${1}"

cd /tmp/terraform
tar zxf thin.tgz
sudo salt-call --id="${minion_id}" state.highstate
