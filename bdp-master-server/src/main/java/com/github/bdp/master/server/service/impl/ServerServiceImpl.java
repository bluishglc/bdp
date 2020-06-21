package com.github.bdp.master.server.service.impl;


import com.github.bdp.master.server.domain.Server;
import com.github.bdp.master.server.repository.ServerJpaRepository;
import com.github.bdp.master.server.repository.ServerRedisRepository;
import com.github.bdp.master.server.service.ServerService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class ServerServiceImpl implements ServerService {

	public static Logger logger = LoggerFactory.getLogger(ServerServiceImpl.class);

	private final ServerJpaRepository serverJpaRepository;

	private final ServerRedisRepository serverRedisRepository;

	@SuppressWarnings("unused")
	public ServerServiceImpl(ServerJpaRepository serverJpaRepository,
							 ServerRedisRepository serverRedisRepository) {
		this.serverJpaRepository = serverJpaRepository;
		this.serverRedisRepository = serverRedisRepository;
	}

	@Override
	public void loadAll() {
		serverJpaRepository.findAll().forEach(
			server -> serverRedisRepository.save(server)
		);
	}

	@Override
	public List<Server> findAll() {
		return serverRedisRepository.findAll();
	}

	@Override
	public void save(Server server) {
		logger.debug(server.getHostname());
		Server savedServer = serverJpaRepository.save(server);
		serverRedisRepository.save(savedServer);
	}

	@Override
	public Server findOne(Long id) {
		return serverRedisRepository.findOne(id);
	}

	@Override
	public Server findOne(String hostname) {
		return serverRedisRepository.findOne(hostname);
	}

	@Override
	public void delete(Long id) {
		Server app = findOne(id);
		serverJpaRepository.delete(app.getId());
		serverRedisRepository.delete(app);
	}

}
