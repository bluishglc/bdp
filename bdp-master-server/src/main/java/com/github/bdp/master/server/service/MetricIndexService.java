package com.github.bdp.master.server.service;


import com.github.bdp.master.server.domain.MetricIndex;

import java.util.List;

public interface MetricIndexService {

	MetricIndex findOne(Long id);

	MetricIndex findOne(String metricName);

	void save(MetricIndex metricIndex);

	void delete(Long id);

	List<MetricIndex> findAll();

	void loadAll();
}
