package com.github.bdp.master.server.service;


import com.github.bdp.master.server.domain.AlertIndex;

import java.util.List;

public interface AlertIndexService {

	AlertIndex findOne(Long id);

	AlertIndex findOne(String alertName);

	void save(AlertIndex alertIndex);

	void delete(Long id);

	List<AlertIndex> findAll();

	void loadAll();
}
