package edu.neu.csye7200.twitterproject.utils

import io.github.cdimascio.dotenv.Dotenv
import java.io.File

// get dynamic connection params of Kafka and MySQL
object ConnectUtils {

  def getParams(paramName: String): String = {

    //var path = "/home/ubuntu"
    var path = "/home/ubuntu/.env"
    val file = new File(path)

    if (!file.exists()) {
      path = "/Users/liuanxi/Desktop/NEU-CSYE7200/Twitter_Project/real_time_twitter_sentiment_analytics_system/src/main"
    }

    val dotenv = Dotenv.configure()
      .directory(path)
      .ignoreIfMalformed()
      .ignoreIfMissing()
      .load()

    dotenv.get(paramName)
  }
}
