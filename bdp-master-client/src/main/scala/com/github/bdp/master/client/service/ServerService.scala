package com.github.bdp.master.client.service

import com.github.bdp.master.client.Constants._
import com.github.bdp.master.client.domain.Server
import com.github.bdp.master.client.util.{JsonDecoder, RedisClient}
import com.typesafe.scalalogging.LazyLogging

object ServerService extends LazyLogging {

  def getServerBy(id: Long): Server = {
    JsonDecoder.decodeServer(RedisClient.get(s"$SERVER_KEYSPACE:$id"))
  }

  def getServerBy(hostname: String): Server = {
    val key = RedisClient.get(s"i_$SERVER_KEYSPACE:$hostname")
    JsonDecoder.decodeServer(RedisClient.get(key))
  }

}