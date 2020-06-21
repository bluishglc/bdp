package com.github.bdp.master.server.controller;

import com.github.bdp.master.server.domain.Server;
import com.github.bdp.master.server.service.ServerService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

@RestController
public class ServerController {

	public static Logger logger = LoggerFactory.getLogger(ServerController.class);

	@Autowired
	private ServerService serverService;

	@RequestMapping(method = RequestMethod.GET, path = "/servers")
	public List<Server> findAll(HttpServletRequest request) {
		return serverService.findAll();
	}

	@RequestMapping(method = RequestMethod.GET, path = "/server/{id}")
	public Server find(@PathVariable Long id) {
		return serverService.findOne(id);
	}

	@RequestMapping(method = RequestMethod.GET, path = "/server")
	public Server find(@RequestParam("hostname") String hostname) {
		return  serverService.findOne(hostname);
	}

	@RequestMapping(method = RequestMethod.POST, path = "/server")
	public void save(@RequestBody Server server) {
		serverService.save(server);
	}

	@RequestMapping(method = RequestMethod.DELETE, path = "/server/{id}")
	public void delete(@PathVariable Long id) {
		serverService.delete(id);
	}


}
