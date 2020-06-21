package com.github.bdp.master.client

import com.github.bdp.master.client.service.{AlertIndexService, AppService, MetricIndexService, ServerService}
import com.typesafe.scalalogging.LazyLogging

object Main extends App with LazyLogging {
	println(AppService.getAppBy(1))
	println(AppService.getAppBy("MyCRM"))

	println(ServerService.getServerBy(1))
	println(ServerService.getServerBy("svr1001"))

	println(AlertIndexService.getAlertIndexBy(1))
	println(AlertIndexService.getAlertIndexBy("free space warning (mb) for host disk"))

	println(MetricIndexService.getMetricIndexBy(1))
	println(MetricIndexService.getMetricIndexBy("cpu.usage"))
}
