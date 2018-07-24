# database_tests_simflex
## Part 1
Build the docker images for ARM as:
```
docker build -t tpcc .
```
For x86
```
docker build -t tpcc -f Dockerfile_x86
```

To start the container: 

```
docker run --name=tpcc -it --ulimit nofile=90000:90000 tpcc [N_Warehouses] [StepSize]

```
The above will run the container and start loading N_Warehouses tpcc warehouses in parallel with a step size of StepSize. 

The script mysql.sh can be used to CPU Utilization, transactions, and No. of User Instructions as a function of the no. of connections.

Run it as 

```
./mysql.sh CONTAINER FILENAME MEASUREMENT_TIME WARMUPTIME NO_WAREHOUSES
```
The filename should contain the list of loads for which the benchmark has to be run. 

The environment variables:

MYSQLCPU                                                                                                                                                                                                     
BENCHMARKCPU                                                                                                                                                                                                                                                                                                                                                                                        
OUTPUTFOLDER

are provided as an example and will require changes as per the requirement. 

The Jupyter notebook plots.py can be used to make the necessary plots. 

## Part 2

In order to get the graph of coefficient of variation as a function of sampling time, we log the number of transactions done as a function of time. We changed the code of the benchmark in order to be able to do the loggin at milisecond precision instead of seconds. 
To run this part, 

```
docker exec -it tpcc /tpcc-mysql/variation.sh RAMP_TIME(s) TIME(s) TIME_STEP(us) NO_CONNECTIONS WAREHOUSES > variation_output.txt
awk '/trx/{print}' variation_output.txt | awk '{print $1}' > parsed_time.txt
awk '/trx/{print}' variation_output.txt | awk '{print $3}' > parsed_trx.txt
```
The above text files can be used to plot the graphs (see variation.ipynb notebook).
