package edu.neu.csye7200.twitterproject.ml

import edu.neu.csye7200.twitterproject.utils.{PropertiesLoaderUtils, SQLContextSingleton, StopWordsLoader}
import org.apache.spark.broadcast.Broadcast
import org.apache.spark.mllib.classification.{NaiveBayes, NaiveBayesModel}
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.rdd.RDD
import org.apache.spark.serializer.KryoSerializer
import org.apache.spark.sql._
import org.apache.spark.{SparkConf, SparkContext}
import org.apache.hadoop.io.compress.GzipCodec


object MLlibNaiveBayesModelCreator {

  def main(args: Array[String]) {
    val sc = createSparkContext()
//    LogUtils.setLogLevels(sc)
    val stopWordsList = sc.broadcast(StopWordsLoader.loadStopWords(PropertiesLoaderUtils.nltkStopWordsFileName))
    createAndSaveNBModel(sc, stopWordsList)
    validateAccuracyOfNBModel(sc, stopWordsList)
  }

  def replaceNewLines(tweetText: String): String = {
    tweetText.replaceAll("\n", "")
  }

  def createSparkContext(): SparkContext = {
    val conf = new SparkConf().setMaster("local")
      .setAppName(this.getClass.getSimpleName)
      .set("spark.serializer", classOf[KryoSerializer].getCanonicalName)
    val sc = SparkContext.getOrCreate(conf)
    sc
  }

  def createAndSaveNBModel(sc: SparkContext, stopWordsList: Broadcast[List[String]]): Unit = {
    val tweetsDF: DataFrame = loadSentiment140File(sc, PropertiesLoaderUtils.sentiment140TrainingDatasetPath)

    val labeledRDD = tweetsDF.select("polarity", "status").rdd.map {
      case Row(polarity: Int, tweet: String) =>
        val tweetInWords: Seq[String] = MLlibNaiveBayesPrediction.getClearTweetText(tweet, stopWordsList.value)
        LabeledPoint(polarity, MLlibNaiveBayesPrediction.transformFeatures(tweetInWords))
    }
    labeledRDD.cache()

    val naiveBayesModel: NaiveBayesModel = NaiveBayes.train(labeledRDD, lambda = 1.0, modelType = "multinomial")
    naiveBayesModel.save(sc, PropertiesLoaderUtils.naiveBayesModelPath)
  }

  def validateAccuracyOfNBModel(sc: SparkContext, stopWordsList: Broadcast[List[String]]): Unit = {
    val naiveBayesModel: NaiveBayesModel = NaiveBayesModel.load(sc, PropertiesLoaderUtils.naiveBayesModelPath)

    val tweetsDF: DataFrame = loadSentiment140File(sc, PropertiesLoaderUtils.sentiment140TestingDatasetPath)
    val actualVsPredictionRDD = tweetsDF.select("polarity", "status").rdd.map {
      case Row(polarity: Int, tweet: String) =>
        val tweetText = replaceNewLines(tweet)
        val tweetInWords: Seq[String] = MLlibNaiveBayesPrediction.getClearTweetText(tweetText, stopWordsList.value)
        (polarity.toDouble,
          naiveBayesModel.predict(MLlibNaiveBayesPrediction.transformFeatures(tweetInWords)),
          tweetText)
    }
    val accuracy = 100.0 * actualVsPredictionRDD.filter(x => x._1 == x._2).count() / tweetsDF.count()

    println(f"""\n\t[******** ML model prediction accuracy compared to actual: $accuracy%.2f%% ********]\n""")
//    saveAccuracy(sc, actualVsPredictionRDD)
  }

  def loadSentiment140File(sc: SparkContext, sentiment140FilePath: String): DataFrame = {
    val sqlContext = SQLContextSingleton.getInstance(sc)
    val tweetsDF = sqlContext.read
      .format("com.databricks.spark.csv")
      .option("header", "false")
      .option("inferSchema", "true")
      .load(sentiment140FilePath)
      .toDF("polarity", "id", "date", "query", "user", "status")

    tweetsDF.drop("id").drop("date").drop("query").drop("user")
  }

//  def saveAccuracy(sc: SparkContext, actualVsPredictionRDD: RDD[(Double, Double, String)]): Unit = {
//    val sqlContext = SQLContextSingleton.getInstance(sc)
//    import sqlContext.implicits._
//    val actualVsPredictionDF = actualVsPredictionRDD.toDF("Actual", "Predicted", "Text")
//    actualVsPredictionDF.coalesce(1).write
//      .format("com.databricks.spark.csv")
//      .option("header", "true")
//      .option("delimiter", "\t")
//      // Compression codec to compress while saving to file.
//      .option("codec", classOf[GzipCodec].getCanonicalName)
//      .mode(SaveMode.Append)
//      .save(PropertiesLoaderUtils.naiveBayesModelAccuracyPath)
//  }



}