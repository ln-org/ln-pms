FROM maven:3.9-eclipse-temurin-21 AS builder
WORKDIR /build

# 配置Maven使用阿里云镜像源（解决国内网络问题）
COPY maven-settings.xml /root/.m2/settings.xml

COPY pom.xml .
COPY src ./src
# 执行打包并进行 Spring Boot 重打包，生成可执行 fat JAR
RUN mvn -s /root/.m2/settings.xml clean package spring-boot:repackage -DskipTests

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=builder /build/target/*-SNAPSHOT.jar /app/app.jar

ENV JAVA_OPTS=""
ENV LOG_PATH=/var/log/filestore
RUN mkdir -p ${LOG_PATH}

EXPOSE 8080
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]

