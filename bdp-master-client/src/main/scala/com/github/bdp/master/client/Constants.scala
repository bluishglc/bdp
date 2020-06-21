package com.github.bdp.master.client

import com.typesafe.config.{Config, ConfigFactory}

/**
  * All constants in lib must be lazy!
  */
object Constants {

  private val config: Config = ConfigFactory.load("bdp-master-client.conf")

  val APP_SERVICE = "APP_SERVICE"
  val SERVER_SERVICE = "SERVER_SERVICE"
  val METRIC_THRESHOLD_SERVICE = "METRIC_THRESHOLD_SERVICE"

  val CPU_USAGE = "cpu.usage"
  val MEM_USED = "mem.used"

  val APP_KEYSPACE = "bdp-metric"
  val SERVER_KEYSPACE = "server"
  val ALERT_INDEX_KEYSPACE = "alert_index"
  val METRIC_INDEX_KEYSPACE = "metric_index"

  val REDIS_HOST = config.getString("redis.host")
  val REDIS_PORT = config.getInt("redis.port")
}