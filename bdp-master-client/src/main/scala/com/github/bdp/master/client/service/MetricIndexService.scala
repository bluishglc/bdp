package com.github.bdp.master.client.service

import com.github.bdp.master.client.Constants.METRIC_INDEX_KEYSPACE
import com.github.bdp.master.client.domain.MetricIndex
import com.github.bdp.master.client.util.{JsonDecoder, RedisClient}
import com.typesafe.scalalogging.LazyLogging

object MetricIndexService extends LazyLogging {

  def getMetricIndexBy(id: Long): MetricIndex = {
    JsonDecoder.decodeMetricIndex(RedisClient.get(s"$METRIC_INDEX_KEYSPACE:$id"))
  }

  def getMetricIndexBy(name: String): MetricIndex = {
    val key = RedisClient.get(s"i_$METRIC_INDEX_KEYSPACE:$name")
    JsonDecoder.decodeMetricIndex(RedisClient.get(key))
  }
}