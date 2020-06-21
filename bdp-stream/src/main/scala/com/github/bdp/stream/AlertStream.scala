package com.github.bdp.stream

import com.github.bdp.stream.Constants._
import com.github.bdp.stream.model.{Alert, AlertRegistry}
import com.github.bdp.stream.service.AlertService._
import com.github.bdp.stream.util.{AlertWriter, ServerStateWriter}
import com.typesafe.scalalogging.LazyLogging
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.streaming.GroupStateTimeout

object AlertStream extends LazyLogging {

	def restream(implicit sparkSession: SparkSession): Unit = {
		persist
		evaluate
	}

	/**
		* we assume no matter open or closed alert message, it can and only can push one time!
		* so here, once there is new alert, no matter what, persist it first! and there won't be duplicated messages.
		*/
	def persist(implicit sparkSession: SparkSession): Unit = {
		import sparkSession.implicits._
		sparkSession.sparkContext.setLocalProperty("spark.scheduler.pool", s"pool_persist_alert")
		sparkSession
			.sql(s"select * from alert").as[Alert]
			.writeStream
			.outputMode("update")
			.foreach(AlertWriter())
			.queryName(s"persist_alert")
			.start
	}

	def evaluate(implicit sparkSession: SparkSession): Unit = {
		import sparkSession.implicits._
		implicit val stateEncoder = org.apache.spark.sql.Encoders.kryo[AlertRegistry]
		sparkSession.sparkContext.setLocalProperty("spark.scheduler.pool", s"pool_evaluate_alert")
		sparkSession
			.sql(s"select * from alert").as[Alert]
			.withWatermark("timestamp", ALERT_WATERMARK)
  		.groupByKey(alert => getServerId(alert.hostname))
  		.mapGroupsWithState(GroupStateTimeout.NoTimeout)(updateAlertGroupState)
			.writeStream
			.outputMode("update")
			.foreach(ServerStateWriter())
			.queryName(s"evaluate_alert")
			.start
	}

}
