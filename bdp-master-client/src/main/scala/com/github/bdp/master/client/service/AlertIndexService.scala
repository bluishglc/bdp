package com.github.bdp.master.client.service

import com.github.bdp.master.client.Constants._
import com.github.bdp.master.client.domain.AlertIndex
import com.github.bdp.master.client.util.{JsonDecoder, RedisClient}
import com.typesafe.scalalogging.LazyLogging

object AlertIndexService extends LazyLogging {

  def getAlertIndexBy(id: Long): AlertIndex = {
    JsonDecoder.decodeAlertIndex(RedisClient.get(s"$ALERT_INDEX_KEYSPACE:$id"))
  }

  def getAlertIndexBy(name: String): AlertIndex = {
    val key = RedisClient.get(s"i_$ALERT_INDEX_KEYSPACE:$name")
		JsonDecoder.decodeAlertIndex(RedisClient.get(key))
  }
}