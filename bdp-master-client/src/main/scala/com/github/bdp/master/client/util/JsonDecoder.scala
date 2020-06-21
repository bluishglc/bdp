package com.github.bdp.master.client.util

import java.sql.Timestamp

import com.github.bdp.master.client.domain.{AlertIndex, MetricIndex, MetricThreshold, Server, App}
import io.circe.Decoder.Result
import io.circe.{Decoder, HCursor}
import io.circe.generic.semiauto.deriveDecoder
import io.circe.parser._
object JsonDecoder  {

	implicit private val appDecoder: Decoder[App] = deriveDecoder[App]
	implicit private val serverDecoder: Decoder[Server] = deriveDecoder[Server]
	implicit private val metricThresholdDecoder: Decoder[MetricThreshold] = deriveDecoder[MetricThreshold]
	implicit private val metricIndexDecoder: Decoder[MetricIndex] = deriveDecoder[MetricIndex]
	implicit private val alertIndexDecoder: Decoder[AlertIndex] = deriveDecoder[AlertIndex]
	implicit private val timestampDecoder = new Decoder[Timestamp] {
		override def apply(c: HCursor): Result[Timestamp] = Decoder.decodeLong.map(s => new Timestamp(s)).apply(c)
	}

	def decodeApp(json: String): App = {
		decode[App](json).right.get
	}

	def decodeServer(json: String): Server = {
		decode[Server](json).right.get
	}

	def decodeMetricIndex(json: String): MetricIndex = {
		decode[MetricIndex](json).right.get
	}

	def decodeAlertIndex(json: String): AlertIndex = {
		decode[AlertIndex](json).right.get
	}

}
