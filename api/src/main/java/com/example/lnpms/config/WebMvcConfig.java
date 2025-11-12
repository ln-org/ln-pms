package com.example.lnpms.config;

import com.example.lnpms.web.interceptors.LoggingInterceptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * MVC配置：注册拦截器
 * 教学目的：演示如何注册和配置拦截器
 */
@Configuration
public class WebMvcConfig implements WebMvcConfigurer {
    
    @Autowired
    private LoggingInterceptor loggingInterceptor;
    
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        // 拦截器：请求计时（演示preHandle/postHandle/afterCompletion）
        registry.addInterceptor(loggingInterceptor)
                .addPathPatterns("/api/**")  // 只拦截API路径
                .excludePathPatterns("/v3/api-docs/**", "/swagger-ui/**");
    }
}

