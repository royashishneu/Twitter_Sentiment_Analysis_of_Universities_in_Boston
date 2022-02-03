package edu.neu.csye7200.twitterproject.nlp

import edu.stanford.nlp.ling.CoreAnnotations
import edu.stanford.nlp.neural.rnn.RNNCoreAnnotations
import edu.stanford.nlp.pipeline.{Annotation, StanfordCoreNLP}
import edu.stanford.nlp.sentiment.SentimentCoreAnnotations

import java.util.Properties
import scala.collection.mutable.ListBuffer
//import scala.collection.convert.ImplicitConversions.`collection AsScalaIterable` // Scala 2.13 -, is deprecated in new version
import scala.jdk.CollectionConverters._  // Scala 2.13 +

object CoreNLPPrediction {

  lazy val pipeline: StanfordCoreNLP = {
    val props = new Properties()
    props.setProperty("annotators", "tokenize, ssplit, pos, lemma, parse, sentiment")
    new StanfordCoreNLP(props)
  }

  // normalization
  def normalizeCoreNLPSentiment(sentiment: Double): Int = {
    sentiment match {
      case s if s <= 0.0 => 0 // neutral
      case s if s < 1.1 => -2 // upset
      case s if s < 2.0 => -1 // unhappy
      case s if s < 3.0 => 0 // neutral
      case s if s < 3.1 => 1 // happy
      case s if s < 5.0 => 2 // cheerful
      case _ => 0 // neutral
    }
  }

  def extractSentiments(text: String): List[(String, Int)] = {
    val annotation: Annotation = pipeline.process(text)
    val sentences = annotation.get(classOf[CoreAnnotations.SentencesAnnotation]).asScala
    sentences
      .map(sentence => (sentence, sentence.get(classOf[SentimentCoreAnnotations.SentimentAnnotatedTree])))
      .map { case (sentence, tree) => (sentence.toString, normalizeCoreNLPSentiment(RNNCoreAnnotations.getPredictedClass(tree))) }
      .toList
  }

  def computeWeightedSentiment(tweet: String): Int = {

    val annotation = pipeline.process(tweet)
    val sentiments: ListBuffer[Double] = ListBuffer()
    val sizes: ListBuffer[Int] = ListBuffer()

    for (sentence <- annotation.get(classOf[CoreAnnotations.SentencesAnnotation]).asScala) {
      val tree = sentence.get(classOf[SentimentCoreAnnotations.SentimentAnnotatedTree])
      val sentiment = RNNCoreAnnotations.getPredictedClass(tree)

      sentiments += sentiment.toDouble
      sizes += sentence.toString.length
    }

    val weightedSentiment = if (sentiments.isEmpty) {
      -1
    } else {
      val weightedSentiments = sentiments.lazyZip(sizes).map((sentiment, size) => sentiment * size)
      weightedSentiments.sum / sizes.sum
    }

    normalizeCoreNLPSentiment(weightedSentiment)
  }
}
