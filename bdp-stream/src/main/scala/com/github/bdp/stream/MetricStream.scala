package com.github.bdp.stream

import com.github.bdp.stream.Constants._
import com.github.bdp.stream.model.Metric
import com.github.bdp.stream.service.MetricService
import com.github.bdp.stream.util.{MetricWriter, ServerStateWriter}
import com.typesafe.scalalogging.LazyLogging
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._

object MetricStream extends LazyLogging {

	def restream(metric: String)(implicit sparkSession: SparkSession): Unit = {
		persist(metric)
		evaluate(metric)
	}

	def persist(metric: String)(implicit sparkSession: SparkSession): Unit = {
		import sparkSession.implicits._
		sparkSession.sparkContext.setLocalProperty("spark.scheduler.pool", s"pool_persist_$metric")
		sparkSession
			.sql(s"select * from $metric").as[Metric]
			.writeStream
			.outputMode("update")
			.foreach(MetricWriter())
			.queryName(s"persist_$metric")
			.start
	}

	def evaluate(metric: String)(implicit sparkSession: SparkSession): Unit = {
		import sparkSession.implicits._
		sparkSession.sparkContext.setLocalProperty("spark.scheduler.pool", s"pool_evaluate_$metric")
		sparkSession
			.sql(s"select * from $metric").as[Metric]
			.withWatermark("timestamp", METRIC_WATERMARK)
			.dropDuplicates("id", "timestamp")
			.groupBy($"hostname", window($"timestamp", WINDOW, SLIDE))
			.agg(avg($"value") as "avg")
			.select($"hostname", (unix_timestamp($"window.end") cast "bigint") as "timestamp", $"avg")
			.as[(String, Long, Double)]
			.map(MetricService.evaluate(metric, _))
			.writeStream
			.outputMode("update")
			.foreach(ServerStateWriter())
			.queryName(s"evaluate_${metric}")
			.start
	}

}
