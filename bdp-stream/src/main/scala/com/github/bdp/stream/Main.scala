package com.github.bdp.stream

import com.github.bdp.stream.Constants._
import com.github.bdp.stream.service.AlertService
import com.github.bdp.stream.service.MetricService.transform
import com.typesafe.scalalogging.LazyLogging
import org.apache.spark.sql.SparkSession

/**
	* CAUTION!!
	* You should always use services in , never expose
	* any master entity in , because once it's exposed,
	* it will be se/de from driver to executor, this will cause
	* unnecessary resource cost!
	*
	* @author lichao.geng
	*/
object Main extends LazyLogging {

	def main(args: Array[String]): Unit = {
		try {
			implicit val sparkSession = SparkSession
				.builder
				.appName("bdp-stream")
				.config("spark.cleaner.referenceTracking.cleanCheckpoints", "true")
				.config("spark.streaming.stopGracefullyOnShutdown", "true")
				.getOrCreate()

			import sparkSession.implicits._

			sparkSession
				.readStream
				.format("kafka")
				.option("kafka.bootstrap.servers", KAFKA_BROKER_LIST)
				.option("subscribe", s"$TOPIC_CPU_USAGE, $TOPIC_MEM_USED, $TOPIC_ALERT")
				.option("startingOffsets", "latest")
				.load()
				.selectExpr("CAST(key AS STRING)", "CAST(value AS STRING)")
				.createTempView("trunk")

			if (CPU_USAGE_STREAM_ENABLED) {
				logger.info("[ CPU USAGE ]  streaming is enabled!")
				sparkSession
					.sql(s"select value from trunk where key like '$CPU_USAGE_MSG_KEY_PREFIX%'").as[String]
					.map(transform(_))
					.createTempView(CPU_USAGE)
				MetricStream.restream(CPU_USAGE)
			}

			if (MEM_USED_STREAM_ENABLED) {
				logger.info("[ MEM USED ]  streaming is enabled!")
				sparkSession
					.sql(s"select value from trunk where key like '$MEM_USED_MSG_KEY_PREFIX%'").as[String]
					.map(transform(_))
					.createTempView(MEM_USED)
				MetricStream.restream(MEM_USED)
			}

			if (ALERT_STREAM_ENABLED) {
				logger.info("[ ALERT ]  streaming is enabled!")
				sparkSession
					.sql(s"select value from trunk where key like '$ALERT_MSG_KEY_PREFIX%'").as[String]
					.map(AlertService.transform(_))
					.createTempView(ALERT)
				AlertStream.restream
			}
			sparkSession.streams.awaitAnyTermination()
//			sparkSession.streams.awaitAnyTermination(600000)
		} catch {
			case e: Throwable => e.printStackTrace()
		}
	}
}
