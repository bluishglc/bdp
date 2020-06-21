package com.github.bdp.master.server;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ConfigurableApplicationContext;

@SpringBootApplication
public class Main {

	public static void main(String[] args) {
		SpringApplication.run(Main.class, args);
	}

	public static ConfigurableApplicationContext getSpringBeanContext() {
		return SpringApplication.run(Main.class, new String[] {});
	}
}
