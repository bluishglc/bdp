package com.github.bdp.stream.assembler

import com.github.bdp.stream.Constants._
import com.github.bdp.stream.model.Alert
import org.apache.hadoop.hbase.client.Put
import org.apache.hadoop.hbase.util.Bytes

object AlertAssembler {
	def assemble(alert: Alert): Put = {
		val put = new Put(Bytes.toBytes(alert.id)) // row key
		// column, qualifier, value
		put.addColumn(ALERT_COL_FAMILY, ALERT_Q_MESSAGE, Bytes.toBytes(alert.message))
		put.addColumn(ALERT_COL_FAMILY, ALERT_Q_HOSTNAME, Bytes.toBytes(alert.hostname))
		put.addColumn(ALERT_COL_FAMILY, ALERT_Q_TIMESTAMP, Bytes.toBytes(alert.timestamp.getTime))
		put.addColumn(ALERT_COL_FAMILY, ALERT_Q_STATUS, Bytes.toBytes(alert.status))
		put
	}
}
