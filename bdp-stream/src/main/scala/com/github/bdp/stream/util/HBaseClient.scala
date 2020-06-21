package com.github.bdp.stream.util

import com.typesafe.scalalogging.LazyLogging
import org.apache.hadoop.hbase.client.{Connection, ConnectionFactory}
import org.apache.hadoop.hbase.{HBaseConfiguration, TableName}
import org.apache.hadoop.hbase.client.BufferedMutator
import org.apache.hadoop.hbase.client.BufferedMutatorParams
import org.apache.hadoop.hbase.client.RetriesExhaustedWithDetailsException
import scala.collection.JavaConverters._
import com.github.bdp.stream.Constants._

/**
	* Typically, a single connection per client application is instantiated and every thread will obtain
	* its own Table instance. Caching or pooling of Table and Admin is not recommended.
	*/
object HBaseClient extends LazyLogging {

	private val connection = createConnection()

	private val mutatorParams = createMutatorParams()

	private def createMutatorParams(): Map[String, BufferedMutatorParams] = {
		Map[String, BufferedMutatorParams](
			METRIC_TABLE_NAME -> createMutatorParams(METRIC_TABLE_NAME),
			ALERT_TABLE_NAME -> createMutatorParams(ALERT_TABLE_NAME),
			SERVER_STATE_TABLE_NAME -> createMutatorParams(SERVER_STATE_TABLE_NAME)
		)
	}

	private def createMutatorParams(tableName: String): BufferedMutatorParams = {
		// a callback invoked when an asynchronous write fails.
		val listener = new BufferedMutator.ExceptionListener() {
			override def onException(e: RetriesExhaustedWithDetailsException, mutator: BufferedMutator): Unit = {
				for (cause: Throwable <- e.getCauses.asScala) {
					logger.error(s"HBase put operation failed! the error message is: ${cause.getMessage}")
					cause.printStackTrace()
				}
				throw e
			}
		}
		new BufferedMutatorParams(TableName.valueOf(tableName)).listener(listener)
	}

	private def createConnection(): Connection = {
		try {
			val conf = HBaseConfiguration.create()
			conf.addResource("hbase-site.xml")
			ConnectionFactory.createConnection(conf)
		} catch {
			case e: Throwable =>
				logger.error(s"HBase create connection operation failed! the error message is: ${e.getMessage}")
				throw e
		}
	}

	def mutator(tableName: String): BufferedMutator = {
		try {
			connection.getBufferedMutator(mutatorParams(tableName))
		} catch {
			case e: Exception =>
				logger.error(s"HBase get mutator operation failed! the error message is: ${e.getMessage}")
				throw e
		}
	}

}
