#!/bin/bash
if [ "$#" -ne 5 ]; then
    echo "Wrong use. Command RAMP_TIME(s) TIME(s) TIME_STEP(us) NO_CONNECTIONS WAREHOUSES"
    exit 1
fi
RAMP_TIME=$1
TIME=$2
TIME_STEP=$3
NO_CONNECTIONS=$4
NO_WAREHOUSES=$5
cp /tpcc-mysql/src/main.c /tpcc-mysql/temp_main.c 
cp /tpcc-mysql/main.c /tpcc-mysql/src/main.c

cd /tpcc-mysql/src
make
cd ..
./tpcc_start -h127.0.0.1 -P3306 -dtpcc1000 -uroot -w$NO_WAREHOUSES -c$NO_CONNECTIONS -r$RAMP_TIME -l$TIME -i$TIME_STEP

cp /tpcc-mysql/temp_main.c /tpcc-mysql/src/main.c
