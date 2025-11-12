package com.example.lnpms.config;

import io.swagger.v3.oas.models.ExternalDocumentation;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Swagger/OpenAPI配置
 * 教学目的：演示API文档自动生成
 */
@Configuration
public class OpenApiConfig {
    
    @Bean
    public OpenAPI api() {
        return new OpenAPI()
                .info(new Info()
                        .title("LN-PMS API")
                        .version("v1.0")
                        .description("Learning Project Management System - Java后端教学示例项目")
                        .contact(new Contact()
                                .name("教学团队")
                                .email("training@example.com")
                        )
                )
                .externalDocs(new ExternalDocumentation()
                        .description("Swagger UI文档")
                        .url("/swagger-ui.html")
                );
    }
}


