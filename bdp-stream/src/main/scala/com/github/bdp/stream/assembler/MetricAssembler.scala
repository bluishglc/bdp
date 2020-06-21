package com.github.bdp.stream.assembler

import com.github.bdp.stream.Constants._
import com.github.bdp.stream.model.Metric
import org.apache.hadoop.hbase.client.Put
import org.apache.hadoop.hbase.util.Bytes

object MetricAssembler {
	def assemble(metric: Metric): Put = {
		// The row key format: [hostname][metric][timestamp]
		// we assume hostname is fixed length, for metric, we use fixed length abbreviation,
		// i.e. cpu.usage is cu, memory free is mu and so on.
		val put = new Put(Bytes.toBytes(metric.id)) // row key
		// column, qualifier, value
		put.addColumn(METRIC_COL_FAMILY, METRIC_Q_NAME, Bytes.toBytes(metric.name))
		put.addColumn(METRIC_COL_FAMILY, METRIC_Q_HOSTNAME, Bytes.toBytes(metric.hostname))
		put.addColumn(METRIC_COL_FAMILY, METRIC_Q_TIMESTAMP, Bytes.toBytes(metric.timestamp.getTime))
		put.addColumn(METRIC_COL_FAMILY, METRIC_Q_VALUE, Bytes.toBytes(metric.value))
		put
	}
}
