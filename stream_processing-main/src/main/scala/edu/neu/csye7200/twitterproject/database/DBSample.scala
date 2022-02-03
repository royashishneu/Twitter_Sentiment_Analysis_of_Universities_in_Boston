package edu.neu.csye7200.twitterproject.database

object DBSample {
  def main(args: Array[String]): Unit = {
    val conn = MySQLManager.getMysqlPool.getConnection
    if (conn == null) {
      println("conn is null.")
    } else {
      println("conn is not null.")
      val statement = conn.createStatement()
      try {
        conn.setAutoCommit(false)
        val keyword = "trump"
        val token = "tokenxxx"
        val tweet = "tweettweettweet"
        val like_num = 222
        val reply_num = 333
        val retweet_num = 444
        val sentiment_res = -1
        val sql = "INSERT INTO tweetsInfo(keyword,token,sentiment_res,like_num,reply_num,retweet_num) " +
          "values ("+"'"+keyword+"'"+","+"'"+token+"'"+","+sentiment_res+","+like_num+","+reply_num+","+retweet_num+");"
        statement.addBatch(sql)
        statement.executeBatch()
        conn.commit()
      } catch {
        case e: Exception => e.printStackTrace()
      } finally {
        statement.close()
        conn.close()
      }
    }
  }
}
