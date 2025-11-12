package com.example.lnpms.web;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * 示例Controller：演示基本的REST API
 * 教学目的：演示Controller的使用（无需认证）
 */
@RestController
@RequestMapping("/api")
@Tag(name = "Hello API", description = "示例API接口")
public class HelloController {
    private static final Logger log = LoggerFactory.getLogger(HelloController.class);
    
    @GetMapping("/hello")
    @Operation(summary = "Hello接口", description = "基础示例接口，可传入name参数")
    public ResponseEntity<?> hello(@RequestParam(defaultValue = "World") String name) {
        log.info("=== Controller示例 === hello方法被调用, name={}", name);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Hello, " + name + "!");
        response.put("timestamp", LocalDateTime.now().toString());
        response.put("note", "这是一个公开的示例接口");
        
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/info")
    @Operation(summary = "系统信息", description = "获取系统基本信息")
    public ResponseEntity<?> info() {
        log.info("=== Controller示例 === info方法被调用");
        
        Map<String, Object> response = new HashMap<>();
        response.put("appName", "LN-PMS (Learning Project Management System)");
        response.put("version", "1.0.0");
        response.put("javaVersion", System.getProperty("java.version"));
        response.put("springBootVersion", "3.3.4");
        response.put("timestamp", LocalDateTime.now().toString());
        response.put("description", "Java后端开发教学示例项目");
        
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/demo")
    @Operation(summary = "演示接口", description = "演示不同的响应数据")
    public ResponseEntity<?> demo(@RequestParam(defaultValue = "test") String param) {
        log.info("=== Controller示例 === demo方法被调用, param={}", param);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("data", Map.of(
            "param", param,
            "length", param.length(),
            "uppercase", param.toUpperCase(),
            "lowercase", param.toLowerCase()
        ));
        response.put("timestamp", LocalDateTime.now());
        
        return ResponseEntity.ok(response);
    }
}

