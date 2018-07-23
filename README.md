# database_tests_simflex

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
