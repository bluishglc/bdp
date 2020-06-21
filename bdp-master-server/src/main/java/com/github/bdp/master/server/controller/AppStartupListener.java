package com.github.bdp.master.server.controller;

import com.github.bdp.master.server.service.AlertIndexService;
import com.github.bdp.master.server.service.AppService;
import com.github.bdp.master.server.service.MetricIndexService;
import com.github.bdp.master.server.service.ServerService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.event.ContextRefreshedEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

@Component
public class AppStartupListener {

    public static Logger logger = LoggerFactory.getLogger(AppStartupListener.class);

    @Autowired
    private AppService appService;

    @Autowired
    private ServerService serverService;

    @Autowired
    private MetricIndexService metricIndexService;

    @Autowired
    private AlertIndexService alertIndexService;

    @EventListener
    public void onApplicationEvent(ContextRefreshedEvent event) {
        logger.info("Start to load all data into redis....");
        appService.loadAll();
        serverService.loadAll();
        metricIndexService.loadAll();
        alertIndexService.loadAll();
        logger.info("loading all data into redis is done!");
    }
}