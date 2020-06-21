package com.github.bdp.master.server.service;


import com.github.bdp.master.server.domain.App;

import java.util.List;

public interface AppService {

	App findOne(Long id);

	App findOne(String appName);

	void save(App app);

	void delete(Long id);

	List<App> findAll();

	void loadAll();
}
