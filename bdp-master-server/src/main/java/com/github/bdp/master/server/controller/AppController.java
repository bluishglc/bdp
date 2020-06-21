package com.github.bdp.master.server.controller;

import com.github.bdp.master.server.domain.App;
import com.github.bdp.master.server.service.AppService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

@RestController
public class AppController {

	public static Logger logger = LoggerFactory.getLogger(AppController.class);

	@Autowired
	private AppService appService;

	@RequestMapping(method = RequestMethod.GET, path = "/apps")
	public List<App> findAll(HttpServletRequest request) {
		return appService.findAll();
	}

	@RequestMapping(method = RequestMethod.GET, path = "/bdp-metric/{id}")
	public App find(@PathVariable Long id) {
		return appService.findOne(id);
	}

	@RequestMapping(method = RequestMethod.GET, path = "/bdp-metric")
	public App find(@RequestParam("appName") String appName) {
		return  appService.findOne(appName);
	}

	@RequestMapping(method = RequestMethod.POST, path = "/bdp-metric")
	public void save(@RequestBody App app) {
		appService.save(app);
	}

	@RequestMapping(method = RequestMethod.DELETE, path = "/bdp-metric/{id}")
	public void delete(@PathVariable Long id) {
		appService.delete(id);
	}

}
