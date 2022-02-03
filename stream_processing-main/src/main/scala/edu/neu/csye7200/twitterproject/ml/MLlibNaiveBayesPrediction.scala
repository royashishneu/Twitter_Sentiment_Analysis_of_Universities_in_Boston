package edu.neu.csye7200.twitterproject.ml

import org.apache.spark.broadcast.Broadcast
import org.apache.spark.mllib.classification.NaiveBayesModel
import org.apache.spark.mllib.feature.HashingTF
import org.apache.spark.mllib.linalg.Vector


object MLlibNaiveBayesPrediction {


  def computeSentiment(text: String, stopWordsList: Broadcast[List[String]], model: NaiveBayesModel): Int = {
    val tweetInWords: Seq[String] = getClearTweetText(text, stopWordsList.value)
    val polarity = model.predict(MLlibNaiveBayesPrediction.transformFeatures(tweetInWords))
    normalizeMLlibSentiment(polarity)
  }

  def normalizeMLlibSentiment(sentiment: Double): Int = {
    sentiment match {
      case x if x == 0 => -1 // negative
      case x if x == 2 => 0 // neutral
      case x if x == 4 => 1 // positive
      case _ => 0 // neutral
    }
  }

  def getClearTweetText(tweetText: String, stopWordsList: List[String]): Seq[String] = {
    //Remove URLs, RT, MT and other redundant chars / strings from the tweets.
    tweetText.toLowerCase()
      .replaceAll("\n", "")
      .replaceAll("rt\\s+", "")
      .replaceAll("\\s+@\\w+", "")
      .replaceAll("@\\w+", "")
      .replaceAll("\\s+#\\w+", "")
      .replaceAll("#\\w+", "")
      .replaceAll("(?:https?|http?)://[\\w/%.-]+", "")
      .replaceAll("(?:https?|http?)://[\\w/%.-]+\\s+", "")
      .replaceAll("(?:https?|http?)//[\\w/%.-]+\\s+", "")
      .replaceAll("(?:https?|http?)//[\\w/%.-]+", "")
      .split("\\W+")
      .filter(_.matches("^[a-zA-Z]+$"))
      .filter(!stopWordsList.contains(_))
  }

  val hashingTF = new HashingTF()

  def transformFeatures(tweetText: Seq[String]): Vector = {
    hashingTF.transform(tweetText)
  }
}