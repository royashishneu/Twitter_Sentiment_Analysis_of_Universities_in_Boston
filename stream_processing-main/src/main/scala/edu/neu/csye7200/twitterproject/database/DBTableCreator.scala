package edu.neu.csye7200.twitterproject.database

object DBTableCreator {
  def main(args: Array[String]): Unit = {
    // get MySQL connection
    val conn = MySQLManager.getMysqlPool.getConnection
    if (conn == null) {
      println("conn is null.") // print in the executor of worker
    } else {
      println("conn is not null.")
      // create statement
      val statement = conn.createStatement()
      try {
        conn.setAutoCommit(false) //do not auto commit

        //create SQL query
        val sql = "CREATE TABLE tweetsInfo (" +
          "id INT PRIMARY KEY AUTO_INCREMENT, " +
          "keyword VARCHAR(25), " +
          "token VARCHAR(25), " +
          "sentiment_res INT, " +
          "like_num INT, " +
          "reply_num INT, " +
          "retweet_num INT);"
        statement.execute(sql)
        conn.commit() // transaction commit
      } catch {
        case e: Exception => e.printStackTrace()
      } finally {
        statement.close() // close statement
        conn.close() //connection close
      }
    }
  }
}
