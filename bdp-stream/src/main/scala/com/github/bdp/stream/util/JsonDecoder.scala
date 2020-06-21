package com.github.bdp.stream.util

import java.sql.Timestamp

import com.github.bdp.stream.model.{Alert, Metric}
import io.circe.Decoder.Result
import io.circe.generic.semiauto.deriveDecoder
import io.circe.parser._
import io.circe.{Decoder, HCursor}

object JsonDecoder  {

	implicit private val metricDecoder: Decoder[Metric] = deriveDecoder
	implicit private val alertDecoder: Decoder[Alert] = deriveDecoder
	implicit private val timestampDecoder = new Decoder[Timestamp] {
		override def apply(c: HCursor): Result[Timestamp] = Decoder.decodeLong.map(s => new Timestamp(s)).apply(c)
	}

	def decodeMetric(json: String): Metric = {
		decode[Metric](json).right.get
	}

	def decodeAlert(json: String): Alert = {
		decode[Alert](json).right.get
	}
}
