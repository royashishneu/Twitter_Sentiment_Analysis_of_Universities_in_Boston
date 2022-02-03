package edu.neu.csye7200.twitterproject.utils

import scala.io.Source


object StopWordsLoader {

  def loadStopWords(stopWordsFileName: String): List[String] = {
    Source.fromResource(stopWordsFileName).getLines().toList // Scala 2.12+
//    Source.fromInputStream(getClass.getResourceAsStream(stopWordsFileName)).getLines().toList

  }
}
