package edu.neu.csye7200.twitterproject.utils

import org.apache.spark.SparkContext
import org.apache.spark.sql.{SQLContext, SparkSession}


// lazy SQL context singleton, initialize as needed
object SQLContextSingleton {

  @transient
  @volatile private var instance: SQLContext = _

  def getInstance(sc: SparkContext): SQLContext = {
    if (instance == null) {
      synchronized {
        if (instance == null) {
//          instance = SQLContext.getOrCreate(sparkContext)
            instance = SparkSession.builder.config(sc.getConf).getOrCreate().sqlContext // Spark 2.0 new API

        }
      }
    }
    instance
  }
}