
if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    echo "usage: Command CONTAINER FILENAME TIME WARM WHICHLOAD"
    exit 1
fi

CONTAINER=$1
FILENAME=$2

TIME=$3
WARM=$4
WHICHLOAD=$5

HALFTIME=$((TIME/2))
echo "HALFTIME $HALFTIME"
#CONNECTIONS=12
WH=100

MYSQLCPU=4-7
BENCHMARKCPU=0-3
NUMANODE=0
OUTPUTFOLDER="/home/rasharma/work/arm/output_x86"
DISPLAYFILE=$OUTPUTFOLDER/display.txt
OUTPUTFILE=$OUTPUTFOLDER/output.txt
OUTPUTFILE2=$OUTPUTFOLDER/output2.txt
LOADFILE=$OUTPUTFOLDER/loads.txt
INSTRUCTIONSFILE=$OUTPUTFOLDER/instructions.txt
TRANSACTIONFILE=$OUTPUTFOLDER/transactions.txt
TEMPFILE1=$OUTPUTFOLDER/temp1.txt
TEMPFILE2=$OUTPUTFOLDER/temp2.txt
TEMPFILE3=$OUTPUTFOLDER/temp3.txt
DEBUGFILE=$OUTPUTFOLDER/debugfile.txt
IDLEINSTRUCTIONSFILE=$OUTPUTFOLDER/idleinstructions.txt
CPUUTILFILE=$OUTPUTFOLDER/cpuutilfile.txt
CPUUTILFILETEMP=$OUTPUTFOLDER/cpuutilfiletemp.txt
CPUUTILFILEPERM=$OUTPUTFOLDER/cpuutilfileperm.txt
CPUUTILACTUALFILE=$OUTPUTFOLDER/cpuutilactual.txt
rm $CPUUTILACTUALFILE
touch $CPUUTILACTUALFILE
rm $CPUUTILFILEPERM
touch $CPUUTILFILEPERM
rm $CPUUTILFILE
touch CPUUTILFILE
rm $OUTPUTFILE
touch $OUTPUTFILE
rm $OUTPUTFILE2
touch $OUTPUTFILE2
rm $DEBUGFILE
touch $DEBUGFILE
sudo pkill tpcc_start

while read LOAD; do
    mysql=`pidof mysqld`
    sudo taskset -cp $MYSQLCPU $mysql
    echo "mysqld process $mysql"
    sudo perf stat -p $mysql -e instructions:u sleep 5 2>>$DEBUGFILE
    rm $DISPLAYFILE && touch $DISPLAYFILE
    echo "LOAD = $LOAD"

    echo $temp
    echo "WARMING"

	docker exec -t $CONTAINER bash -c "taskset -c $BENCHMARKCPU /tpcc-mysql/tpcc_start -h127.0.0.1 -P3306 -dtpcc1000 -uroot -w$WH -c$LOAD -r$WARM -l1"
	sudo pkill -9 tpcc_start
	( (mpstat -N $NUMANODE $TIME 1> $CPUUTILFILETEMP)) &
	echo "-" >> $CPUUTILACTUALFILE
	( (top -b -n$TIME -d1 | grep "mysqld$" | awk '{print $9}')>>$CPUUTILACTUALFILE ) &
	( (sudo perf stat -p $mysql -e instructions:u docker exec -t $CONTAINER bash -c "taskset -c $BENCHMARKCPU /tpcc-mysql/tpcc_start -h127.0.0.1 -P3306 -dtpcc1000 -uroot -w$WH -c$LOAD -r0 -l$TIME -i$TIME") 1>$TEMPFILE3 2>$TEMPFILE1) && (echo "LOAD = $LOAD" > $TEMPFILE2)
	(awk 'NR==4' $CPUUTILFILETEMP | awk '{print $NF}') >> $CPUUTILFILE
	cat $CPUUTILFILETEMP >> $CPUUTILFILEPERM

    
    echo "perf done"
    cat $TEMPFILE1>>$OUTPUTFILE
    cat $TEMPFILE2>>$OUTPUTFILE
    cat $TEMPFILE3>>$OUTPUTFILE  
    ((awk '/LOAD/{print}' $TEMPFILE2 | awk '{print $3}') && (awk '/instructions/{print}' $TEMPFILE1 | awk '{print $1}') && (awk '/trx/{print}' $TEMPFILE3 | awk '{print substr($3, 1, length($3)-1)}') && (awk 'NR==4' $CPUUTILFILETEMP | awk '{print $3}')  ) | tr '\n' ' ' >> $OUTPUTFILE2
    echo "" >> $OUTPUTFILE2
#( (awk '/LOAD/{print}' $TEMPFILE2 | awk '{print $3}') && ('/instructions/{print}' $TEMPFILE1 | awk '{print $1}' )  | tr '\n' ' ' ) >> $OUTPUTFILE2 


    awk '/LOAD/{print}' $OUTPUTFILE | awk '{print $3}' > $LOADFILE && awk '/instructions/{print}' $OUTPUTFILE | awk '{print $1}' > $INSTRUCTIONSFILE && awk '/trx/{print}' $OUTPUTFILE | awk '{print substr($3, 1, length($3)-1)}' > $TRANSACTIONFILE && awk '/instructions/{print}' $DEBUGFILE | awk '{print $1}' > $IDLEINSTRUCTIONSFILE
    cat $OUTPUTFILE2
    sudo pkill -9 tpcc_start
    docker exec -t $CONTAINER bash -c "service mysql restart"
    docker exec -t $CONTAINER bash -c "mysql --execute \"set global max_connections = 10000;\""
    docker exec -t $CONTAINER bash -c "mysql --execute \"set global max_prepared_stmt_count = 1000000;\""
    sleep 5
    echo "LOAD = $LOAD" >> $DEBUGFILE

    

done < $FILENAME
