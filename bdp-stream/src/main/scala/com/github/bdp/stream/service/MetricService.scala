package com.github.bdp.stream.service

import com.github.bdp.master.client.domain.SEVERITY.{AMBER, GREEN, RED}
import com.github.bdp.master.client.service.ServerService._
import com.github.bdp.stream.model.{Metric, ServerState}
import com.github.bdp.stream.util.JsonDecoder._
import com.typesafe.scalalogging.LazyLogging

object MetricService extends LazyLogging {

  def transform(metricMsg: String): Metric = {
    try {
      decodeMetric(metricMsg)
    } catch {
      case ex: Exception => {
        logger.error("decode kafka message error: " + ex.getMessage)
        null
      }
    }
  }

  def evaluate(metric:String, row:(String, Long, Double)): ServerState = {
    val (hostname, timestamp, avg) = row
    val server = getServerBy(hostname)
    val serverId = server.id
    val amberThreshold = server.metricThresholds(metric.replace('_','.')).amberThreshold
    val redThreshold = server.metricThresholds(metric.replace('_','.')).redThreshold
    val severity = avg match {
      case avg if avg < amberThreshold => GREEN
      case avg if avg >= redThreshold => RED
      case _ => AMBER
    }
    ServerState(serverId, timestamp, metric, severity.id)
  }

}