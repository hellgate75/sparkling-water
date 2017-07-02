#!/bin/bash

: ${HADOOP_HOME:=/usr/local/hadoop}

$HADOOP_HOME/etc/hadoop/hadoop-env.sh

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_HOME/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

if [[ -e /etc/config/spark/init-spark-env.sh ]]; then
  source /etc/config/spark/init-spark-env.sh
fi


service ssh start

mkdir -p $HADOOP_HOME/logs

SPARK_RUNNING="$(ps -eaf|grep java| grep spark)"
HADOOP_RUNNING="$(ps -eaf|grep java| grep hadoop)"

if [[ "true" == "$SPARK_START_HADOOP" ]]; then
  if [[ -z "$SPARK_RUNNING" ]] || [[ "true" == "$SPARK_FORCE_HADOOP_RESTART" ]]; then
    if [[ "true" == "$SPARK_FORCE_HADOOP_RESTART" ]]; then
      $HADOOP_HOME/sbin/stop-all.sh
    fi
    if [[ "true" == "$SPARK_START_HADOOP_ALL_SERVICES" ]]; then
      $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
      $HADOOP_HOME/bin/hdfs namenode -format -force -nonInteractive && \
      $HADOOP_HOME/sbin/start-all.sh
    else
      $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
      $HADOOP_HOME/bin/hdfs namenode -format -force -nonInteractive
      if [[ "true" == "$SPARK_START_HADOOP_HDFS" ]]; then
        echo "Starting Apache™ Hadoop® HDFS™ service ..."
        $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
        $HADOOP_HOME/sbin/hdfs-config.sh && \
        $HADOOP_HOME/sbin/dfs.sh
      fi
      if [[ "true" == "$SPARK_START_HADOOP_YARN" ]]; then
        echo "Starting Apache™ Hadoop® YARN™ service ..."
        $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
        $HADOOP_HOME/sbin/start-yarn.sh
        if [[ "true" == "$SPARK_START_HADOOP_YARN_DEAMONS" ]]; then
          if ! [[ -z "$SPARK_HADOOP_YARN_DEAMON_COMMAND" ]]; then
            $HADOOP_HOME/sbin/yarn-daemons.sh start $SPARK_HADOOP_YARN_DEAMON_COMMAND
          fi
        fi
        if [[ "true" == "$SPARK_START_HADOOP_YARN_DEAMON" ]]; then
          if ! [[ -z "$SPARK_HADOOP_YARN_DEAMON_COMMAND" ]]; then
            $HADOOP_HOME/sbin/yarn-daemon.sh start $SPARK_HADOOP_YARN_DEAMON_COMMAND
          fi
        fi
      fi
      if [[ "true" == "$SPARK_START_HADOOP_JOB_HISTORY" ]]; then
        echo "Starting Apache™ Hadoop® Mr Job History service ..."
      $HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start $SPARK_HADOOP_JOB_HISTORY_MAPRED_COMMAND
      fi
      if [[ "true" == "$SPARK_START_HADOOP_BALANCER" ]]; then
        echo "Starting Apache™ Hadoop® Balancer service ..."
        $HADOOP_HOME/sbin/start-balancer.sh
      fi
      if [[ "true" == "$SPARK_START_HADOOP_KMS_SERVER" ]]; then
        echo "Starting Apache™ Hadoop® KMS™ service ..."
        $HADOOP_HOME/sbin/kms.sh start
      fi
    fi
    if [[ "true" == "$SPARK_START_HADOOP_DEAMONS" ]]; then
      if ! [[ -z "$SPARK_HADOOP_DEAMON_COMMAND" ]]; then
        $HADOOP_HOME/sbin/hadoop-daemons.sh start $SPARK_HADOOP_DEAMON_COMMAND
      fi
    fi
    if [[ "true" == "$SPARK_START_HADOOP_DEAMON" ]]; then
      if ! [[ -z "$SPARK_HADOOP_DEAMON_COMMAND" ]]; then
        $HADOOP_HOME/sbin/hadoop-daemon.sh start $SPARK_HADOOP_DEAMON_COMMAND
      fi
    fi
  else
    echo "Apache™ Hadoop® is running, yet!!"
  fi
else
  echo "Apache™ Hadoop® is deactivate, not start action provided!!"
fi

if [[ -e /root/application/bootstrap.sh ]]; then
  if ! [[ -e /root/application/.spark_built ]]; then
    echo "Apache™ Spark® Application Bootstrap script execution ..."
    chmod 777 /root/application/bootstrap.sh
    /root/application/bootstrap.sh
    touch /root/application/.spark_built
  fi
fi

if [[ -z "$SPARK_RUNNING" ]] || [[ "true" == "$SPARK_FORCE_RESTART" ]]; then
  if [[ "true" == "$SPARK_FORCE_RESTART" ]]; then
    $SPARK_HOME/sbin/stop-all.sh
  fi
  echo "Apache™ Spark® services starting ..."
  echo "Apache™ Spark® starting ..."
  if [[ "true" == "$SPARK_START_INTEGRATE_WITH_YARN" ]]; then
    echo "Apache™ Spark® YARN integration running ..."
    EXTRA_JARS=""
    if [[ -e /etc/config/spark/libs ]]; then
      EXTRA_JARS="$(ls /etc/config/spark/libs/ | grep -v 'spark-bootstrap.jar' | awk '{FS=OFS="\n"}{print "-jar "$1}'| xargs echo )"
    fi
    if ! [[ -e /etc/config/spark/libs/spark-bootstrap.jar ]]; then
      echo "Apache™ Spark® with Apache™ Hadoop® YARN integration : couldn't find package : /etc/config/spark/libs/spark-bootstrap.jar !!"
      exit 1
    fi
    if ! [[ -z "$EXTRA_JARS" ]]; then
      $SPARK_HOME/bin/spark-submit --class "$SPARK_START_YARN_CLASSNAME" \
      --master yarn \
      --deploy-mode cluster \
      --driver-memory "$SPARK_CONFIG_DRIVER_MEMORY" \
      --executor-memory "$SPARK_START_SLAVE_MEMORY" \
      --executor-cores "$SPARK_START_SLAVE_CORES" \
      --queue "$SPARK_START_YARN_QUEUE_NAME" \
      $EXTRA_JARS \
      /etc/config/spark/libs/spark-bootstrap.jar
      $SPARK_START_YARN_ARGUMENTS
    else
      $SPARK_HOME/bin/spark-submit --class "$SPARK_START_YARN_CLASSNAME" \
      --master yarn \
      --deploy-mode cluster \
      --driver-memory "$SPARK_CONFIG_DRIVER_MEMORY" \
      --executor-memory "$SPARK_START_SLAVE_MEMORY" \
      --executor-cores "$SPARK_START_SLAVE_CORES" \
      --queue "$SPARK_START_YARN_QUEUE_NAME" \
      /etc/config/spark/libs/spark-bootstrap.jar \
      $SPARK_START_YARN_ARGUMENTS
    fi
    echo "Apache™ Spark® started with Apache™ Hadoop® YARN integration !!"
  else
    if [[ "true" == "$SPARK_START_MASTER_NODE" ]]; then
      echo "Apache™ Spark® starting in MASTER mode..."
      $SPARK_HOME/sbin/spark-config.sh && $SPARK_HOME/sbin/start-master.sh
    else
      echo "Apache™ Spark® starting in SLAVE mode..."
      $SPARK_HOME/sbin/spark-config.sh && $SPARK_HOME/sbin/start-slaves.sh
    fi
  fi
  if [[ "true" == "$SPARK_START_ALL_SERVICES" ]]; then
    echo "Starting Apache™ Spark® All services ..."
    $SPARK_HOME/sbin/spark-config.sh && $SPARK_HOME/sbin/start-all.sh
  else
    if [[ "true" == "$SPARK_START_HISTORY_SERVER" ]]; then
      echo "Starting Apache™ Spark® History Service ..."
      $SPARK_HOME/sbin/spark-config.sh && $SPARK_HOME/sbin/start-history-server.sh
    fi
    if [[ "true" == "$SPARK_START_SHUFFLE_SERVICE" ]]; then
      echo "Starting Apache™ Spark® Shuffle Service ..."
      $SPARK_HOME/sbin/spark-config.sh && $SPARK_HOME/sbin/start-shuffle-service.sh
    fi
    if [[ "true" == "$SPARK_START_THRIFT_SERVER" ]]; then
      echo "Starting Apache™ Spark® Thrift Server ..."
      $SPARK_HOME/sbin/spark-config.sh && $SPARK_HOME/sbin/start-thriftserver.sh
    fi
    if [[ "true" == "$SPARK_START_MESOS_INTEGRATION" ]]; then
      echo "Starting Apache™ Spark® MESOS® Services ..."
      $SPARK_HOME/sbin/spark-config.sh && $SPARK_HOME/sbin/start-mesos-dispatcher.sh
      $SPARK_HOME/sbin/spark-config.sh && $SPARK_HOME/sbin/start-mesos-shuffle-service.sh
    fi
  fi
  if [[ "true" == "$SPARK_START_DEAMONS" ]]; then
    if ! [[ -z "$SPARK_DAEMON_COMMAND" ]]; then
      $HADOOP_HOME/sbin/hadoop-daemons.sh start $SPARK_DAEMON_COMMAND
    fi
  fi
  if [[ "true" == "$SPARK_START_DEAMON" ]]; then
    if ! [[ -z "$SPARK_DAEMON_COMMAND" ]]; then
      $HADOOP_HOME/sbin/hadoop-daemon.sh start $SPARK_DAEMON_COMMAND
    fi
  fi
  if [[ "true" != "$SPARK_START_ALL_SLAVES" ]]; then
    echo "Starting Apache™ Spark® Slaves ..."
    $SPARK_HOME/sbin/spark-config.sh && $SPARK_HOME/sbin/start-slaves.sh
  fi
  nohup run-sparkling &
else
  echo "Apache™ Spark® is running, yet!!"
fi


echo "Waiting for product start-up ...."
sleep 30
netstat aux
echo ""
echo "Sparling Water logs :"

if [[ $1 == "-d" ]]; then
  tail -f $SPARK_HOME/nohup.out
  tail -f /dev/null
fi

if [[ $1 == "-bash" ]]; then
  cat $SPARK_HOME/nohup.out
  /bin/bash
fi
