#!/bin/bash

# Script to update the website

# set environment
. /opt/calmeq-mypi/env.sh

# set variables
PYDIR=/opt/calmeq-mypi/python
MAC=$( cat /sys/class/net/eth0/address )
DELAY=60

#SITE=http://calmeq-devices-alpharigel.c9.io/pies
SITE=http://calmeq-devices.herokuapp.com/pies

#IDFILE=/etc/calmeq-device-id
#if [ -f $IDFILE ]; then
#    ID=$( cat $IDFILE )
#else
#    echo "No ID File found at $IDFILE"
#    ID=""
#fi

amixer -D hw:1 sset Mic Capture Volume 40


while true; do 

    if [ -z $ID ]; then
        # Get a device id from server. POST on pies
        DEVICE_JSON=$(curl -X  POST $SITE \
            -d '{"py": {"lat":"", "identifier":"'$MAC'", "devicetime":"'$NOW'", "notes":"Hello from Pi"}}' \
            -H "Accept: application/json" -H "Content-Type: application/json" )

        # TODO: what about offline operation?  Check to see if ID is required for that.
        ID=$(echo $DEVICE_JSON | jq '.id')
    fi

    LAT=$( tail -n 30 ~/gpstrack.xml  | grep '<trkpt' | tail -n 1 | sed 's:.*lat="\([-0-9.]*\)".*:\1:g' )
    LON=$( tail -n 30 ~/gpstrack.xml  | grep '<trkpt' | tail -n 1 | sed 's:.*lon="\([-0-9.]*\)".*:\1:g' )
    NOW=$( date )
    DBLVL=$( arecord -d 1 -D hw:1 -f S16_LE -r 44100 -t raw | python $PYDIR/rawaudio2rms.py )

    READING_JSON=$(curl -X  POST $SITE/$ID/readings \
        -d '{"reading": {"lat":"'$LAT'", "identifier":"'$MAC'", "lon":"'$LON'", "dblvl":"'$DBLVL'", "devicetime":"'$NOW'" }}' \
        -H "Accept: application/json" -H "Content-Type: application/json")

    # TODO: check errors
    sleep $DELAY
done
