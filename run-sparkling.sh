#!/bin/bash
cd /opt
export SPARKLING_HOME="/opt/$(ls /opt | grep sparkling)"
echo "Running Sparkling Water ...."
$SPARKLING_HOME/bin/pysparkling --num-executors $SPARKLING_EXECUTORS --executor-memory $SPARKLING_EXECUTOR_MEMORY \
                                --executor-cores $SPARKLING_EXECUTOR_CORES --driver-memory $SPARKLING_DRIVER_MEMORY --master yarn-client
#java -Xmx$H2O_JVM_HEAP_SIZE -jar h2o.jar -ice_root /data -flow_dir /flows "$H2O_ARGS"
