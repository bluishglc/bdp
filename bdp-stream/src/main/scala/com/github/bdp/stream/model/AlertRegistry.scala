package com.github.bdp.stream.model

import com.github.bdp.master.client.service.AlertIndexService
import com.github.bdp.stream.Constants._
import com.typesafe.scalalogging.LazyLogging

import scala.collection.mutable
import scala.math._

case class AlertRegistry() extends LazyLogging {

	private var registry = mutable.Map[(Long, Long), (Boolean, Boolean)]()

	def updateWith(alerts: Iterator[Alert]): Unit = {
		alerts.foreach {
			alert =>
				val id = AlertIndexService.getAlertIndexBy(alert.message).id
				val timestamp = alert.timestamp.getTime
				val status = alert.status
				val key = (id,timestamp)
				val oldValue = registry.getOrElse(key, (false,false))
				val newValue = status match {
					case "OPEN" => (true, oldValue._2)
					case "CLOSED" => (oldValue._1, true)
				}
				registry.update(key, newValue)
		}
	}

	/**
		* If there is un-closed flag on any timestamp, return given severity,
		* because it means, for this server, there is at least an open alert on it.
		*/
	def evaluate():Int = {
		// need fold and go though all elements so as to get highest severity!
		registry.foldLeft(0){
			(severity,entry) =>
				val ((id,_),(open,closed)) = entry
				if (open && !closed) {
					max(severity,AlertIndexService.getAlertIndexBy(id).severity)
				} else {
					severity
				}
		}
	}

	/**
		* To avoid unbounded state...
		* @param now
		*/
	def cleanUp(now: Long): Unit = {
		registry = registry.filter{
			case ((id,timestamp),_) =>
				logger.debug(s"(CURRENT_TIME-ALERT_TIME)-ALERT_TIME_TO_LIVE=" +
					s"($now-$timestamp)-$ALERT_TIME_TO_LIVE = ${(now-timestamp)-ALERT_TIME_TO_LIVE}")
				if (now - timestamp < ALERT_TIME_TO_LIVE) {
					logger.debug(s"($id, $timestamp) is kept in session because it is LIVE.")
					true
				} else {
					logger.debug(s"($id, $timestamp) is removed from session because it is EXPIRED.")
					false
				}
		}
	}

}
