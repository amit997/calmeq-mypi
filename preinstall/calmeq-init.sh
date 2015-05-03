#!/bin/bash

# this script needs to be preinstalled on noobs

# keep this short, and instead put much of the logic in the mypi github:

# pull mypi repo

MYDIR=/opt/calmeq-mypi

if [ ! -d $MYDIR ]; then
    git clone https://github.com/CalmEQ/calmeq-mypi.git $MYDIR
else
    git -C $MYDIR pull
fi

# run first time
. $MYDIR/firsttime.sh 