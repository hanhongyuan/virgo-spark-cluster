
export YARN_CONF_DIR="$(pwd)"

SPARK_VERSION=2.2.3

DEPLOY_MODE=${1:-cluster}
export HADOOP_USER_NAME=${2:-virgo}

if [[ $(spark-submit --version 2> out) && $(cat out | grep -o $SPARK_VERSION out | head -n 1) != $SPARK_VESRION ]]; then  
	echo "Wrong Version for Spark binaries. Expected Spark version: $SPARK_VERSION"; 
else 
	echo "using SPARK $SPARK_VERSION"; 
fi

NAMENODE=hdfs://hadoop-namenode:8020
echo "Submitting job as YARN $DEPLOY_MODE to $NAMENODE"

if [ "$DEPLOY_MODE" == "cluster" ]; then 

$SPARK_HOME/bin/spark-submit \
  --master yarn \
  --deploy-mode cluster \
  --executor-cores 8 \
  --executor-memory 4G \
  --queue test \
  --conf spark.yarn.jars="$NAMENODE/apps/spark/jars/*.jar" \
  --conf "spark.yarn.appMasterEnv.HADOOP_USER_NAME=${HADDOP_USER_NAME}" \
  --conf "spark.yarn.historyServer.address=http://spark-historyserver:18080" \
  --conf "spark.eventLog.enabled=true" \
  --conf "spark.eventLog.dir=hdfs://hadoop-namenode:8020/logs/spark" \
  --conf "spark.history.fs.logDirectory=hdfs://hadoop-namenode:8020/logs/spark" \
  --conf spark.yarn.am.extraJavaOptions="-XX:ReservedCodeCacheSize=100M -XX:MaxMetaspaceSize=256m -XX:CompressedClassSpaceSize=256m" \
  --class org.apache.spark.examples.SparkPi \
  $NAMENODE/apps/spark-examples_2.11-2.2.3.jar \
100

else 

if [[ $(uname) -eq "Linux" ]]; then 
	SPARK_LOCAL_IP=$(ip route get 1 | awk '{print $7}' | head -n 1)
else
	SPARK_LOCAL_IP=127.0.0.1
fi

echo "Using Spark Local IP: $SPARK_LOCAL_IP connecting to remote YARN service as $HADOOP_USER_NAME"


$SPARK_HOME/bin/spark-submit \
  --master yarn \
  --deploy-mode client \
  --executor-cores 8 \
  --executor-memory 4G \
  --queue test \
  --conf spark.yarn.jars="$NAMENODE/apps/spark/jars/*.jar" \
  --conf "spark.yarn.appMasterEnv.HADOOP_USER_NAME=${HADDOP_USER_NAME}" \
  --conf "spark.eventLog.enabled=true" \
  --conf "spark.eventLog.dir=hdfs://hadoop-namenode:8020/logs/spark" \
  --conf "spark.history.fs.logDirectory=hdfs://hadoop-namenode:8020/logs/spark" \
  --conf "spark.yarn.historyServer.address=http://spark-historyserver:18080" \
  --conf spark.driver.extraJavaOptions="-XX:ReservedCodeCacheSize=100M -XX:MaxMetaspaceSize=256m -XX:CompressedClassSpaceSize=256m" \
  --class org.apache.spark.examples.SparkPi \
  $NAMENODE/apps/spark-examples_2.11-2.2.3.jar \
100

fi 
