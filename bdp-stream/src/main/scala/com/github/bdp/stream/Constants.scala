package com.github.bdp.stream

import com.typesafe.config.{Config, ConfigFactory}
import org.apache.hadoop.hbase.util.Bytes

/**
 *  System constants, some are loaded from configuration file.
 *
 *  @author lichao.geng
 */
object Constants {

  private val config: Config = ConfigFactory.load("bdp-stream.conf")

  // spark related constants
  private val  sparkConfig = config.getConfig("spark")
  val SLIDE = sparkConfig.getString("slide")
  val WINDOW = sparkConfig.getString("window")
  val CHECKPOINT = sparkConfig.getString("checkpoint")

  // kafka related constants
  private val  hbaseConfig = config.getConfig("hbase")
  val HBASE_ZK_QUORUM = hbaseConfig.getString("zkQuorum")
  val HBASE_ZK_PORT = hbaseConfig.getString("zkPort")

  private val kafkaConfig = config.getConfig("kafka")
  val KAFKA_BROKER_LIST = kafkaConfig.getString("brokerList")

  // message type name
  val TOPIC_CPU_USAGE = "cpu.usage"
  val TOPIC_MEM_USED = "mem.used"
  val TOPIC_ALERT = "alert"

  // message type name
  val CPU_USAGE = "cpu_usage"
  val MEM_USED = "mem_used"
  val ALERT = "alert"

  private val metricConfig = config.getConfig("stream.metric")
  val CPU_USAGE_STREAM_ENABLED = metricConfig.getBoolean("cpuUsageEnabled")
  val CPU_USAGE_MSG_KEY_PREFIX = metricConfig.getString("cpuUsageKeyPrefix")
  val MEM_USED_STREAM_ENABLED = metricConfig.getBoolean("memUsedEnabled")
  val MEM_USED_MSG_KEY_PREFIX = metricConfig.getString("memUsedKeyPrefix")
  val METRIC_WATERMARK = metricConfig.getString("watermark")

  private val alertConfig = config.getConfig("stream.alert")
  val ALERT_STREAM_ENABLED = alertConfig.getBoolean("enabled")
  val ALERT_MSG_KEY_PREFIX = alertConfig.getString("keyPrefix")
  val ALERT_TIME_TO_LIVE = alertConfig.getLong("timeToLive")
  val ALERT_WATERMARK = alertConfig.getString("watermark")

  val METRIC_TABLE_NAME = config.getString("hbase.schema.metric.table")
  val METRIC_COL_FAMILY = Bytes.toBytes(config.getString("hbase.schema.metric.columnFamily"))
  private val metricQualifier = config.getConfig("hbase.schema.metric.qualifier")
  val METRIC_Q_NAME = Bytes.toBytes(metricQualifier.getString("name"))
  val METRIC_Q_HOSTNAME = Bytes.toBytes(metricQualifier.getString("hostname"))
  val METRIC_Q_TIMESTAMP = Bytes.toBytes(metricQualifier.getString("timestamp"))
  val METRIC_Q_VALUE = Bytes.toBytes(metricQualifier.getString("value"))

  val ALERT_TABLE_NAME = config.getString("hbase.schema.alert.table")
  val ALERT_COL_FAMILY = Bytes.toBytes(config.getString("hbase.schema.alert.columnFamily"))
  private val alertQualifier = config.getConfig("hbase.schema.alert.qualifier")
  val ALERT_Q_MESSAGE = Bytes.toBytes(alertQualifier.getString("message"))
  val ALERT_Q_SEVERITY = Bytes.toBytes(alertQualifier.getString("severity"))
  val ALERT_Q_HOSTNAME = Bytes.toBytes(alertQualifier.getString("hostname"))
  val ALERT_Q_TIMESTAMP = Bytes.toBytes(alertQualifier.getString("timestamp"))
  val ALERT_Q_STATUS = Bytes.toBytes(alertQualifier.getString("status"))

  val SERVER_STATE_TABLE_NAME = config.getString("hbase.schema.serverState.table")
  val SERVER_STATE_COL_FAMILY = Bytes.toBytes(config.getString("hbase.schema.serverState.columnFamily"))
  private val serverStateQualifier = config.getConfig("hbase.schema.serverState.qualifier")
//  val SERVER_STATE_Q_SERVER_ID = Bytes.toBytes(serverStateQualifier.getString("getServerId"))
//  val SERVER_STATE_Q_TIMESTAMP = Bytes.toBytes(serverStateQualifier.getString("timestamp"))
  val SERVER_STATE_Q_SRC_TYPE = Bytes.toBytes(serverStateQualifier.getString("srcType"))
  val SERVER_STATE_Q_SEVERITY = Bytes.toBytes(serverStateQualifier.getString("severity"))

}