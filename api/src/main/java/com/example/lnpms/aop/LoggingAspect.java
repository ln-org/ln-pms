package com.example.lnpms.aop;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

/**
 * 示例AOP切面：记录方法执行时间
 * 教学目的：演示AOP的使用
 */
@Aspect
@Component
public class LoggingAspect {
    private static final Logger log = LoggerFactory.getLogger(LoggingAspect.class);

    @Around("execution(* com.example.lnpms.web..*(..))")
    public Object logAround(ProceedingJoinPoint pjp) throws Throwable {
        long start = System.currentTimeMillis();
        String methodName = pjp.getSignature().toShortString();
        
        log.info("=== AOP示例 === 方法开始执行: {}", methodName);
        
        try {
            Object result = pjp.proceed();
            long cost = System.currentTimeMillis() - start;
            log.info("=== AOP示例 === 方法执行成功: {}, 耗时: {} ms", methodName, cost);
            return result;
        } catch (Throwable ex) {
            long cost = System.currentTimeMillis() - start;
            log.error("=== AOP示例 === 方法执行失败: {}, 耗时: {} ms, 异常: {}", 
                     methodName, cost, ex.getMessage());
            throw ex;
        }
    }
}


