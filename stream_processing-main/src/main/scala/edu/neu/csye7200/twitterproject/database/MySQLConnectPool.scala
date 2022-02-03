package edu.neu.csye7200.twitterproject.database

import com.mchange.v2.c3p0.ComboPooledDataSource
import edu.neu.csye7200.twitterproject.utils.ConnectUtils

import java.sql.Connection


class MySQLConnectPool extends Serializable{
  private val cpds: ComboPooledDataSource = new ComboPooledDataSource(true) // auto registration
  try {
    // setup MySQL params
//    cpds.setJdbcUrl("jdbc:mysql://localhost:3306/twitter?useUnicode=true&characterEncoding=UTF-8")
    cpds.setJdbcUrl("jdbc:mysql://"+ConnectUtils.getParams("MYSQL_URL")+":3306/webapp_mysql_development")
    cpds.setDriverClass("com.mysql.cj.jdbc.Driver")  //mysql-connector-java-8.0.16 driver
    cpds.setUser(ConnectUtils.getParams("MYSQL_USER"))
    cpds.setPassword(ConnectUtils.getParams("MYSQL_PW"))
    cpds.setMaxPoolSize(10)
    cpds.setMinPoolSize(2)
    cpds.setAcquireIncrement(2)
    cpds.setMaxStatements(180)
  } catch {
    case e: Exception => e.printStackTrace()
  }

  // get connection
  def getConnection: Connection = {
    try {
       cpds.getConnection()
    } catch {
      case e: Exception => e.printStackTrace()
        null
    }
  }
}

// lazy singleton, initialize as needed
object MySQLManager {
  @volatile private var mysqlPool: MySQLConnectPool = _
  def getMysqlPool: MySQLConnectPool = {
    if (mysqlPool == null) {
      synchronized {
        if (mysqlPool == null) {
          mysqlPool = new MySQLConnectPool
        }
      }
    }
    mysqlPool
  }
}

