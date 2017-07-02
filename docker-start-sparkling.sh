#!/bin/bash

if [[ -z "$1"  ]]; then
  echo "Apache™ Spark® Wrong command ..."
  echo "docker-start-spark [mode]"
  echo "-daemon Start with infinite listener"
  echo "-interactive Start with bash shell"
  exit 1
fi


export CONFIGURED_SPARK_BY_URL_EXIT_CODE=1

if ! [[ -z "$SPARK_CONFIG_TGZ_URL"  ]]; then
  if ! [[ -e /root/hadoop_configured ]]; then
    mkdir -p /root/uploaded/config/spark
    echo "Download Spark configuration files from : $SPARK_CONFIG_TGZ_URL  ..."
    curl -s $SPARK_CONFIG_TGZ_URL | tar -xz -C /root/uploaded/config/hadoop/
    export CONFIGURED_SPARK_BY_URL_EXIT_CODE="$?"
    if [[ "0" == "$CONFIGURED_SPARK_BY_URL_EXIT_CODE" ]]; then
      cp -f /root/uploaded/config/spark/* /etc/config/spark/
      cp -f /etc/config/spark/* /usr/local/spark/conf/
      echo "Apache™ Spark® configured by URL files at : $SPARK_CONFIG_TGZ_URL !!"
      touch /root/spark_configured
    else
      echo "Apache™ Spark® $HAHOOP_VERSION problems downaloading and extracting files from URL : $SPARK_CONFIG_TGZ_URL !!"
    fi
  else
    echo "Apache™ Spark® $HAHOOP_VERSION already configured!!"
  fi
else
  if [[ -e /etc/config/spark ]]; then
    if ! [[ -z "$(ls -latr /etc/config/spark/*)" ]]; then
      cp -f /etc/config/spark/* /usr/local/spark/conf/
      touch /root/spark_configured
      echo "Apache™ Hadoop® configured by volume : /etc/config/spark/ !!"
      export CONFIGURED_SPARK_BY_URL_EXIT_CODE=0
    fi
  fi

fi

if [[ -e /etc/config/spark/init-spark-env.sh ]]; then
  echo "Boostrap environment variable into the system from file : /etc/config/spark/init-spark-env.sh !!"
  chmod +x /etc/config/spark/init-spark-env.sh
  source /etc/config/spark/init-spark-env.sh
fi

export CONFIGURED_BY_URL_EXIT_CODE=1

if ! [[ -z "$SPARK_HADOOP_TGZ_URL"  ]]; then
  if ! [[ -e /root/hadoop_configured ]]; then
    mkdir -p /root/uploaded/config/hadoop
    echo "Download Hadoop configuration files from : $SPARK_HADOOP_TGZ_URL  ..."
    curl -s $SPARK_HADOOP_TGZ_URL | tar -xz -C /root/uploaded/config/hadoop/
    export CONFIGURED_BY_URL_EXIT_CODE="$?"
    if [[ "0" == "$CONFIGURED_BY_URL_EXIT_CODE" ]]; then
      cp -f /root/uploaded/config/hadoop/* /etc/config/hadoop/

      cp -Rf $HADOOP_HOME/etc/hadoop /usr/local/spark/etc

      if [[ "true" == "$SPARK_START_HADOOP" ]]; then
        service ssh start
        $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
        $HADOOP_HOME/bin/hdfs namenode -format -force -nonInteractive && \
        $HADOOP_HOME/sbin/start-dfs.sh && \
        $HADOOP_HOME/bin/hdfs dfs -mkdir /user && \
        $HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/root && \
        $HADOOP_HOME/sbin/stop-dfs.sh
        service ssh stop

        service ssh start
        $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
        $HADOOP_HOME/sbin/start-dfs.sh && \
        $HADOOP_HOME/bin/hdfs dfs -mkdir input && \
        $HADOOP_HOME/bin/hdfs dfs -put $HADOOP_HOME/etc/hadoop/ input && \
        $HADOOP_HOME/sbin/stop-dfs.sh
        service ssh stop
        touch /root/hadoop_configured
        echo "Apache™ Hadoop® configured by URL files at : $SPARK_HADOOP_TGZ_URL !!"
      else
        echo "Apache™ Hadoop® is deactivate, not configuration action provided!!"
      fi
    else
      echo "Apache™ Hadoop® $HAHOOP_VERSION problems downaloading and extracting files from URL : $SPARK_HADOOP_TGZ_URL !!"
    fi
  else
    echo "Apache™ Hadoop® $HAHOOP_VERSION already configured!!"
  fi
else
  if [[ -e /etc/config/hadoop ]]; then

      if ! [[ -z "$(ls -latr /etc/config/hadoop/*)" ]]; then
        cp -Rf $HADOOP_HOME/etc/hadoop /usr/local/spark/etc

        if [[ "true" == "$SPARK_START_HADOOP" ]]; then
          service ssh start
          $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
          $HADOOP_HOME/bin/hdfs namenode -format -force -nonInteractive && \
          $HADOOP_HOME/sbin/start-dfs.sh && \
          $HADOOP_HOME/bin/hdfs dfs -mkdir /user && \
          $HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/root && \
          $HADOOP_HOME/sbin/stop-dfs.sh
          service ssh stop

          service ssh start
          $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
          $HADOOP_HOME/sbin/start-dfs.sh && \
          $HADOOP_HOME/bin/hdfs dfs -mkdir input && \
          $HADOOP_HOME/bin/hdfs dfs -put $HADOOP_HOME/etc/hadoop/ input && \
          $HADOOP_HOME/sbin/stop-dfs.sh
          service ssh stop
          touch /root/hadoop_configured
          echo "Apache™ Hadoop® configured by volume : /etc/config/hadoop/ !!"
          export CONFIGURED_BY_URL_EXIT_CODE=0
        else
          echo "Apache™ Hadoop® is deactivate, not configuration action provided!!"
        fi
      fi

  fi
fi

if [[ -e /usr/share/zoneinfo/$MACHINE_TIMEZONE ]]; then
  ln -fs /usr/share/zoneinfo/$MACHINE_TIMEZONE /etc/localtime
  echo "Current Timezone: $(cat /etc/timezone)"
  dpkg-reconfigure tzdata
fi

echo "Checking files in /etc/config/hadoop folder ..."
if [[ "" != "$(ls /etc/config/hadoop/)" ]]; then
  echo "Copy new configuration files from folder /etc/config/hadoop ..."
  cp /etc/config/hadoop/* /etc/hadoop/
fi

echo "Configuring Apache™ Hadoop® $HAHOOP_VERSION ..."
if [[ $APACHE_HADOOP_SITE_HOSTNAME == "localhost" ]]; then
  export APACHE_HADOOP_SITE_HOSTNAME="$(hostname)"
  echo "Changed Host name :  $APACHE_HADOOP_SITE_HOSTNAME"
fi
if [[ $APACHE_HADOOP_YARN_RESOURCE_MANAGER_HOSTNAME == "localhost" ]]; then
  export APACHE_HADOOP_YARN_RESOURCE_MANAGER_HOSTNAME="$(hostname)"
  echo "Changed Resource Manager Host name :  $APACHE_HADOOP_YARN_RESOURCE_MANAGER_HOSTNAME"
fi

if [[ "yes" != "$APACHE_HADOOP_IS_CLUSTER" ]]; then
  sed s/HOSTNAME/$APACHE_HADOOP_SITE_HOSTNAME/ $HADOOP_HOME/etc/hadoop/singlenode/core-site.xml.template | sed s/BUFFERSIZE/$APACHE_HADOOP_SITE_BUFFER_SIZE/ > $HADOOP_HOME/etc/hadoop/core-site.xml
else
  sed s/HOSTNAME/$APACHE_HADOOP_SITE_HOSTNAME/ $HADOOP_HOME/etc/hadoop/clusternode/core-site.xml.template | sed s/BUFFERSIZE/$APACHE_HADOOP_SITE_BUFFER_SIZE/ > $HADOOP_HOME/etc/hadoop/core-site.xml
fi
if [[ "0" != "$CONFIGURED_BY_URL_EXIT_CODE" ]]; then
  if ! [[ -e /root/hadoop_configured ]]; then
    echo "Configuring Apache™ Hadoop® $HAHOOP_VERSION ..."
    echo "Host name :  $APACHE_HADOOP_SITE_HOSTNAME"
    echo "Resource Manager Host name :  $APACHE_HADOOP_YARN_RESOURCE_MANAGER_HOSTNAME"
    mkdir -p /user/$HADOOP_USER/data/hadoop/hdfs/namenode
    mkdir -p /user/$HADOOP_USER/data/hadoop/hdfs/checkpoint
    mkdir -p /user/$HADOOP_USER/data/hadoop/hdfs/datanode
    echo -e "export HADOOP_CONF_DIR=$HADOOP_CONF_DIR\nexport YARN_CONF_DIR=$YARN_CONF_DIR\nexport HADOOP_USER=$HADOOP_USER\nexport HDFS_NAMENODE_USER=$HADOOP_USER\nexport HDFS_DATANODE_USER=$HADOOP_USER\nexport YARN_RESOURCEMANAGER_USER=$HADOOP_USER\nexport YARN_NODEMANAGER_USER=$HADOOP_USER\nexport HDFS_SECONDARYNAMENODE_USER=$HADOOP_USER" >> /root/.bashrc
    echo -e "export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin" >> /root/.bashrc
    source /root/.bashrc

    if [[ "yes" != "$APACHE_HADOOP_IS_CLUSTER" ]]; then
      echo "Configuring Apache™ Hadoop® $HAHOOP_VERSION Single Node ..."
      if [[ "" == "$(cat $HADOOP_HOME/etc/hadoop/core-site.xml)" ]]; then
        touch $HADOOP_HOME/etc/hadoop/core-site.xml
        echo -e "Hadoop Configuration: \nMASTER_HOSTNAME: $APACHE_HADOOP_SITE_HOSTNAME\nBUFFER_SIZE: $APACHE_HADOOP_SITE_BUFFER_SIZE\n"
        sed s/HOSTNAME/$APACHE_HADOOP_SITE_HOSTNAME/ $HADOOP_HOME/etc/hadoop/singlenode/core-site.xml.template | sed s/BUFFERSIZE/$APACHE_HADOOP_SITE_BUFFER_SIZE/  > $HADOOP_HOME/etc/hadoop/core-site.xml
      fi
      if [[ "" == "$(cat $HADOOP_HOME/etc/hadoop/hdfs-site.xml)" ]]; then
        touch $HADOOP_HOME/etc/hadoop/hdfs-site.xml
        echo -e "HDFS Configuration: \nREPLICATION: $APACHE_HADOOP_HDFS_REPLICATION\nHADOOP_USER: $HADOOP_USER\n"
        sed s/USERNAME/$HADOOP_USER/ $HADOOP_HOME/etc/hadoop/singlenode/hdfs-site.xml.template > $HADOOP_HOME/etc/hadoop/hdfs-site.xml
      fi
      if [[ "" == "$(cat $HADOOP_HOME/etc/hadoop/yarn-site.xml)" ]]; then
        touch $HADOOP_HOME/etc/hadoop/yarn-site.xml
        echo -e "YARN Configuration: \nRESOURCE_MANAGER: $APACHE_HADOOP_YARN_RESOURCE_MANAGER_HOSTNAME\n"
        sed s/RM_HOSTNAME/$APACHE_HADOOP_YARN_RESOURCE_MANAGER_HOSTNAME/ $HADOOP_HOME/etc/hadoop/singlenode/yarn-site.xml.template > $HADOOP_HOME/etc/hadoop/yarn-site.xml
      fi
      if [[ "" == "$(cat $HADOOP_HOME/etc/hadoop/mapred-site.xml)" ]]; then
        touch $HADOOP_HOME/etc/hadoop/mapred-site.xml
        echo -e "Map Reduce Configuration: default\n"
        cp $HADOOP_HOME/etc/hadoop/singlenode/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
      fi
    else
      if [[ "no" != "$APACHE_HADOOP_IS_CLUSTER" ]]; then
        echo "Invalid cluster flag preference : $APACHE_HADOOP_IS_CLUSTER\nExpected: (yes/no) found : $APACHE_HADOOP_IS_CLUSTER"
        exit 1
      fi
      echo "Configuring Apache™ Hadoop® $HAHOOP_VERSION Cluster Node ..."
      if [[ "$APACHE_HADOOP_IS_MASTER" == "yes" ]]; then
        echo "Master Cluster Node"
      else
        echo "Slave Cluster Node"
      fi
      if [[ "" == "$(cat $HADOOP_HOME/etc/hadoop/core-site.xml)" ]]; then
        touch $HADOOP_HOME/etc/hadoop/core-site.xml
        echo -e "Hadoop Configuration: \nMASTER_HOSTNAME: $APACHE_HADOOP_SITE_HOSTNAME\nBUFFER_SIZE: $APACHE_HADOOP_SITE_BUFFER_SIZE\n"
        sed s/HOSTNAME/$APACHE_HADOOP_SITE_HOSTNAME/ $HADOOP_HOME/etc/hadoop/clusternode/core-site.xml.template | sed s/BUFFERSIZE/$APACHE_HADOOP_SITE_BUFFER_SIZE/  > $HADOOP_HOME/etc/hadoop/core-site.xml
      fi
      if [[ "" == "$(cat $HADOOP_HOME/etc/hadoop/hdfs-site.xml)" ]]; then
        touch $HADOOP_HOME/etc/hadoop/hdfs-site.xml
        echo -e "HDFS Configuration: \nREPLICATION: $APACHE_HADOOP_HDFS_REPLICATION\nHADOOP_USER: $HADOOP_USER\nBLOCK_SIZE: $APACHE_HADOOP_HDFS_BLOCKSIZE\nHADLER_COUNT: $APACHE_HADOOP_HDFS_HANDLERCOUNT\n"
        sed s/REPLICATION/$APACHE_HADOOP_HDFS_REPLICATION/ $HADOOP_HOME/etc/hadoop/clusternode/hdfs-site.xml.template | sed s/USERNAME/$HADOOP_USER/ | \
        sed s/BLOCKSIZE/$APACHE_HADOOP_HDFS_BLOCKSIZE/ | sed s/HANDLERCOUNT/$APACHE_HADOOP_HDFS_HANDLERCOUNT/ > $HADOOP_HOME/etc/hadoop/hdfs-site.xml
      fi
      if [[ "" == "$(cat $HADOOP_HOME/etc/hadoop/yarn-site.xml)" ]]; then
        touch $HADOOP_HOME/etc/hadoop/yarn-site.xml
        if [[ "$APACHE_HADOOP_YARN_ACL_ENABLED" != 'true' ]]; then
          if [[ "$APACHE_HADOOP_YARN_ACL_ENABLED" != 'false' ]]; then
            export APACHE_HADOOP_YARN_ACL_ENABLED=false
          fi
        fi
        if [[ "$APACHE_HADOOP_YARN_LOG_AGGREGATION" != 'true' ]]; then
          if [[ "$APACHE_HADOOP_YARN_LOG_AGGREGATION" != 'false' ]]; then
            export APACHE_HADOOP_YARN_ACL_ENABLED=false
          fi
        fi
        echo -e "Yarn Configuration: \nRESOURCE_MANAGER: $APACHE_HADOOP_YARN_RESOURCE_MANAGER_HOSTNAME\nACL_ENABLED: $APACHE_HADOOP_YARN_ACL_ENABLED\nADMIN_ACL: $APACHE_HADOOP_YARN_ADMIN_ACL\nLOG AGGREGATION: $APACHE_HADOOP_YARN_LOG_AGGREGATION\n"
        sed s/YANR_ACL_ENABLED/$APACHE_HADOOP_YARN_ACL_ENABLED/ $HADOOP_HOME/etc/hadoop/clusternode/yarn-site.xml.template | sed s/ADMIN_ACL/$APACHE_HADOOP_YARN_ADMIN_ACL/ | \
        sed s/LOG_AGGREGATION/$APACHE_HADOOP_YARN_LOG_AGGREGATION/ | sed s/AGGREGATION_RETAIN/$APACHE_HADOOP_YARN_AGGREGATION_RETAIN_SECONDS/ | \
        sed s/AGGREGATION_RETAIN_CHECK/$APACHE_HADOOP_YARN_AGGREGATION_RETAIN_CHECK_SECONDS/ | sed s/RM_HOSTNAME/$APACHE_HADOOP_YARN_RESOURCE_MANAGER_HOSTNAME/ > $HADOOP_HOME/etc/hadoop/yarn-site.xml
      fi
      if [[ "" == "$(cat $HADOOP_HOME/etc/hadoop/mapred-site.xml)" ]]; then
        touch $HADOOP_HOME/etc/hadoop/mapred-site.xml
        echo -e "Map Reduce Configuration: \nMAP_MEM_MBS: $APACHE_HADOOP_MAPRED_MAP_MEMORY_MBS\nMAP_OPTS: $APACHE_HADOOP_MAPRED_MAP_JAVA_OPTS\nRED_MEM_MBS: $APACHE_HADOOP_MAPRED_RED_MEMORY_MBS\nRED_OPTS: $APACHE_HADOOP_MAPRED_RED_JAVA_OPTS\n"
        echo -e "SORT_MEM_MBS: $APACHE_HADOOP_MAPRED_SORT_MEMORY_MBS\nSORT_FACT: $APACHE_HADOOP_MAPRED_SORT_FACTOR\nSHUGGLE_COPIES: $APACHE_HADOOP_MAPRED_SHUFFLE_PARALLELCOPIES\n"
        echo -e "JOB_HISTORY_ADDR: $APACHE_HADOOP_MAPRED_JOB_HISTORY_HOSTNAME\nJOB_HISTORY_PORT: $APACHE_HADOOP_MAPRED_JOB_HISTORY_PORT\nJI_WEB_ADDR: $APACHE_HADOOP_MAPRED_JOB_HISTORY_WEBUI_HOSTNAME\n"
        echo -e "JI_WEB_PORT: $APACHE_HADOOP_MAPRED_JOB_HISTORY_WEBUI_PORT\n"
        sed s/MAPRED_MAP_MEMORY/$APACHE_HADOOP_MAPRED_MAP_MEMORY_MBS/ $HADOOP_HOME/etc/hadoop/clusternode/mapred-site.xml.template | sed s/MAPRED_MAP_JAVA_OPTS/$APACHE_HADOOP_MAPRED_MAP_JAVA_OPTS/ | \
        sed s/MAPRED_RED_JAVA_OPTS/$APACHE_HADOOP_MAPRED_RED_JAVA_OPTS/ | sed s/MAPRED_RED_MEMORY/$APACHE_HADOOP_MAPRED_RED_MEMORY_MBS/ | \
        sed s/MAPRED_SORT_MEMORY/$APACHE_HADOOP_MAPRED_SORT_MEMORY_MBS/ | sed s/MAPRED_SORT_FACTOR/$APACHE_HADOOP_MAPRED_SORT_FACTOR/ | \
        sed s/MAPRED_SHUFFLE/$APACHE_HADOOP_MAPRED_SHUFFLE_PARALLELCOPIES/ | sed s/JOB_HISTORY_HOSTNAME/$APACHE_HADOOP_MAPRED_JOB_HISTORY_HOSTNAME/ | \
        sed s/JOB_HISTORY_PORT/$APACHE_HADOOP_MAPRED_JOB_HISTORY_PORT/ | sed s/JOB_HISTORY_WEBUI_HOSTNAME/$APACHE_HADOOP_MAPRED_JOB_HISTORY_WEBUI_HOSTNAME/ | \
        sed s/JOB_HISTORY_WEBUI_PORT/$APACHE_HADOOP_MAPRED_JOB_HISTORY_WEBUI_PORT/ > $HADOOP_HOME/etc/hadoop/mapred-site.xml
      fi
    fi
  fi
  cp -Rf $HADOOP_HOME/etc/hadoop /usr/local/spark/etc


  if [[ "true" == "$SPARK_START_HADOOP" ]]; then
    service ssh start
    $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    $HADOOP_HOME/bin/hdfs namenode -format -force -nonInteractive && \
    $HADOOP_HOME/sbin/start-dfs.sh && \
    $HADOOP_HOME/bin/hdfs dfs -mkdir /user && \
    $HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/root && \
    $HADOOP_HOME/sbin/stop-dfs.sh
    service ssh stop

    service ssh start
    $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    $HADOOP_HOME/sbin/start-dfs.sh && \
    $HADOOP_HOME/bin/hdfs dfs -mkdir input && \
    $HADOOP_HOME/bin/hdfs dfs -put $HADOOP_HOME/etc/hadoop/ input && \
    $HADOOP_HOME/sbin/stop-dfs.sh
    service ssh stop
    touch /root/hadoop_configured
  else
    echo "Apache™ Hadoop® is deactivate, not configuration action provided!!"
  fi

else
  echo "Apache™ Hadoop® $HAHOOP_VERSION already configured!!"
fi

echo "Apache™ Spark® $SPARK_VERSION (build on $APACHE_HADOOP_VERSION) installed on $HAHOOP_VERSION starting ..."


if [[ "0" != "$CONFIGURED_SPARK_BY_URL_EXIT_CODE" ]]; then
  if ! [[ -e  /root/spark_configured ]]; then
    if [[ "true" != "$SPARK_RUN_STANDALONE" ]]; then
      if [[ "true" != "$START_MASTER_SPARK_NODE" ]]; then
        export START_MASTER_SPARK_NODE=true
      fi
      if [[ "true" == "$SPARK_START_MASTER_NODE" ]]; then
        echo "Apache™ Spark® $SPARK_VERSION (build on $APACHE_HADOOP_VERSION) installed on $HAHOOP_VERSION MASTER mode configuration ..."
        sed s/EVENT_LOG_ENABLED/$SPARK_CONFIG_LOG_EVENT_ENABLED/g $SPARK_HOME/conf/spark-defaults-master.conf | \
        sed s/SPARK_SERIALIZER_CLASS/$SPARK_CONFIG_SERIALIZER_CLASS/g | sed s/SPARK_DRIVER_MEMORY/$SPARK_CONFIG_DRIVER_MEMORY/g | \
        sed s/SPARK_EXTRA_JVM_OPTIONS/$SPARK_CONFIG_EXTRA_JVM_OPTIONS/g | sed s/EVENT_LOG_ENABLED/$SPARK_CONFIG_LOG_EVENT_ENABLED/g | \
        sed s/MAX_RETAIN_APPLICATIONS/$SPARK_CONFIG_DEPLOY_RETAIN_APPS/g | sed s/MAX_RETAIN_DRIVERS/$SPARK_CONFIG_RETAIN_DRIVERS/g | \
        sed s/DEPLOY_DEFAULT_CORES/$SPARK_CONFIG_DEPLOY_DEFAULT_CORES/g | sed s/DEPLOY_SPREAD_OUT/$SPARK_CONFIG_DEPLOY_SPREADOUT/g | \
        sed s/DEPLOY_MAX_RETRIES/$SPARK_CONFIG_DEPLOY_MAX_EXEC_RETRIES/g sed s/WORKER_TIMEOUT/$SPARK_CONFIG_WORKER_TIMEOUT/g \
        > $SPARK_HOME/conf/spark-defaults.conf
      else
        echo "Apache™ Spark® $SPARK_VERSION (build on $APACHE_HADOOP_VERSION) installed on $HAHOOP_VERSION WORKER mode configuration ..."
        MASTER_HOST="${SPARK_START_SLAVE_MASTER_HOST:-`echo $SPARK_MASTER_HOST`}"
        MASTER_PORT="${SPARK_START_SLAVE_MASTER_PORT:-`echo $SPARK_MASTER_PORT`}"
        sed s/EVENT_LOG_ENABLED/$SPARK_CONFIG_LOG_EVENT_ENABLED/g $SPARK_HOME/conf/spark-defaults-worker.conf | \
        sed s/SPARK_SERIALIZER_CLASS/$SPARK_CONFIG_SERIALIZER_CLASS/g | sed s/SPARK_DRIVER_MEMORY/$SPARK_CONFIG_DRIVER_MEMORY/g | \
        sed s/SPARK_EXTRA_JVM_OPTIONS/$SPARK_CONFIG_EXTRA_JVM_OPTIONS/g | sed s/EVENT_LOG_ENABLED/$SPARK_CONFIG_LOG_EVENT_ENABLED/g | \
        sed s/MASTER_HOST/$MASTER_HOST/g | sed s/MASTER_PORT/$MASTER_PORT/g | s/CLEAN_UP_ENABLED/$SPARK_CONFIG_WORKER_CLEANUP_ENABLED/g \
        sed s/CLEAN_UP_INTERVAL/$SPARK_CONFIG_WORKER_CLEANUP_INTERVAL/g | sed s/CLEAN_UP_TTL/$SPARK_CONFIG_WORKER_CLEANUP_TTL/g | \
        sed s/COMPRESSED_CACHED_SIZE/$SPARK_CONFIG_WORKER_COMPRESSED_CACHE_SIZE/g > $SPARK_HOME/conf/spark-defaults.conf
      fi
    else
      echo "Apache™ Spark® $SPARK_VERSION (build on $APACHE_HADOOP_VERSION) installed on $HAHOOP_VERSION STAND-ALONE mode : No configuration applied!!"
    fi
    touch /root/spark_configured
  else
    echo "Apache™ Spark® $SPARK_VERSION (build on $APACHE_HADOOP_VERSION) installed on $HAHOOP_VERSION already configured!!"
  fi
fi


if [[ "true" == "$SPARK_START_INTEGRATE_WITH_YARN" ]]; then
  if [[ -e /etc/config/spark/spark-yarn.conf ]]; then
    echo "Merging custom YARN configuration from : /etc/config/spark/spark-yarn.conf !!"
    echo /etc/config/spark/spark-yarn.conf >>  /usr/local/spark/conf/spark-defaults.conf
  else
    echo "Unable to locate custom YARN configuration in : /etc/config/spark/spark-yarn.conf !!"
    exit 1
  fi
fi

if  [[ $1 == "-daemon" ]]; then
  /etc/bootstrap.sh -d
else
  if [[ $1 == "-interactive" ]]; then
    /etc/bootstrap.sh -bash
  else
    echo "docker-start-spark [mode]"
    echo "-daemon Start with infinite listener"
    echo "-interactive Start with bash shell"
    exit 1
  fi
fi
