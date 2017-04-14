#!/bin/bash

# some delays in getting wifi running without gui
# just need to push the interface up a few times until it connects

# is it running?

L=`ifplugstatus | grep "wlan0: unplugged" | wc -l`


if [[ "$L" = "1" ]] ; then
    # no
    sudo ifup wlan0
fi
