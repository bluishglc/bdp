package com.github.bdp.master.client.service

import com.github.bdp.master.client.Constants._
import com.github.bdp.master.client.domain.App
import com.github.bdp.master.client.util.{JsonDecoder, RedisClient}
import com.typesafe.scalalogging.LazyLogging

object AppService extends LazyLogging {

  def getAppBy(id: Long): App = {
    JsonDecoder.decodeApp(RedisClient.get(s"$APP_KEYSPACE:$id"))
  }

  def getAppBy(name: String): App = {
    val key = RedisClient.get(s"i_$APP_KEYSPACE:$name")
    JsonDecoder.decodeApp(RedisClient.get(key))
  }

}