package com.github.bdp.master.server.controller;

import com.github.bdp.master.server.domain.MetricIndex;
import com.github.bdp.master.server.service.MetricIndexService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

@RestController
public class MetricIndexController {

	@Autowired
	private MetricIndexService metricIndexService;

	@RequestMapping(method = RequestMethod.GET, path = "/metricIndexes")
	public List<MetricIndex> findAll(HttpServletRequest request) {
		return metricIndexService.findAll();
	}

	@RequestMapping(method = RequestMethod.GET, path = "/metricIndex/{id}")
	public MetricIndex find(@PathVariable Long id) {
		return metricIndexService.findOne(id);
	}

	@RequestMapping(method = RequestMethod.GET, path = "/metricIndex")
	public MetricIndex find(@RequestParam("name") String name) {
		return  metricIndexService.findOne(name);
	}

	@RequestMapping(method = RequestMethod.POST, path = "/metricIndex")
	public void save(@RequestBody MetricIndex metricIndex) {
		metricIndexService.save(metricIndex);
	}

	@RequestMapping(method = RequestMethod.DELETE, path = "/metricIndex/{id}")
	public void delete(@PathVariable Long id) {
		metricIndexService.delete(id);
	}

}
