# H2O™ Sparkling Water® Docker image


Docker Image for H2o™ Sparkling Water® on Apache™ Spark® Master/Worker Node. This Docker image provides Java, Scala, Python and R execution environment.


### Introduction ###

H2o™ Sparkling Water® provides transparent integration for the H2O engine and its
machine learning algorithms into the Spark platform, enabling:

* Use of H2o™ algorithms in Spark workflow
* Transformation between H2O and Spark data structures
* Use of Apache™ Spark® RDDs and DataFrames as input for H2o™ algorithms
* Use of H2OFrames as input for MLlib algorithms
* Transparent execution of H2o™ Sparkling Water® applications on top of Apache™ Spark®


Here some more info on H2o™ Sparkling Water® :
http://docs.h2o.ai/h2o/latest-stable/h2o-docs/faq.html#sparkling-water

Now something more about Apache™ Spark®'s H2o™ Sparkling Water® available properties (file: `spark-defaults.conf`)  :
https://github.com/h2oai/sparkling-water/blob/master/doc/configuration/configuration_properties.rst


Now something more about Apache™ Spark® :

The Apache™ Spark® is a fast and general-purpose cluster computing system. It provides high-level APIs in Java, Scala, Python and R, and an optimized engine that supports general execution graphs. It also supports a rich set of higher-level tools including Spark SQL for SQL and structured data processing, MLlib for machine learning, GraphX for graph processing, and Spark Streaming.

See : [Apache™ Spark® Overview](http://spark.apache.org/docs/latest/index.html)

This image provides Apache™ Hadoop® environment and integration, now more about that framework.

The Apache™ Hadoop® project develops open-source software for reliable, scalable, distributed computing.

The Apache™ Hadoop® software library is a framework that allows for the distributed processing of large data sets across clusters of computers using simple programming models. It is designed to scale up from single servers to thousands of machines, each offering local computation and storage. Rather than rely on hardware to deliver high-availability, the library itself is designed to detect and handle failures at the application layer, so delivering a highly-available service on top of a cluster of computers, each of which may be prone to failures.


The project includes these modules:

* Hadoop Common: The common utilities that support the other Hadoop modules.
* Hadoop Distributed File System (HDFS™): A distributed file system that provides high-throughput access to application data.
* Hadoop YARN: A framework for job scheduling and cluster resource management.
* Hadoop MapReduce: A YARN-based system for parallel processing of large data sets.


Here some more info on Apache™ Hadoop® :
http://hadoop.apache.org/


### Goals ###

This doscker images has been designed to be a test, development, integration, production environment for Apache™ Spark® single node and cluster instances.
*No warranties for production use.*


### Default Container service configuration ###

Default docker environment configuration enable to start :
* Apache™ Hadoop® HDFS™ service
* Apache™ Spark® all services

If you need a different configutation please note following environment variable, Docker defined capabilities and tips, included in this documentation.
Apache™ Hadoop® HDFS™ service is the minimum Apache™ Hadoop® service needed by Apache™ Spark®, however configuration can change accondingly to deployed architecture.


### Docker Image features ###

Here some information :

Volumes : /user/root/data/hadoop/hdfs/datanode, /user/root/data/hadoop/hdfs/namenode, /user/root/data/hadoop/hdfs/checkpoint, /etc/config/hadoop, /etc/config/spark, /root/application



`/user/root/data/hadoop/hdfs/datanode` :

DataNode storage folder.


`/user/root/data/hadoop/hdfs/namenode` :

NameNode storage folder.


`/user/root/data/hadoop/hdfs/checkpoint`:

Check Point and Check Point Edits storage folder.


`/etc/config/hadoop`:

Configuration folder for Apache™ Hadoop®, and expected/suitable files are :

* `core-site.xml`: Core Site custmized configuration file
* `yarn-site.xml`: Yarn Site custmized configuration file
* `hdfs-site.xml`: HDFS™ Site custmized configuration file
* `mapred-site.xml`: Map Reduce Site custmized configuration file


`/etc/config/spark`:

Configuration folder for Apache™ Spark®, and expected/suitable files are :

* `docker.properties` : Configure MESOS docker image (NOT TESTED YET)
* `log4j.properties` : Configure logging properties
* `slaves` : Configure slave nodes hosts
* `spark-defaults.conf` : Configure default Spark parameters
* `spark-yarn.conf` : Configure default Spark YARN integration parameters. It will be merged in spark-defaults.conf file.

Some format samples (with fine-grained description) at [samples](/samples)
See :
* [Stand Alone Configuration](http://spark.apache.org/docs/latest/spark-standalone.html)
* [Apache YARN Configuration](http://spark.apache.org/docs/latest/running-on-yarn.html)
* [MESOS Configuration](http://spark.apache.org/docs/latest/running-on-mesos.html)


`/root/application`:

Folder dedicated to mount application layer, packages and anything that can be compiled on the machine. If that folder conatains any file
named `bootstrap.sh` it will be executed automatically before Apache™ Spark® starts. In the boostrap shell file, in order to be sure to point to the
right source folder, you have to change to `/root/application` or mark this folder as source root, accordingly to your source ordering and file hierarchy.


Ports:

Apache™ Spark® ports:

8080 (web interface)


Apache™ Hadoop® HDFS™ ports :

50010 50020 50070 50075 50090 8020 9000


Apache™ Hadoop® MAP Reduce ports :

10020 19888


Apache™ Hadoop® YARN ports:

8030 8031 8032 8033 8040 8042 8088 (web interface)


Other Apache™ Hadoop® ports:

49707 2122


### H2o™ Sparkling Water® Docker Environment Entries ###

Here H2o™ Sparkling Water® service configuration environment variables :

* `SPARKLING_EXECUTORS` : Number of executors used in H2o™ Sparkling Water® Worker (default: 1)
* `SPARKLING_EXECUTOR_MEMORY` : Amount of memory used in a single H2o™ Sparkling Water® Worker (default: 4g)
* `SPARKLING_EXECUTOR_CORES` : Number of cores used in a single H2o™ Sparkling Water® Worker (default: 1)
* `SPARKLING_DRIVER_MEMORY` : Global amount of memory used in H2o™ Sparkling Water® driver (default: 4g)


Here Apache™ Spark® service configuration environment variables :

* `SPARK_RUN_STANDALONE` : (true/false) Run Apache™ Spark® in stand-alone mode, no Apache™ Spark® configuration will be applied (default: true)
* `SPARK_HADOOP_TGZ_URL` : Url of a tar gz file within Apache™ Hadoop® configuration files (default: "")
* `SPARK_CONFIG_TGZ_URL` : Url of a tar gz file within Apache™ Spark® and H2o™ Sparkling Water® configuration files (default: "") - auto-execution of custom environment file `init-spark-env.sh`
* `SPARK_START_HADOOP` : Include Apache™ Hadoop® features (true/false) (default: true)
* `SPARK_START_HADOOP_ALL_SERVICES` : (true/false) Auto-Start all Apache™ Hadoop® services at startup other service start configurations will be ignored (default: false)
* `SPARK_START_HADOOP_HDFS` : (true/false) Start Apache™ Hadoop® HDFS™ service (default: true)
* `SPARK_START_HADOOP_YARN` : (true/false) Start Apache™ Hadoop® YARN service (default: false)
* `SPARK_START_HADOOP_JOB_HISTORY` : (true/false) Start Apache™ Hadoop® Mr Job History service (default: false)
* `SPARK_HADOOP_JOB_HISTORY_MAPRED_COMMAND` : Start Apache™ Hadoop® MapReduce history command (default: "")
* `SPARK_START_HADOOP_DEAMONS` : (true/false)  Start Apache™ Hadoop® Daemons service (default: false)
* `SPARK_START_HADOOP_DEAMON` : (true/false)  Start Apache™ Hadoop® Daemon service (default: false)
* `SPARK_HADOOP_DEAMON_COMMAND` :  Apache™ Hadoop® MAP-RED Command with arguments (default: "")
* `SPARK_START_HADOOP_YARN_DEAMONS` : (true/false) Start Apache™ Hadoop® Yarn Daemons (default: false)
* `SPARK_START_HADOOP_YARN_DEAMON` : (true/false)  Start Apache™ Hadoop® Yarn Daemon service (default: false)
* `SPARK_HADOOP_YARN_DEAMON_COMMAND` :  Apache™ Hadoop® Yarn Daemon command with arguments (default: "")
* `SPARK_START_HADOOP_BALANCER` : (true/false) Start Apache™ Hadoop® Load Balancer service (default: false)
* `SPARK_START_HADOOP_KMS_SERVER` : (true/false) Start Apache™ Hadoop® KMS service(default: false)
* `SPARK_START_MASTER_NODE` : (true/false) Start Apache™ Spark® as Master node, elsewise it will be considered a worker (default: true)
* `SPARK_START_SLAVE_MASTER_HOST` : Apache™ Spark® worker Master Hostname/IPv4/IPv6 address (default: "")
* `SPARK_START_SLAVE_MASTER_PORT` : Apache™ Spark® worker Master Port (default: "")
* `SPARK_START_SLAVE_MASTER_WEBUI_PORT` : Apache™ Spark® worker Master Web UI port (default: "")
* `SPARK_START_SLAVE_CORES` : Apache™ Spark® worker number of cores provided to master for jobs (default: 1)
* `SPARK_START_SLAVE_MEMORY` : Apache™ Spark® worker amount of memory provided to master for jobs (default: 2G)
* `SPARK_START_ALL_SERVICES` : (true/false) Auto-Start all Apache™ Spark® services at startup other service start configurations will be ignored (default: true)
* `SPARK_START_ALL_SLAVES` : (true/false) Start All Apache™ Spark® Slaves from `slave` file (default: false)
* `SPARK_START_HISTORY_SERVER` : (true/false) Start Apache™ Spark® History service (default: false)
* `SPARK_START_SHUFFLE_SERVICE` : (true/false) Start Apache™ Spark® Shuffle service (default: false)
* `SPARK_START_DEAMONS` : (true/false) Start Apache™ Spark® Daemons (default: false)
* `SPARK_START_DEAMON` : (true/false) Start Apache™ Spark® Daemon (default: false)
* `SPARK_DAEMON_COMMAND` :  Apache™ Spark® Daemon command with arguments (default: "")
* `SPARK_START_THRIFT_SERVER` : (true/false) Start Apache™ Spark® Thrift Server (default: false)
* `SPARK_START_MESOS_INTEGRATION` : (true/false) Start Apache™ Spark® MESOS integration (default: false)
* `SPARK_START_INTEGRATE_WITH_YARN` : (true/false) Apply Apache™ Spark® Integration from file `spark-yarn.conf` (default: false)
* `SPARK_START_YARN_CLASSNAME` : YARN Client execution full class name (default: "") - we consider any jar from volume flat folder `/etc/config/spark/libs`. Use _SLAVE_ CORES, MEMORY, and SPARK_CONFIG_DRIVER_MEMORY, SPARK_START_YARN_QUEUE_NAME to setup YARN. we consider as boostrap jar named `/etc/config/spark/libs/spark-bootstrap.jar`
* `SPARK_START_YARN_ARGUMENTS` : YARN Client execution class arguments (default: "")
* `SPARK_START_YARN_QUEUE_NAME` : YARN Application Queue Name (default: "master-queue")
* `SPARK_FORCE_HADOOP_RESTART` : (true/false) Force restart  Apache™ Hadoop® any container restart or any entry-point access access (default: false - suggested)
* `SPARK_FORCE_RESTART` : (true/false) Force restart  Apache™ Spark® any container restart or any entry-point access access (default: false - suggested)


Here Apache™ Spark® common Spark configuration environment variables :
* `SPARK_CONFIG_LOG_EVENT_ENABLED` : (true/false) Enable/Disable Apache™ Spark® Log Event Engine (default: true - suggested)
* `SPARK_CONFIG_SERIALIZER_CLASS` : Apache™ Spark® serializer class (default: org.apache.spark.serializer.KryoSerializer)
* `SPARK_CONFIG_DRIVER_MEMORY` :  Apache™ Spark® Global Memory (default: 5g) - use lower case memory unit
* `SPARK_CONFIG_EXTRA_JVM_OPTIONS` : Extra Apache™ Spark® JVM options (default: "" - disabled) - sample : `-XX:+PrintGCDetails -Dkey=value -Dnumbers="one two three"`


Here Apache™ Spark® Master Spark node configuration environment variables :
* `SPARK_CONFIG_DEPLOY_RETAIN_APPS` : The maximum number of completed applications to display. Older applications will be dropped from the UI to maintain this limit (default: 200)
* `SPARK_CONFIG_RETAIN_DRIVERS` : The maximum number of completed drivers to display. Older drivers will be dropped from the UI to maintain this limit (default: 200)
* `SPARK_CONFIG_DEPLOY_SPREADOUT` : (true/false) Whether the standalone cluster manager should spread applications out across nodes or try to consolidate them onto as few nodes as possible. Spreading out is usually better for data locality in HDFS™, but consolidating is more efficient for compute-intensive workloads (default: true)
* `SPARK_CONFIG_DEPLOY_DEFAULT_CORES` : Default number of cores to give to applications in Spark's standalone/master mode if they don't set spark.cores.max. If not set, applications always get all available cores unless they configure spark.cores.max themselves. Set this lower on a shared cluster to prevent users from grabbing the whole cluster by default (default: 4)
* `SPARK_CONFIG_DEPLOY_MAX_EXEC_RETRIES` : Limit on the maximum number of back-to-back executor failures that can occur before the standalone cluster manager removes a faulty application. An application will never be removed if it has any running executors. If an application experiences more than spark.deploy.maxExecutorRetries failures in a row, no executors successfully start running in between those failures, and the application has no running executors then the standalone cluster manager will remove the application and mark it as failed. To disable this automatic removal, set spark.deploy.maxExecutorRetries to -1 (default: 10)
* `SPARK_CONFIG_WORKER_TIMEOUT` : Number of seconds after which the standalone deploy master considers a worker lost if it receives no heartbeats (default: 60)


Here Apache™ Spark® Worker Spark node configuration environment variables :
* `SPARK_CONFIG_WORKER_CLEANUP_ENABLED` : (true/false) Enable periodic cleanup of worker / application directories. Note that this only affects standalone mode, as YARN works differently. Only the directories of stopped applications are cleaned up (default: false - suggested)
* `SPARK_CONFIG_WORKER_CLEANUP_INTERVAL` : Controls the interval, in seconds, at which the worker cleans up old application work dirs on the local machine (default: 1800  == 30 minutes)
* `SPARK_CONFIG_WORKER_CLEANUP_TTL` : The number of seconds to retain application work directories on each worker. This is a Time To Live and should depend on the amount of available disk space you have. Application logs and jars are downloaded to each application work dir. Over time, the work dirs can quickly fill up disk space, especially if you run jobs very frequently(default: 604800  == 7 * 24 * 3600 [7 days])
* `SPARK_CONFIG_WORKER_COMPRESSED_CACHE_SIZE` : For compressed log files, the uncompressed file can only be computed by uncompressing the files. Spark caches the uncompressed file size of compressed log files. This property controls the cache size (default: 100)


See :
* [Stand Alone Configuration](http://spark.apache.org/docs/latest/spark-standalone.html)
* [Apache YARN Configuration](http://spark.apache.org/docs/latest/running-on-yarn.html)
* [MESOS Configuration](http://spark.apache.org/docs/latest/running-on-mesos.html)

*NOTE :*
Any Apache™ Spark® and Apache™ Hadoop® environment variable can be placed in a shell script file  named `init-spark-env.sh` in the `SPARK_CONFIG_TGZ_URL` tgz file or
in `/etc/config/spark` volume folder.


### Apache™ Spark® useful Environment Entries ###


Here futher environment variables :
* `SPARK_MASTER_HOST` : Bind the master to a specific hostname or IP address, for example a public one.
* `SPARK_MASTER_PORT` : Start the master on a different port (default: 7077).
* `SPARK_MASTER_WEBUI_PORT` : Port for the master web UI (default: 8080).
* `SPARK_MASTER_OPTS` : Configuration properties that apply only to the master in the form "-Dx=y" (default: none). See below for a list of possible options.
* `SPARK_LOCAL_DIRS` : Directory to use for "scratch" space in Spark, including map output files and RDDs that get stored on disk. This should be on a fast, local disk in your system. It can also be a comma-separated list of multiple directories on different disks.
* `SPARK_WORKER_CORES` : Total number of cores to allow Spark applications to use on the machine (default: all available cores).
* `SPARK_WORKER_MEMORY` : Total amount of memory to allow Spark applications to use on the machine, e.g. 1000m, 2g (default: total memory minus 1 GB); note that each application's individual memory is configured using its spark.executor.memory property.
* `SPARK_WORKER_PORT` : Start the Spark worker on a specific port (default: random).
* `SPARK_WORKER_WEBUI_PORT` : Port for the worker web UI (default: 8081).
* `SPARK_WORKER_DIR` : Directory to run applications in, which will include both logs and scratch space (default: SPARK_HOME/work).
* `SPARK_WORKER_OPTS` : Configuration properties that apply only to the worker in the form "-Dx=y" (default: none). See below for a list of possible options.
* `SPARK_DAEMON_MEMORY` : Memory to allocate to the Spark master and worker daemons themselves (default: 1g).
* `SPARK_DAEMON_JAVA_OPTS` : JVM options for the Spark master and worker daemons themselves in the form "-Dx=y" (default: none).
* `SPARK_PUBLIC_DNS` : The public DNS name of the Spark master and workers (default: none).

*NOTE :*
Any Apache™ Spark® and Apache™ Hadoop® environment variable can be placed in a shell script file  named `init-spark-env.sh` in the `SPARK_CONFIG_TGZ_URL` tgz file or
in `/etc/config/spark` volume folder.


###  Apache™ Spark® Integrations configuration ###

YARN integration :

We refer to file `spark-yarn.conf` that can be included in volume `spark-yarn.conf` or in Spark tar-gz URL.
Docker System entry that activates YARN integration is : `SPARK_START_INTEGRATE_WITH_YARN`


### Apache™ Hadoop® Docker Environment Entries ###

Here Apache™ Hadoop® single mode container environment variables :

* `MACHINE_TIMEZONE` : Set Machine timezone ([See Timezones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones))
* `APACHE_HADOOP_SITE_BUFFER_SIZE` : Set Hadoop Buffer Size (default: 131072)
* `APACHE_HADOOP_SITE_HOSTNAME`: Set Hadoop master site hostname, as default `localhost` will be replaced with machine hostname

For more information about values : [Apache™ Hadoop® Single Node](http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/SingleCluster.html)


Here Apache™ Hadoop® cluster mode container environment variables :

* `MACHINE_TIMEZONE` : Set Machine timezone ([See Timezones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones))
* `APACHE_HADOOP_IS_CLUSTER` : Set cluster mode (yes/no)
* `APACHE_HADOOP_IS_MASTER` : Does this node lead cluster workers as the cluter master node? (yes/no)
* `APACHE_HADOOP_SITE_BUFFER_SIZE` : Set Hadoop Buffer Size (default: 131072)
* `APACHE_HADOOP_SITE_HOSTNAME`: Set Hadoop master site hostname, as default `localhost` will be replaced with machine hostname
* `APACHE_HADOOP_HDFS_REPLICATION`: Set HDFS™ Replication factor  (default: 1)
* `APACHE_HADOOP_HDFS_BLOCKSIZE`: Set HDFS™ Block Size (default: 268435456)
* `APACHE_HADOOP_HDFS_HANDLERCOUNT`: Set HDFS™ Header Count (default: 100)
* `APACHE_HADOOP_YARN_RESOURCE_MANAGER_HOSTNAME`: Set Yarn Resource Manager hostname, as default `localhost` will be replaced with machine hostname
* `APACHE_HADOOP_YARN_ACL_ENABLED`: Set Yarn ACL Enabled (default: false values: true|false)
* `APACHE_HADOOP_YARN_ADMIN_ACL`: Set Admin ACL Name (default: `*`)
* `APACHE_HADOOP_YARN_AGGREGATION_RETAIN_SECONDS`: Set Yarn Log aggregation retain time in seconds (default: 60)
* `APACHE_HADOOP_YARN_AGGREGATION_RETAIN_CHECK_SECONDS`: Set Yarn Log aggregation retain chack time in seconds (default: 120)
* `APACHE_HADOOP_YARN_LOG_AGGREGATION`: Set Yarn Log Aggregation enabled (default: false values: true|false)
* `APACHE_HADOOP_MAPRED_JOB_HISTORY_HOSTNAME`: Set Job History Server Address/Hostname, as default `localhost` will be replaced with machine hostname
* `APACHE_HADOOP_MAPRED_JOB_HISTORY_PORT`: Set Job History Server Port (default: 10020)
* `APACHE_HADOOP_MAPRED_JOB_HISTORY_WEBUI_HOSTNAME`: Set Job History Web UI Server Address/Hostname, as default `localhost` will be replaced with machine hostname
* `APACHE_HADOOP_MAPRED_JOB_HISTORY_WEBUI_PORT`:Set Job History Web UI Server Port (default: 19888)
* `APACHE_HADOOP_MAPRED_MAP_MEMORY_MBS`: Set Map Reduce Map allocated Memory in MBs (default: 1536)
* `APACHE_HADOOP_MAPRED_MAP_JAVA_OPTS`: Set Map Reduce Map Java options  (default: `-Xmx1024M`)
* `APACHE_HADOOP_MAPRED_RED_MEMORY_MBS`: Set Map Reduce Reduce allocated Memory in MBs (default: 3072)
* `APACHE_HADOOP_MAPRED_RED_JAVA_OPTS`: Set Map Reduce Reduce Java options (default: `-Xmx2560M`)
* `APACHE_HADOOP_MAPRED_SORT_MEMORY_MBS`: Set Map Reduce Sort allocated Memory in MBs (default: 512)
* `APACHE_HADOOP_MAPRED_SORT_FACTOR`: Set Map Reduce Sort factor (default: 100)
* `APACHE_HADOOP_MAPRED_SHUFFLE_PARALLELCOPIES`: Set Map Reduce Shuffle parallel copies limit (default: 50)

For more information about values : [Apache™ Hadoop® Cluster Setup](http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/ClusterSetup.html)

*NOTE :*
Any Apache™ Spark® and Apache™ Hadoop® environment variable can be placed in a shell script file  named `init-spark-env.sh` in the `SPARK_CONFIG_TGZ_URL` tgz file or
in `/etc/config/spark` volume folder.


### Sample command ###

Here a sample command to run Apache™ Spark® container:

```bash
docker run -d -p 49707:49707 -p 2122:2122 -p 8030:8030 -p 8031:8031 -p 8032:8032 -p 8033:8033 -p 8040:8040 -p 8042:8042 \
       -p 8088:8088 -p 10020:10020 -p 19888:19888  -p 50010:50010  -p 50020:50020  -p 50070:50070  -p 50075:50075  -p 50090:50090 \
        -p 8020:8020  -p 9000:9000 -p 8080:8080 -v my/datanode/dir:/user/root/data/hadoop/hdfs/datanode -v my/namenode/dir:/user/root/data/hadoop/hdfs/namenode \
         -v my/checkpoint/dir:/user/root/data/hadoop/hdfs/checkpoint -v my/hadoop/config/files/dir:/etc/config/hadoop \
         -v my/spark/config/files/dir:/etc/config/spark --name my-apache-spark hellgate75/sparkling-wter:2.1.8
```


### Test Spark / YARN console ###

In order to access to Apache™ Spark® web console you can use a web browser and type :
```bash
    #For Apache™ Spark® test:
    http://{hostname or ip address}:8080
    eg.:
    http://localhost:8080 for a local container
```


### License ###

[LGPL 3](https://github.com/hellgate75/sparkling-water/blob/master/LICENSE)
