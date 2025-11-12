# 项目结构说明

这是一个基础框架。

## 技术栈

- **Java**: 21
- **Spring Boot**: 3.3.4
- **API文档**: Swagger/OpenAPI 3.0
- **容器化**: Docker + Docker Compose

## 项目结构

```
src/main/java/com/example/filestore/
├── FilestoreApplication.java          # 应用主类
├── aop/                                # AOP切面
│   └── LoggingAspect.java             # 示例：方法执行日志
├── config/                             # 配置类
│   ├── OpenApiConfig.java             # Swagger配置
│   ├── WebMvcConfig.java              # MVC配置（拦截器注册）
├── listeners/                          # 监听器
│   └── AppListeners.java              # 示例：应用启动监听
├── model/                              # 数据模型
├── repository/                         # 数据访问层
├── schedule/                           # 定时任务
│   └── FileCountScheduler.java        # 示例：定时任务
├── service/                            # 业务逻辑层
│   └── FileStorageService.java        # 示例：业务服务
└── web/                                # 控制器层
    ├── HelloController.java           # 示例：Hello API
    ├── ApiAuthController.java         # API认证（JWT登录/注册）
    ├── AuthController.java            # 页面认证（表单登录/注册）
    ├── PageController.java            # 页面路由
    ├── ErrorController.java           # 错误页面
    ├── filters/                        # 过滤器
    │   └── RequestLogging.java        # 示例：请求日志过滤器
    └── interceptors/                   # 拦截器
        └── LoggingInterceptor.java     # 示例：拦截器
```

## 核心组件说明

### 1. Filter（过滤器）
- **位置**: `web/filters/CorrelationIdFilter.java`
- **功能**: 演示Filter的使用，记录请求进出日志
- **执行时机**: 在Servlet之前和之后

### 2. Interceptor（拦截器）
- **位置**: `web/interceptors/AccessDeniedInterceptor.java`  
- **功能**: 演示Interceptor的三个方法（preHandle, postHandle, afterCompletion）
- **执行时机**: 在Controller之前和之后

### 3. AOP（切面）
- **位置**: `aop/LoggingAspect.java`
- **功能**: 记录Controller方法执行时间
- **切入点**: 所有Controller方法

### 4. Scheduler（定时任务）
- **位置**: `schedule/FileCountScheduler.java`
- **功能**: 演示定时任务的使用
- **执行频率**: 每分钟一次（Cron）+ 每10秒一次（fixedDelay）

### 5. Listener（监听器）
- **位置**: `listeners/AppListeners.java`
- **功能**: 监听应用启动事件
- **触发时机**: 应用启动完成后


## API端点

### 公开接口（不需要JWT）

| 端点 | 方法 | 说明 |
|------|------|------|
| `/api/hello` | GET | Hello示例 |
| `/api/info` | GET | 系统信息 |
| `/api/auth/login` | POST | 用户登录 |
| `/api/auth/register` | POST | 用户注册 |

### 受保护接口（需要JWT）

| 端点 | 方法 | 说明 |
|------|------|------|
| `/api/protected` | GET | 受保护的示例接口 |
| `/api/auth/me` | GET | 获取当前用户信息 |

## 快速开始

### 1. 启动应用

使用Docker Compose：

```bash
docker compose up -d
```

或本地运行：

```bash
mvn spring-boot:run
```

### 2. 访问应用

- **首页**: http://localhost:8085
- **Swagger API文档**: http://localhost:8085/swagger-ui.html
- **数据库**: localhost:5432

### 3. 测试API

#### 公开接口（无需认证）：

```bash
curl http://localhost:8085/api/hello?name=Java
curl http://localhost:8085/api/info
```


### 4. 使用Swagger测试

1. 访问 http://localhost:8085/swagger-ui.html
2. 使用 `/api/auth/login` 接口获取Token
3. 点击右上角 "Authorize" 按钮
4. 输入Token（不需要Bearer前缀）
5. 测试需要认证的接口


## 日志示例

启动后，您会看到各组件的日志输出：

```
=== Listener示例 === 应用启动完成，准备接收请求
=== Filter示例 === 请求进入: GET /api/hello
=== Interceptor示例 === preHandle: GET /api/hello
=== AOP示例 === 方法开始执行: HelloController.hello(..)
=== Controller示例 === hello方法被调用, name=World
=== AOP示例 === 方法执行成功: HelloController.hello(..), 耗时: 5 ms
=== Interceptor示例 === postHandle: Controller执行完成
=== Interceptor示例 === afterCompletion: 请求完全处理完成
=== Filter示例 === 请求完成: GET /api/hello
=== Scheduler示例 === 定时任务执行，当前时间: 2024-11-11T10:00:00
```


