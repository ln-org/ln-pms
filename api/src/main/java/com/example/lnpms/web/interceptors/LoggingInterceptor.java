package com.example.lnpms.web.interceptors;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

/**
 * 示例拦截器：请求计时拦截器
 * 教学目的：演示如何在拦截器中传递数据和三个方法的使用
 */
@Component
public class LoggingInterceptor implements HandlerInterceptor {
    private static final Logger log = LoggerFactory.getLogger(LoggingInterceptor.class);
    
    private static final String START_TIME_ATTRIBUTE = "startTime";

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) 
            throws Exception {
        // 记录开始时间到request属性中
        long startTime = System.currentTimeMillis();
        request.setAttribute(START_TIME_ATTRIBUTE, startTime);
        
        log.info("=== Interceptor示例 === preHandle: 请求开始处理");
        return true;
    }
    
    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, 
                          ModelAndView modelAndView) throws Exception {
        Long startTime = (Long) request.getAttribute(START_TIME_ATTRIBUTE);
        if (startTime != null) {
            long duration = System.currentTimeMillis() - startTime;
            log.info("=== Interceptor示例 === postHandle: Controller处理耗时 {} ms", duration);
        }
    }
    
    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, 
                               Exception ex) throws Exception {
        Long startTime = (Long) request.getAttribute(START_TIME_ATTRIBUTE);
        if (startTime != null) {
            long totalDuration = System.currentTimeMillis() - startTime;
            log.info("=== Interceptor示例 === afterCompletion: 总耗时 {} ms, 状态码: {}", 
                    totalDuration, response.getStatus());
        }
        
        if (ex != null) {
            log.error("=== Interceptor示例 === 请求处理异常: {}", ex.getMessage());
        }
    }
}

