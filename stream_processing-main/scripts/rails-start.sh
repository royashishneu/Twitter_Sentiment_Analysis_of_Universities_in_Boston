#! /bin/bash

cd /home/ubuntu/spark-3.2.0-bin-hadoop3.2-scala2.13 || exit

nohup /home/ubuntu/spark-3.2.0-bin-hadoop3.2-scala2.13/bin/spark-class org.apache.spark.deploy.SparkSubmit \
--class edu.neu.csye7200.twitterproject.StreamProcessing \
--master local \
/home/ubuntu/spark/real_time_twitter_sentiment_analytics_system-1.0-SNAPSHOT-jar-with-dependencies.jar  > ~/application.log 2>&1 &
echo -e "started" >> /home/ubuntu/started