package com.github.bdp.master.server.service.impl;


import com.github.bdp.master.server.domain.MetricIndex;
import com.github.bdp.master.server.repository.MetricIndexJpaRepository;
import com.github.bdp.master.server.repository.MetricIndexRedisRepository;
import com.github.bdp.master.server.service.MetricIndexService;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Component("metricService")
@Transactional
public class MetricIndexServiceImpl implements MetricIndexService {

	private final MetricIndexJpaRepository metricIndexJpaRepository;

	private final MetricIndexRedisRepository metricIndexRedisRepository;

	public MetricIndexServiceImpl(MetricIndexJpaRepository metricIndexJpaRepository,
								  MetricIndexRedisRepository metricIndexRedisRepository) {
		this.metricIndexJpaRepository = metricIndexJpaRepository;
		this.metricIndexRedisRepository = metricIndexRedisRepository;
	}

	@Override
	public void save(MetricIndex metricIndex) {
		MetricIndex savedMetricIndex = metricIndexJpaRepository.save(metricIndex);
		metricIndexRedisRepository.save(savedMetricIndex);
	}

	@Override
	public MetricIndex findOne(Long id) {
		return metricIndexRedisRepository.findOne(id);
	}

	@Override
	public MetricIndex findOne(String metricName) {
		return metricIndexRedisRepository.findOne(metricName);
	}

	@Override
	public void delete(Long id) {
		MetricIndex metricIndex = findOne(id);
		metricIndexJpaRepository.delete(metricIndex.getId());
		metricIndexRedisRepository.delete(metricIndex);
	}

	@Override
	public List<MetricIndex> findAll() {
		return metricIndexRedisRepository.findAll();
	}

	@Override
	public void loadAll() {
		metricIndexJpaRepository.findAll().forEach(
				metric -> metricIndexRedisRepository.save(metric)
		);
	}
}
