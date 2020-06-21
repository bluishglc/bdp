package com.github.bdp.master.server.service.impl;


import com.github.bdp.master.server.domain.AlertIndex;
import com.github.bdp.master.server.repository.AlertIndexJpaRepository;
import com.github.bdp.master.server.repository.AlertIndexRedisRepository;
import com.github.bdp.master.server.service.AlertIndexService;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Component("alertService")
@Transactional
public class AlertIndexServiceImpl implements AlertIndexService {


	private final AlertIndexJpaRepository alertIndexJpaRepository;

	private final AlertIndexRedisRepository alertIndexRedisRepository;

	public AlertIndexServiceImpl(AlertIndexJpaRepository alertIndexJpaRepository,
								 AlertIndexRedisRepository alertIndexRedisRepository) {
		this.alertIndexJpaRepository = alertIndexJpaRepository;
		this.alertIndexRedisRepository = alertIndexRedisRepository;
	}

	@Override
	public void save(AlertIndex alertIndex) {
		AlertIndex savedAlertIndex = alertIndexJpaRepository.save(alertIndex);
		alertIndexRedisRepository.save(savedAlertIndex);
	}

	@Override
	public AlertIndex findOne(Long id) {
		return alertIndexRedisRepository.findOne(id);
	}

	@Override
	public AlertIndex findOne(String name) {
		return alertIndexRedisRepository.findOne(name);
	}

	@Override
	public void delete(Long id) {
		AlertIndex alertIndex = findOne(id);
		alertIndexJpaRepository.delete(alertIndex.getId());
		alertIndexRedisRepository.delete(alertIndex);
	}

	@Override
	public List<AlertIndex> findAll() {
		return alertIndexRedisRepository.findAll();
	}

	@Override
	public void loadAll() {
		alertIndexJpaRepository.findAll().forEach(
				alert -> alertIndexRedisRepository.save(alert)
		);
	}
}
