package com.github.bdp.collect;

import org.apache.camel.spring.SpringCamelContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.support.ClassPathXmlApplicationContext;

public class Main {
	private static final Logger logger = LoggerFactory.getLogger(Main.class);

	public static void main(String[] args) throws Exception {

		ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext("camel-context.xml");

		SpringCamelContext camelContext = context.getBean(SpringCamelContext.class);

		try {
			camelContext.start();
			Runtime.getRuntime().addShutdownHook(new Thread() {
				@Override
				public void run() {
					try {
						camelContext.stop();
						context.close();
					} catch (Exception ex) {
						logger.error("stop camel context error:" + ex.getMessage());
					}
				}
			});
			logger.info("camel context started!");
			camelContext.start();
			Thread.sleep(Long.MAX_VALUE);
		} catch (Exception e) {
			camelContext.stop();
			context.close();
			e.printStackTrace();
		}
	}
}
