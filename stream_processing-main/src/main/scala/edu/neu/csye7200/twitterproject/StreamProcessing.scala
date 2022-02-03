package edu.neu.csye7200.twitterproject

import edu.neu.csye7200.twitterproject.database.MySQLManager
//import edu.neu.csye7200.twitterproject.ml.MLlibNaiveBayesPrediction
import edu.neu.csye7200.twitterproject.nlp.CoreNLPPrediction
import edu.neu.csye7200.twitterproject.utils.{ConnectUtils, PropertiesLoaderUtils, StopWordsLoader}
import org.apache.kafka.common.serialization.StringDeserializer
import org.apache.log4j.BasicConfigurator
import org.apache.spark.mllib.classification.NaiveBayesModel
import org.apache.spark.SparkConf
import org.apache.spark.serializer.KryoSerializer
import org.apache.spark.streaming.kafka010.{ConsumerStrategies, KafkaUtils, LocationStrategies}
import org.apache.spark.streaming.{Seconds, StreamingContext}



object StreamProcessing {
  def main(args: Array[String]): Unit = {
//    BasicConfigurator.configure()

    // create StreamingContext
//    val conf = new SparkConf().setMaster("local[2]").setAppName("twitter_stream_processing") // submit job in IDE
    val conf = new SparkConf().setAppName("twitter_stream_processing") // submit job in Spark Standalone
    val ssc = new StreamingContext(conf, Seconds(5))


    // setup Kafka params
    val kafkaParams = Map[String, Object](
      elems = "bootstrap.servers"->ConnectUtils.getParams("KAFKA_IP"),
      "key.deserializer"->classOf[StringDeserializer],
      "value.deserializer"->classOf[StringDeserializer],
      "group.id"->"group_1",
      "auto.offset.reset"->"latest",
      "enable.auto.commit"->(true: java.lang.Boolean)
    )
    // setup consumer Kafka topics
    val topics = Array("twitterdata")

    // consume discretized streams(DStream) from Kafka
    val kafkaDStream = KafkaUtils.createDirectStream[String, String](
      ssc,
      LocationStrategies.PreferConsistent,
      ConsumerStrategies.Subscribe[String,String](topics, kafkaParams)
    )

    // create ml model and stopWords list
//    val naiveBayesModel = NaiveBayesModel.load(ssc.sparkContext, PropertiesLoaderUtils.naiveBayesModelPath)
//    val stopWordsList = ssc.sparkContext.broadcast(StopWordsLoader.loadStopWords(PropertiesLoaderUtils.nltkStopWordsFileName))

    // compute each RDD in discretized streams(DStream)
    kafkaDStream.foreachRDD(rdd => {
      rdd.foreachPartition(partitionOfRecords => {
          //both partition and record are located in local Worker
          //get MySQL connection
          val conn = MySQLManager.getMysqlPool.getConnection
          if (conn == null) {
            println("conn is null.")  //// print in the executor of worker
          } else {
            println("conn is not null.")

            //create statement
            val statement = conn.createStatement()
            try {
              conn.setAutoCommit(false) //commit manually
              partitionOfRecords.foreach(record => {
                val recordArray = record.value().split("%%%%%")
                val keyword = recordArray(0)
                val token = recordArray(1)
                val tweet = recordArray(2)
                val like_num = recordArray(3).toInt
//                val reply_num = recordArray(4).toInt
                val retweet_num = recordArray(4).toInt
                println(keyword)
                println(token)
                println(tweet)
                println(like_num)
//                println(reply_num)
                println(retweet_num)
//                val res1 = MLlibNaiveBayesPrediction.computeSentiment(record.value(), stopWordsList, naiveBayesModel)
//                println(res1)
                val sentiment_res = CoreNLPPrediction.computeWeightedSentiment(tweet)
                println(sentiment_res)
                println("--------------------------------------------------")
                // create SQL query and add it into batch
                val sql = "INSERT INTO tweetsInfo(keyword,token,sentiment_res,like_num,retweet_num) " +
                          "values ("+"'"+keyword+"'"+","+"'"+token+"'"+","+sentiment_res+","+like_num+","+retweet_num+");"
                statement.addBatch(sql) // add into batch
              })
              statement.executeBatch() //execute query in batch
              conn.commit() //transaction commit
            } catch {
              case e: Exception => e.printStackTrace()
            } finally {
              statement.close() //close statment
              conn.close() //close connection
            }
          }

//       })
      })
    })

    // start the computation
    ssc.start()
    // wait for the computation to terminate
    ssc.awaitTermination()
  }
}


/*
优化，
动态地址，kafka mysql
确认.env 用不用写在path里
确认topic name是不是twitterdata
 */