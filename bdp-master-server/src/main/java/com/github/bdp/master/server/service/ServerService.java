package com.github.bdp.master.server.service;

import java.util.List;
import com.github.bdp.master.server.domain.Server;

public interface ServerService {

	Server findOne(Long id);

	Server findOne(String serverName);

	void save(Server server);

	void delete(Long id);

	List<Server> findAll();

	void loadAll();
}
