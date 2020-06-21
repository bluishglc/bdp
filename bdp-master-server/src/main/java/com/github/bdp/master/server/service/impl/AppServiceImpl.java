package com.github.bdp.master.server.service.impl;


import com.github.bdp.master.server.domain.App;
import com.github.bdp.master.server.repository.AppJpaRepository;
import com.github.bdp.master.server.repository.AppRedisRepository;
import com.github.bdp.master.server.service.AppService;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Component
@Transactional
public class AppServiceImpl implements AppService {

	private final AppJpaRepository appJpaRepository;

	private final AppRedisRepository appRedisRepository;

	public AppServiceImpl(AppJpaRepository appJpaRepository,
						  AppRedisRepository appRedisRepository) {
		this.appJpaRepository = appJpaRepository;
		this.appRedisRepository = appRedisRepository;
	}

	@Override
	public void save(App app) {
		App savedApp = appJpaRepository.save(app);
		appRedisRepository.save(savedApp);
	}

	@Override
	public App findOne(Long id) {
		return appRedisRepository.findOne(id);
	}

	@Override
	public App findOne(String appName) {
		return appRedisRepository.findOne(appName);
	}

	@Override
	public void delete(Long id) {
		App app = findOne(id);
		appJpaRepository.delete(app.getId());
		appRedisRepository.delete(app);
	}

	@Override
	public List<App> findAll() {
		return appRedisRepository.findAll();
	}

	@Override
	public void loadAll() {
		appJpaRepository.findAll().forEach(
			app -> appRedisRepository.save(app)
		);
	}
}
