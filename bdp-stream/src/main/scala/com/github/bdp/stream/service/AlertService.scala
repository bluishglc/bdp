package com.github.bdp.stream.service

import com.github.bdp.master.client.service.ServerService._
import com.github.bdp.stream.Constants._
import com.github.bdp.stream.model._
import com.github.bdp.stream.util.JsonDecoder._
import com.typesafe.scalalogging.LazyLogging
import org.apache.spark.sql.streaming.GroupState


object AlertService extends LazyLogging {

  def transform(alertMsg: String): Alert = {
    try {
      decodeAlert(alertMsg)
    } catch {
      case ex: Exception => {
        logger.error("decode kafka message error: " + ex.getMessage)
        null
      }
    }
  }

  def getServerId(hostname: String): Long = {
    getServerBy(hostname).id
  }

  def updateAlertGroupState(serverId: Long, alerts: Iterator[Alert], state: GroupState[AlertRegistry]): ServerState = {
    val alertRegistry = state.getOption.getOrElse(AlertRegistry())
    val now = System.currentTimeMillis()/1000
    alertRegistry.cleanUp(now)
    alertRegistry.updateWith(alerts)
    state.update(alertRegistry)
    val severity = alertRegistry.evaluate()
    val timestamp = (now+5)/5*5000
    ServerState(serverId, timestamp, ALERT, severity)
  }

}