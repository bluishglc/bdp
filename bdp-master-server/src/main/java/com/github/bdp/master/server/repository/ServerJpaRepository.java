package com.github.bdp.master.server.repository;

import com.github.bdp.master.server.domain.Server;
import org.springframework.data.repository.PagingAndSortingRepository;

public interface ServerJpaRepository extends PagingAndSortingRepository<Server, Long> {}
