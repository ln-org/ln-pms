package com.example.lnpms.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

/**
 * 示例Service：业务逻辑层示例
 * 教学目的：演示Service层的使用
 */
@Service
public class FileStorageService {
    private static final Logger log = LoggerFactory.getLogger(FileStorageService.class);

    public String processFile(String filename) {
        log.info("=== Service示例 === 处理文件: {}", filename);
        // 这里只是示例，实际业务逻辑已删除
        return "文件处理完成: " + filename;
    }
    
    public void exampleBusinessLogic() {
        log.info("=== Service示例 === 执行业务逻辑");
    }
}
