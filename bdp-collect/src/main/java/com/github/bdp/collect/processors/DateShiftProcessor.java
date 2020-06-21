package com.github.bdp.collect.processors;

import org.apache.camel.Exchange;
import org.apache.camel.Message;
import org.apache.camel.Processor;
import org.joda.time.DateTime;

import java.util.Date;

public class DateShiftProcessor implements Processor {

	@Override
	public void process(Exchange exchange) throws Exception {
		Message message = exchange.getIn();
		Integer offset = message.getHeader("offset", Integer.class);
		Date firedTime = message.getHeader("firedTime", Date.class);
		DateTime dateTime = new DateTime(firedTime);
        DateTime shiftedTime = dateTime.minusSeconds(offset);
		message.setHeader("shiftedTime", shiftedTime.toDate());
	}

}
