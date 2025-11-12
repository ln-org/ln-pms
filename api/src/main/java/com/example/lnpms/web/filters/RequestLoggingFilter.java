package com.example.lnpms.web.filters;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.io.IOException;

/**
 * 示例过滤器：记录请求详细信息
 * 教学目的：演示如何获取请求的详细信息
 */
@Component
@Order(1)
public class RequestLoggingFilter implements Filter {
    private static final Logger log = LoggerFactory.getLogger(RequestLoggingFilter.class);
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) 
            throws IOException, ServletException {
        
        if (request instanceof HttpServletRequest req) {
            // 记录请求详细信息
            log.info("=== Filter示例 === 请求方法: {}", req.getMethod());
            log.info("=== Filter示例 === 请求路径: {}", req.getRequestURI());
            log.info("=== Filter示例 === 客户端IP: {}", req.getRemoteAddr());
            log.info("=== Filter示例 === User-Agent: {}", req.getHeader("User-Agent"));
        }
        
        // 继续过滤器链
        chain.doFilter(request, response);
    }
}

