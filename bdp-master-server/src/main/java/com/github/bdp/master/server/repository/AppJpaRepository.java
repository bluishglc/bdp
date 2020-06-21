package com.github.bdp.master.server.repository;

import com.github.bdp.master.server.domain.App;
import org.springframework.data.repository.PagingAndSortingRepository;

public interface AppJpaRepository extends PagingAndSortingRepository<App, Long> {}
