package edu.neu.csye7200.twitterproject.utils

object PropertiesLoaderUtils {
  val sentiment140TrainingDatasetPath = "src/main/resources/training.1600000.processed.noemoticon.csv"
  val sentiment140TestingDatasetPath = "src/main/resources/new.testdata.manual.2009.06.14.csv"
  val nltkStopWordsFileName = "NLTK_English_Stopwords_Corpus.txt"
  val naiveBayesModelPath = "src/main/output/model"  // submit job in IDE
  val naiveBayesModelAccuracyPath = "src/main/output/accuracy" // submit job in IDE
//  val naiveBayesModelPath = "output"  // submit job in Spark Standalone
//  val naiveBayesModelAccuracyPath = "output" // submit job in Spark Standalone
}
