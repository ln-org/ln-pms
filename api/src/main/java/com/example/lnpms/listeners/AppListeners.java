package com.example.lnpms.listeners;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.stereotype.Component;

/**
 * 示例监听器：监听应用启动事件
 * 教学目的：演示ApplicationListener的使用
 */
@Component
public class AppListeners implements ApplicationListener<ApplicationReadyEvent> {
    private static final Logger log = LoggerFactory.getLogger(AppListeners.class);

    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        log.info("=== Listener示例 === 应用启动完成，准备接收请求");
        log.info("=== Listener示例 === 访问地址: http://localhost:8085");
        log.info("=== Listener示例 === Swagger文档: http://localhost:8085/swagger-ui.html");
    }
}


