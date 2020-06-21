package com.github.bdp.stream.util

import com.github.bdp.stream.Constants._
import com.github.bdp.stream.assembler.{AlertAssembler, MetricAssembler, ServerStateAssembler}
import com.github.bdp.stream.model.{Alert, Metric, ServerState}
import com.typesafe.scalalogging.LazyLogging
import org.apache.hadoop.hbase.client.BufferedMutator
import org.apache.spark.sql.ForeachWriter

case class MetricWriter() extends ForeachWriter[Metric] with LazyLogging {

	private var mutator: BufferedMutator = _

	override def open(partitionId: Long, version: Long): Boolean = {
		try {
			mutator = HBaseClient.mutator(METRIC_TABLE_NAME)
			logger.debug(s"Opening HBase connection & mutator for table [ $METRIC_TABLE_NAME (partitionId=$partitionId) ] is done!")
			true
		} catch {
			case e: Throwable =>
				logger.error(s"Opening HBase mutator for table [ $METRIC_TABLE_NAME (partitionId=$partitionId) ] is failed! the error message is: ${e.getMessage}")
				throw e
				false
		}
	}

	override def process(metric: Metric): Unit = {
		val put = MetricAssembler.assemble(metric)
		mutator.mutate(put)
	}

	override def close(errorOrNull: Throwable): Unit = {
		try {
			mutator.close()
			logger.debug(s"Closing HBase connection & mutator for table [ $METRIC_TABLE_NAME ] is done!")
		} catch {
			case e: Throwable =>
				logger.error(s"Closing HBase mutator for table [ $METRIC_TABLE_NAME ] is failed! the error message is: ${e.getMessage}")
				throw e
		}
	}
}

case class AlertWriter() extends ForeachWriter[Alert] with LazyLogging {

	private var mutator: BufferedMutator = _

	override def open(partitionId: Long, version: Long): Boolean = {
		try {
			mutator = HBaseClient.mutator(ALERT_TABLE_NAME)
			logger.debug(s"Opening HBase connection & mutator for table [ $ALERT_TABLE_NAME (partitionId=$partitionId) ] is done!")
			true
		} catch {
			case e: Throwable =>
				logger.error(s"Opening HBase mutator for table [ $ALERT_TABLE_NAME (partitionId=$partitionId) ] is failed! the error message is: ${e.getMessage}")
				throw e
				false
		}
	}

	override def process(alert: Alert): Unit = {
		val put = AlertAssembler.assemble(alert)
		mutator.mutate(put)
		logger.debug(s"alert=$alert")
	}

	override def close(errorOrNull: Throwable): Unit = {
		try {
			mutator.close()
			logger.debug(s"Closing HBase connection & mutator for table [ $ALERT_TABLE_NAME ] is done!")
		} catch {
			case e: Throwable =>
				logger.error(s"Closing HBase mutator for table [ $ALERT_TABLE_NAME ] is failed! the error message is: ${e.getMessage}")
				throw e
		}
	}
}

case class ServerStateWriter() extends ForeachWriter[ServerState] with LazyLogging {

	private var mutator: BufferedMutator = _

	override def open(partitionId: Long, version: Long): Boolean = {
		try {
			mutator = HBaseClient.mutator(SERVER_STATE_TABLE_NAME)
			logger.debug(s"Opening HBase connection & mutator for table [ $SERVER_STATE_TABLE_NAME (partitionId=$partitionId) ] is done!")
			true
		} catch {
			case e: Throwable =>
				logger.error(s"Opening HBase mutator for table [ $SERVER_STATE_TABLE_NAME (partitionId=$partitionId) ] is failed! the error message is: ${e.getMessage}")
				throw e
				false
		}
	}

	override def process(serverState: ServerState): Unit = {
		val put = ServerStateAssembler.assemble(serverState)
		mutator.mutate(put)
		logger.debug(s"serverState=$serverState")
	}

	override def close(errorOrNull: Throwable): Unit = {
		try {
			mutator.close()
			logger.debug(s"Closing HBase connection & mutator for table [ $SERVER_STATE_TABLE_NAME ] is done!")
		} catch {
			case e: Throwable =>
				logger.error(s"Closing HBase mutator for table [ $SERVER_STATE_TABLE_NAME ] is failed! the error message is: ${e.getMessage}")
				throw e
		}
	}
}