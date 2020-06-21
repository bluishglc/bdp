package com.github.bdp.master.server.controller;

import com.github.bdp.master.server.domain.AlertIndex;
import com.github.bdp.master.server.service.AlertIndexService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

import static org.springframework.web.bind.annotation.RequestMethod.*;

@RestController
public class AlertIndexController {

	public static Logger logger = LoggerFactory.getLogger(AlertIndexController.class);

	@Autowired
	private AlertIndexService alertIndexService;

	@RequestMapping(method = GET, path = "/alertIndexes")
	public List<AlertIndex> findAll(HttpServletRequest request) {
		return alertIndexService.findAll();
	}

	@RequestMapping(method = GET, path = "/alertIndex/{id}")
	public AlertIndex find(@PathVariable Long id) {
		return alertIndexService.findOne(id);
	}

	@RequestMapping(method = GET, path = "/alertIndex")
	public AlertIndex find(@RequestParam("name") String name) {
		return  alertIndexService.findOne(name);
	}

	@RequestMapping(method = POST, path = "/alertIndex")
	public void save(@RequestBody AlertIndex alertIndex) {
		alertIndexService.save(alertIndex);
	}

	@RequestMapping(method = DELETE, path = "/alertIndex/{id}")
	public void delete(@PathVariable Long id) {
		alertIndexService.delete(id);
	}


}
