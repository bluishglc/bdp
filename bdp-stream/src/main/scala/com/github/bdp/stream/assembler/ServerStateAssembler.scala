package com.github.bdp.stream.assembler

import com.github.bdp.stream.Constants._
import com.github.bdp.stream.model.ServerState
import org.apache.hadoop.hbase.client.Put
import org.apache.hadoop.hbase.util.Bytes

object ServerStateAssembler {
	def assemble(serverState: ServerState): Put = {
		// The row key format: [hostname][serverState][timestamp]
		// we assume hostname is fixed length, for serverState, we use fixed length abbreviation,
		// i.e. cpu.usage is cu, memory free is mu and so on.
		val put = new Put(Bytes.toBytes(serverState.serverId) ++ Bytes.toBytes(serverState.timestamp)) // row key
		// column, qualifier, value
		put.addColumn(SERVER_STATE_COL_FAMILY, SERVER_STATE_Q_SRC_TYPE, Bytes.toBytes(serverState.srcType))
		put.addColumn(SERVER_STATE_COL_FAMILY, SERVER_STATE_Q_SEVERITY, Bytes.toBytes(serverState.severity))
		put
	}
}
