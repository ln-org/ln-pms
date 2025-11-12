package com.example.lnpms.schedule;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

/**
 * 示例定时任务：每分钟执行一次
 * 教学目的：演示@Scheduled的使用
 */
@Component
public class FileCountScheduler {
    private static final Logger log = LoggerFactory.getLogger(FileCountScheduler.class);

    // 每分钟执行一次
    @Scheduled(cron = "0 * * * * *")
    public void logFileCounts() {
        log.info("=== Scheduler示例 === 定时任务执行，当前时间: {}", LocalDateTime.now());
    }
    
    // 每10秒执行一次
    @Scheduled(fixedDelay = 10000)
    public void fixedDelayExample() {
        log.info("=== Scheduler示例 === 固定延迟任务执行（上次执行结束后10秒）");
    }
}


