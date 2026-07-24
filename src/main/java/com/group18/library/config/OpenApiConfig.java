package com.group18.library.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.*;

@Configuration
public class OpenApiConfig {
    @Bean
    public OpenAPI libraryOpenAPI() {
        return new OpenAPI().info(new Info()
            .title("Library Management API - Group 18")
            .version("1.0.0")
            .description("RESTful API cho hệ thống quản lý thư viện"));
    }
}
